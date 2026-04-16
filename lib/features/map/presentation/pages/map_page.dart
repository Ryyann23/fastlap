import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../../../shared/widgets/user_header_avatar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LatLng _fallbackCenter = const LatLng(-4.8645, -43.3573);

  List<LatLng> _routePoints = const [];
  LatLng? _userLocation;
  bool _loadingLocation = true;
  int _selectedTab = 0;
  final int _activeStepIndex = 2;

  String _formatBrasiliaDate() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';

    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadMapData());
  }

  Future<void> _loadMapData() async {
    final userPosition = await _fetchUserLocation();
    final center = userPosition ?? _fallbackCenter;

    if (!mounted) return;

    final points = _buildRoutePoints(center);
    setState(() {
      _userLocation = userPosition;
      _routePoints = points;
      _loadingLocation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(center, 18.5);
    });
  }

  Future<LatLng?> _fetchUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  List<LatLng> _buildRoutePoints(LatLng center) {
    return [
      LatLng(center.latitude - 0.010, center.longitude - 0.008),
      LatLng(center.latitude - 0.006, center.longitude - 0.004),
      LatLng(center.latitude - 0.001, center.longitude + 0.0005),
      LatLng(center.latitude + 0.004, center.longitude + 0.005),
      LatLng(center.latitude + 0.008, center.longitude + 0.009),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final dateText = _formatBrasiliaDate();
    final headerGradient = isDark
      ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
      : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];
    final mapCenter = _userLocation ?? _fallbackCenter;
    final stops = _routePoints.isEmpty ? _buildRoutePoints(mapCenter) : _routePoints;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              10 * scale,
              horizontalPadding,
              16 * scale,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
                stops: const [0.05, 0.55, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 34 * scale,
                        child: Image.asset('src/img/logo.png', fit: BoxFit.contain),
                      ),
                      const Spacer(),
                      ThemeModeButton(scale: scale),
                      SizedBox(width: 10 * scale),
                      UserHeaderAvatar(radius: 20 * scale),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    'Mapa de Rotas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 42 * scale,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      fontSize: 18 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 18.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.fastlap.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: stops,
                          color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFDB7B2C),
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (var i = 0; i < stops.length; i++)
                          Marker(
                            width: 34,
                            height: 34,
                            point: stops[i],
                            child: _stopMarker(String.fromCharCode(65 + i)),
                          ),
                        if (_userLocation != null)
                          Marker(
                            width: 22,
                            height: 22,
                            point: _userLocation!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFFB06CFF) : const Color(0xFF2D87FF),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (stops.length > _activeStepIndex)
                          Marker(
                            width: 34,
                            height: 44,
                            point: stops[_activeStepIndex],
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_shipping_rounded,
                                  color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE36F15),
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE36F15),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10 * scale,
                  left: horizontalPadding,
                  right: horizontalPadding,
                  child: Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1D2A).withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 48 * scale,
                          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF111421) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: const Color(0xFF858585), size: 22 * scale),
                              SizedBox(width: 8 * scale),
                              Text(
                                'Buscar endereco ou parada...',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : const Color(0xFF858585),
                                  fontSize: 16 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Row(
                          children: [
                            _MapTabChip(
                              label: 'Ativas',
                              selected: _selectedTab == 0,
                              scale: scale,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                            _MapTabChip(
                              label: 'Agendadas',
                              selected: _selectedTab == 1,
                              scale: scale,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                            _MapTabChip(
                              label: 'Historico',
                              selected: _selectedTab == 2,
                              scale: scale,
                              onTap: () => setState(() => _selectedTab = 2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 12 * scale,
                  child: _bottomRouteCard(scale),
                ),
                if (_loadingLocation)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FastlapBottomBar(
        scale: scale,
        currentTab: FastlapTab.mapa,
        onTabSelected: (tab) {
          if (tab == FastlapTab.inicio) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
            );
          }
          if (tab == FastlapTab.rotas) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const RoutesPage()),
            );
          }
          if (tab == FastlapTab.historico) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
            );
          }
          if (tab == FastlapTab.perfil) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _stopMarker(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _bottomRouteCard(double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(14 * scale, 12 * scale, 14 * scale, 0),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1D2A).withValues(alpha: 0.97)
            : Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rota 04 - Centro',
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFF0D6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Em Progresso',
                  style: TextStyle(
                    color: const Color(0xFF267A3B),
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dotStep('A', true, scale),
              _stepLine(active: false),
              _dotStep('B', false, scale),
              _stepLine(active: true),
              _dotStep('C', true, scale, showTruck: true),
              _stepLine(active: false),
              _dotStep('D', false, scale),
              _stepLine(active: false),
              _dotStep('E', false, scale),
            ],
          ),
          SizedBox(height: 8 * scale),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Est. 12:45 | 10.1 km restantes',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontSize: 15 * scale,
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(height: 1, color: const Color(0xFFE2E2E2)),
          SizedBox(
            height: 48 * scale,
            child: Row(
              children: [
                Expanded(
                  child: _actionRow(Icons.receipt_long_rounded, 'Ver Detalhes', scale),
                ),
                Container(width: 1, height: 24 * scale, color: const Color(0xFFE2E2E2)),
                Expanded(
                  child: _actionRow(Icons.navigation_outlined, 'Navegar', scale),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFC7742A),
          size: 21 * scale,
        ),
        SizedBox(width: 6 * scale),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _dotStep(String label, bool active, double scale, {bool showTruck = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? (isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23))
            : const Color(0xFFCBCBCB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: showTruck
          ? Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 17 * scale,
            )
          : Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? const Color(0xFFCED3E6) : const Color(0xFF676767)),
                fontWeight: FontWeight.w700,
                fontSize: 14 * scale,
              ),
            ),
    );
  }

  Widget _stepLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: active
              ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFB06CFF)
                    : const Color(0xFFE67A23))
              : const Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _MapTabChip extends StatelessWidget {
  const _MapTabChip({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                        : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : (isDark ? const Color(0xFF111421) : Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * scale,
              color: selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF2A2A2A)),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
