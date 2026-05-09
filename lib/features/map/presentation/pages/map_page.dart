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

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng _fallbackCenter = const LatLng(-4.8645, -43.3573);

  // Cache de polylines com rotas reais (chave = route.id)
  final Map<String, List<LatLng>> _routePolylines = {};
  late final AnimationController _routeAnimationController;
  String? _simulatedRouteId;
  bool _showSimulationControls = false;
  bool _isSimulationPaused = false;
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
    _routeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )
      ..addListener(_onSimulationTick)
      ..addStatusListener(_onSimulationStatusChanged);
    RouteService.instance.addListener(_onRoutesChanged);
    _loadRoutesAndGeometries();
  }

  @override
  void dispose() {
    RouteService.instance.removeListener(_onRoutesChanged);
    _routeAnimationController.dispose();
    super.dispose();
  }

  void _onSimulationTick() {
    if (mounted) setState(() {});
  }

  void _onSimulationStatusChanged(AnimationStatus status) {
    if (mounted && status == AnimationStatus.completed) {
      setState(() => _isSimulationPaused = false);
    }
  }

  void _onRoutesChanged() {
    if (mounted) {
      _clearSimulationIfRouteHidden();
      _fetchAllRouteGeometries();
      setState(() {});
    }
  }

  Future<void> _loadRoutesAndGeometries() async {
    try {
      await RouteService.instance.loadRoutes();
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }

    await _fetchAllRouteGeometries();
  }

  Future<void> _updateRouteStatus(
    AppRoute route,
    RouteStatus status,
  ) async {
    try {
      await RouteService.instance.updateStatus(route.id, status);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  void _clearSimulationIfRouteHidden() {
    if (_simulatedRouteId == null) return;

    final visibleRouteIds = _filteredRoutes().map((r) => r.id).toSet();
    if (visibleRouteIds.contains(_simulatedRouteId)) return;

    _routeAnimationController.stop();
    _routeAnimationController.value = 0;
    _simulatedRouteId = null;
    _showSimulationControls = false;
    _isSimulationPaused = false;
  }

  List<LatLng> _polylineFor(AppRoute route) {
    final cached = _routePolylines[route.id];
    if (cached != null && cached.length >= 2) return cached;
    return route.points.map((p) => p.latLng).toList();
  }

  double _routeProgressFor(AppRoute route) {
    if (_simulatedRouteId != route.id) return 0;
    return _routeAnimationController.value.clamp(0.0, 1.0).toDouble();
  }

  bool _hasSimulationControlsFor(AppRoute route) {
    return _simulatedRouteId == route.id && _showSimulationControls;
  }

  void _startRouteSimulation(AppRoute route) {
    if (_simulatedRouteId != route.id) {
      _simulatedRouteId = route.id;
      _routeAnimationController.value = 0;
    }

    final currentProgress = _routeAnimationController.value;
    final startFrom = currentProgress >= 1 ? 0.0 : currentProgress;

    _routeAnimationController
      ..duration = _simulationDurationFor(route)
      ..forward(from: startFrom);

    setState(() {
      _showSimulationControls = true;
      _isSimulationPaused = false;
    });
  }

  void _pauseOrResumeRouteSimulation(AppRoute route) {
    if (!_hasSimulationControlsFor(route)) return;
    if (_routeAnimationController.isCompleted) return;

    if (_routeAnimationController.isAnimating) {
      _routeAnimationController.stop();
      setState(() => _isSimulationPaused = true);
      return;
    }

    _routeAnimationController
      ..duration = _simulationDurationFor(route)
      ..forward(from: _routeAnimationController.value);
    setState(() => _isSimulationPaused = false);
  }

  void _cancelRouteSimulation(AppRoute route) {
    if (_simulatedRouteId != route.id) return;

    final polylinePoints = _polylineFor(route);
    final lastStopProgress = _lastReachedStopProgress(
      route,
      polylinePoints,
      _routeAnimationController.value,
    );

    _routeAnimationController.stop();
    _routeAnimationController.value = lastStopProgress;

    setState(() {
      _showSimulationControls = false;
      _isSimulationPaused = false;
    });
  }

  Future<void> _completeRouteSimulation(AppRoute route) async {
    if (_simulatedRouteId == route.id) {
      _routeAnimationController.stop();
      _routeAnimationController.value = 1;
    }
    await _updateRouteStatus(route, RouteStatus.concluida);
  }

  Duration _simulationDurationFor(AppRoute route) {
    final seconds = (10 + route.totalDistanceKm * 8).clamp(12.0, 55.0).round();
    return Duration(seconds: seconds);
  }

  _RouteProgressSlice _slicePolyline(List<LatLng> points, double progress) {
    if (points.isEmpty) {
      return _RouteProgressSlice(
        position: _fallbackCenter,
        completed: const [],
        remaining: const [],
      );
    }
    if (points.length == 1) {
      return _RouteProgressSlice(
        position: points.first,
        completed: [points.first],
        remaining: [points.first],
      );
    }

    final targetProgress = progress.clamp(0.0, 1.0).toDouble();
    final totalDistance = _pathDistanceMeters(points);
    if (totalDistance <= 0) {
      return _RouteProgressSlice(
        position: points.first,
        completed: [points.first],
        remaining: points,
      );
    }

    final targetDistance = totalDistance * targetProgress;
    if (targetDistance <= 0) {
      return _RouteProgressSlice(
        position: points.first,
        completed: [points.first],
        remaining: points,
      );
    }
    if (targetDistance >= totalDistance) {
      return _RouteProgressSlice(
        position: points.last,
        completed: points,
        remaining: [points.last],
      );
    }

    const distance = Distance();
    var traveled = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final segmentDistance =
          distance.as(LengthUnit.Meter, start, end).toDouble();
      if (segmentDistance <= 0) continue;

      final nextTraveled = traveled + segmentDistance;
      if (targetDistance <= nextTraveled) {
        final segmentProgress = ((targetDistance - traveled) / segmentDistance)
            .clamp(0.0, 1.0)
            .toDouble();
        final position = _interpolateLatLng(start, end, segmentProgress);
        return _RouteProgressSlice(
          position: position,
          completed: [...points.take(i + 1), position],
          remaining: [position, ...points.skip(i + 1)],
        );
      }

      traveled = nextTraveled;
    }

    return _RouteProgressSlice(
      position: points.last,
      completed: points,
      remaining: [points.last],
    );
  }

  double _pathDistanceMeters(List<LatLng> points) {
    if (points.length < 2) return 0;

    const distance = Distance();
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return total;
  }

  LatLng _interpolateLatLng(LatLng start, LatLng end, double progress) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * progress,
      start.longitude + (end.longitude - start.longitude) * progress,
    );
  }

  List<double> _stopProgressesFor(AppRoute route, List<LatLng> polyline) {
    if (route.points.isEmpty) return const [];

    final progresses = <double>[];
    var minProgress = 0.0;
    for (var i = 0; i < route.points.length; i++) {
      double progress;
      if (i == 0) {
        progress = 0;
      } else if (i == route.points.length - 1) {
        progress = 1;
      } else {
        progress = _projectedProgressOnPath(
          polyline,
          route.points[i].latLng,
          minProgress: minProgress,
        );
      }

      if (progress < minProgress) progress = minProgress;
      progresses.add(progress.clamp(0.0, 1.0).toDouble());
      minProgress = progress;
    }
    return progresses;
  }

  double _projectedProgressOnPath(
    List<LatLng> path,
    LatLng point, {
    required double minProgress,
  }) {
    if (path.length < 2) return minProgress.clamp(0.0, 1.0).toDouble();

    final totalDistance = _pathDistanceMeters(path);
    if (totalDistance <= 0) return minProgress.clamp(0.0, 1.0).toDouble();

    const distance = Distance();
    var bestDistance = double.infinity;
    var bestTraveled = totalDistance * minProgress;
    var traveled = 0.0;

    for (var i = 0; i < path.length - 1; i++) {
      final start = path[i];
      final end = path[i + 1];
      final segmentDistance =
          distance.as(LengthUnit.Meter, start, end).toDouble();
      if (segmentDistance <= 0) continue;

      final segmentEndProgress = (traveled + segmentDistance) / totalDistance;
      if (segmentEndProgress + 0.015 < minProgress) {
        traveled += segmentDistance;
        continue;
      }

      final projection = _projectionFactor(start, end, point);
      final projectedTraveled = traveled + segmentDistance * projection;
      final projectedProgress = projectedTraveled / totalDistance;
      if (projectedProgress + 0.015 < minProgress) {
        traveled += segmentDistance;
        continue;
      }

      final projectedPoint = _interpolateLatLng(start, end, projection);
      final distanceToPoint =
          distance.as(LengthUnit.Meter, projectedPoint, point).toDouble();
      if (distanceToPoint < bestDistance) {
        bestDistance = distanceToPoint;
        bestTraveled = projectedTraveled;
      }

      traveled += segmentDistance;
    }

    return (bestTraveled / totalDistance).clamp(0.0, 1.0).toDouble();
  }

  double _projectionFactor(LatLng start, LatLng end, LatLng point) {
    final dx = end.longitude - start.longitude;
    final dy = end.latitude - start.latitude;
    final denominator = dx * dx + dy * dy;
    if (denominator == 0) return 0;

    final px = point.longitude - start.longitude;
    final py = point.latitude - start.latitude;
    return ((px * dx + py * dy) / denominator).clamp(0.0, 1.0).toDouble();
  }

  double _lastReachedStopProgress(
    AppRoute route,
    List<LatLng> polyline,
    double progress,
  ) {
    final stopProgresses = _stopProgressesFor(route, polyline);
    var lastReached = 0.0;
    for (final stopProgress in stopProgresses) {
      if (progress + 0.015 >= stopProgress) {
        lastReached = stopProgress;
      }
    }
    return lastReached;
  }

  bool _isStopReached(int index, List<double> stopProgresses, double progress) {
    if (index == 0) return true;
    if (index >= stopProgresses.length) return false;
    return progress + 0.015 >= stopProgresses[index];
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
    final userMarkers = <Marker>[];
    final allPolylines = <Polyline>[];

    for (final route in routes) {
      // Usar rota real do OSRM se disponível, senão linha reta como fallback
      final polylinePoints = _polylineFor(route);
      final progress = _routeProgressFor(route);
      final pathSlice = _slicePolyline(polylinePoints, progress);
      final stopProgresses = _stopProgressesFor(route, polylinePoints);
      final routeColor =
          isDark ? const Color(0xFFFFA13B) : const Color(0xFFE67A23);
      final traveledColor =
          isDark ? const Color(0xFF7B8190) : const Color(0xFFBFC3C8);

      if (pathSlice.completed.length > 1 && progress > 0) {
        allPolylines.add(
          Polyline(
            points: pathSlice.completed,
            color: traveledColor.withValues(alpha: 0.72),
            strokeWidth: 5,
          ),
        );
      }

      if (pathSlice.remaining.length > 1) {
        allPolylines.add(
          Polyline(
            points: pathSlice.remaining,
            color: routeColor,
            strokeWidth: 5,
          ),
        );
      }

      for (var i = 0; i < route.points.length; i++) {
        final point = route.points[i];
        allMarkers.add(
          Marker(
            width: 34 * scale,
            height: 34 * scale,
            point: point.latLng,
            child: _stopMarker(
              point.label,
              reached: _isStopReached(i, stopProgresses, progress),
              scale: scale,
            ),
          ),
        );
      }

      userMarkers.add(
        Marker(
          width: 46 * scale,
          height: 46 * scale,
          point: pathSlice.position,
          child: _userRouteMarker(scale),
        ),
      );
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
                    if (allMarkers.isNotEmpty || userMarkers.isNotEmpty)
                      MarkerLayer(markers: [...allMarkers, ...userMarkers]),
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

  Widget _stopMarker(
    String label, {
    required bool reached,
    required double scale,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = reached
        ? (isDark ? const Color(0xFFFFA13B) : const Color(0xFFE67A23))
        : (isDark ? const Color(0xFF717783) : const Color(0xFFC8CDD3));

    return Container(
      decoration: BoxDecoration(
        color: color,
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
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14 * scale,
        ),
      ),
    );
  }

  Widget _userRouteMarker(double scale) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(23 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE67A23),
          width: 2 * scale,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(3 * scale),
        child: UserHeaderAvatar(
          radius: 18 * scale,
          lightBackgroundColor: const Color(0xFFFFA95B),
          darkBackgroundColor: const Color(0xFF8B4DDE),
        ),
      ),
    );
  }

  Widget _bottomRouteCard(AppRoute route, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final polylinePoints = _polylineFor(route);
    final progress = _routeProgressFor(route);
    final stopProgresses = _stopProgressesFor(route, polylinePoints);

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
                  _dotStep(
                    route.points[i].label,
                    scale,
                    reached: _isStopReached(i, stopProgresses, progress),
                  ),
                  if (i < route.points.length - 1)
                    _stepLine(
                      reached: _isStopReached(i + 1, stopProgresses, progress),
                    ),
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
        if (!_hasSimulationControlsFor(route)) {
          return _startRouteButton(route, scale);
        }

        return Row(
          children: [
            Expanded(
              child: _actionRow(
                _isSimulationPaused
                    ? Icons.play_circle_outline
                    : Icons.pause_circle_outline,
                _isSimulationPaused ? 'Retomar' : 'Pausar',
                scale,
                onTap: () => _pauseOrResumeRouteSimulation(route),
              ),
            ),
            Container(
                width: 1,
                height: 24 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
              child: _actionRow(
                Icons.cancel_outlined,
                'Cancelar',
                scale,
                onTap: () => _cancelRouteSimulation(route),
              ),
            ),
            Container(
                width: 1,
                height: 24 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
              child: _actionRow(
                Icons.check_circle_outline,
                'Concluir',
                scale,
                onTap: () => _completeRouteSimulation(route),
              ),
            ),
          ],
        );
      case RouteStatus.pausada:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.play_circle_outline, 'Retomar', scale,
                    onTap: () {
              _updateRouteStatus(route, RouteStatus.ativa);
            })),
            Container(
                width: 1,
                height: 24 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.cancel_outlined, 'Cancelar', scale,
                    onTap: () {
              _updateRouteStatus(route, RouteStatus.cancelada);
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

  Widget _startRouteButton(AppRoute route, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      child: GestureDetector(
        onTap: () => _startRouteSimulation(route),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22 * scale),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A00), Color(0xFFE86618)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 23 * scale,
              ),
              SizedBox(width: 6 * scale),
              Text(
                'Começar rota',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dotStep(String label, double scale, {required bool reached}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: reached
            ? (isDark ? const Color(0xFFFFA13B) : const Color(0xFFE67A23))
            : (isDark ? const Color(0xFF717783) : const Color(0xFFC8CDD3)),
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

  Widget _stepLine({required bool reached}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: reached
              ? (isDark ? const Color(0xFFFFA13B) : const Color(0xFFE67A23))
              : (isDark ? const Color(0xFF717783) : const Color(0xFFC8CDD3)),
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
            color: isDark ? const Color(0xFFFFA13B) : const Color(0xFFC7742A),
            size: 21 * scale,
          ),
          SizedBox(width: 6 * scale),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteProgressSlice {
  const _RouteProgressSlice({
    required this.position,
    required this.completed,
    required this.remaining,
  });

  final LatLng position;
  final List<LatLng> completed;
  final List<LatLng> remaining;
}
