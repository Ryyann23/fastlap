import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/data/route_model.dart';
import '../../../../shared/data/route_service.dart';
import '../../../../shared/data/routing_service.dart';
import '../../../../shared/utils/app_responsive.dart';
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

  // Cache de polylines com rotas reais (chave = route.id)
  final Map<String, List<LatLng>> _routePolylines = {};
  bool _loadingRoutes = false;

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
    RouteService.instance.addListener(_onRoutesChanged);
    _fetchAllRouteGeometries();
  }

  @override
  void dispose() {
    RouteService.instance.removeListener(_onRoutesChanged);
    super.dispose();
  }

  void _onRoutesChanged() {
    if (mounted) {
      _fetchAllRouteGeometries();
      setState(() {});
    }
  }

  Future<void> _fetchAllRouteGeometries() async {
    final routes = _filteredRoutes();
    if (routes.isEmpty) return;

    // Verifica se há rotas novas que ainda não foram buscadas
    final needsFetch =
        routes.where((r) => !_routePolylines.containsKey(r.id)).toList();
    if (needsFetch.isEmpty) return;

    setState(() => _loadingRoutes = true);

    for (final route in needsFetch) {
      final waypoints = route.points.map((p) => p.latLng).toList();
      final realPath = await RoutingService.instance.getRoute(waypoints);
      if (mounted) {
        _routePolylines[route.id] = realPath;
      }
    }

    if (mounted) {
      setState(() => _loadingRoutes = false);
    }
  }

  List<AppRoute> _filteredRoutes() {
    final service = RouteService.instance;
    return service.routes.where((r) => r.status == RouteStatus.ativa).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = AppResponsive.scale(context);
    final horizontalPadding = AppResponsive.pagePadding(context);
    final dateText = _formatBrasiliaDate();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];

    final routes = _filteredRoutes();
    final activeRoute = routes.isNotEmpty ? routes.first : null;

    // Juntar todos os pontos de todas as rotas filtradas para exibir no mapa
    final allMarkers = <Marker>[];
    final allPolylines = <Polyline>[];

    for (final route in routes) {
      // Usar rota real do OSRM se disponível, senão linha reta como fallback
      final polylinePoints = _routePolylines[route.id] ??
          route.points.map((p) => p.latLng).toList();

      allPolylines.add(
        Polyline(
          points: polylinePoints,
          color: route.status == RouteStatus.ativa
              ? (isDark ? const Color(0xFFB06CFF) : const Color(0xFFDB7B2C))
              : route.status == RouteStatus.pausada
                  ? const Color(0xFFE04A4A)
                  : const Color(0xFF888888),
          strokeWidth: 5,
        ),
      );

      for (final point in route.points) {
        allMarkers.add(
          Marker(
            width: 34,
            height: 34,
            point: point.latLng,
            child: _stopMarker(point.label),
          ),
        );
      }
    }

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
                        child: Image.asset('src/img/logo.png',
                            fit: BoxFit.contain),
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
                      fontSize: 36 * scale,
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
                    initialCenter: _fallbackCenter,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.fastlap.app',
                    ),
                    if (allPolylines.isNotEmpty)
                      PolylineLayer(polylines: allPolylines),
                    if (allMarkers.isNotEmpty) MarkerLayer(markers: allMarkers),
                  ],
                ),

                // Card de rota ativa na parte inferior
                if (activeRoute != null)
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 12 * scale,
                    child: _bottomRouteCard(activeRoute, scale),
                  ),

                // Indicador de carregamento de rotas
                if (_loadingRoutes)
                  Positioned(
                    top: 60 * scale,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1D2A).withValues(alpha: 0.92)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16 * scale,
                              height: 16 * scale,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? const Color(0xFFB06CFF)
                                    : const Color(0xFFE67A23),
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Calculando rota...',
                              style: TextStyle(
                                fontSize: 13 * scale,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Mensagem quando não há rotas
                if (routes.isEmpty)
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 12 * scale,
                    child: Container(
                      padding: EdgeInsets.all(16 * scale),
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
                          Icon(
                            Icons.alt_route_rounded,
                            size: 40 * scale,
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            'Nenhuma rota ativa para exibir',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15 * scale,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                    builder: (_) => const RoutesPage()),
                              );
                            },
                            child: Text(
                              'Ir para Rotas',
                              style: TextStyle(
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFB06CFF)
                                    : const Color(0xFFE67A23),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _bottomRouteCard(AppRoute route, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    switch (route.status) {
      case RouteStatus.ativa:
        statusBgColor = const Color(0xFFCFF0D6);
        statusTextColor = const Color(0xFF267A3B);
        statusLabel = 'Ativa';
      case RouteStatus.pausada:
        statusBgColor = const Color(0xFFFFD9CC);
        statusTextColor = const Color(0xFF9A4A2D);
        statusLabel = 'Pausada';
      case RouteStatus.agendada:
        statusBgColor = const Color(0xFFDDE4EC);
        statusTextColor = const Color(0xFF3A4653);
        statusLabel = 'Agendada';
      case RouteStatus.concluida:
        statusBgColor = const Color(0xFFD4E8D9);
        statusTextColor = const Color(0xFF1B6B2E);
        statusLabel = 'Concluída';
      case RouteStatus.cancelada:
        statusBgColor = const Color(0xFFFFD6D6);
        statusTextColor = const Color(0xFFA93333);
        statusLabel = 'Cancelada';
    }

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
                  route.name,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),

          // Pontos timeline
          SizedBox(
            height: 30 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < route.points.length; i++) ...[
                  _dotStep(route.points[i].label, scale),
                  if (i < route.points.length - 1) _stepLine(),
                ],
              ],
            ),
          ),
          SizedBox(height: 8 * scale),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Est. ${route.estimatedTime} | ${route.totalDistanceKm.toStringAsFixed(1)} km',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontSize: 15 * scale,
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
              height: 1,
              color:
                  isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),

          // Ações
          SizedBox(
            height: 48 * scale,
            child: _buildMapActions(route, scale),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActions(AppRoute route, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (route.status) {
      case RouteStatus.ativa:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.pause_circle_outline, 'Pausar', scale,
                    onTap: () {
              RouteService.instance.updateStatus(route.id, RouteStatus.pausada);
            })),
            Container(
                width: 1,
                height: 24 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.check_circle_outline, 'Concluir', scale,
                    onTap: () {
              RouteService.instance
                  .updateStatus(route.id, RouteStatus.concluida);
            })),
          ],
        );
      case RouteStatus.pausada:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.play_circle_outline, 'Retomar', scale,
                    onTap: () {
              RouteService.instance.updateStatus(route.id, RouteStatus.ativa);
            })),
            Container(
                width: 1,
                height: 24 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.cancel_outlined, 'Cancelar', scale,
                    onTap: () {
              RouteService.instance
                  .updateStatus(route.id, RouteStatus.cancelada);
            })),
          ],
        );
      default:
        return Row(
          children: [
            Expanded(
                child: _actionRow(
                    Icons.receipt_long_rounded, 'Ver Detalhes', scale,
                    onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const RoutesPage()),
              );
            })),
          ],
        );
    }
  }

  Widget _dotStep(String label, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14 * scale,
        ),
      ),
    );
  }

  Widget _stepLine() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, double scale,
      {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Row(
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
      ),
    );
  }
}
