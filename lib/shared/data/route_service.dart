import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'api_client.dart';
import 'audit_log_service.dart';
import 'caxias_pois.dart';
import 'route_model.dart';

/// Servico singleton para gerenciar rotas do app usando o backend FastLap.
class RouteService extends ChangeNotifier {
  RouteService._();
  static final RouteService _instance = RouteService._();
  static RouteService get instance => _instance;

  final ApiClient _api = ApiClient.instance;
  final List<AppRoute> _routes = [];
  bool _loaded = false;
  bool _loading = false;

  List<AppRoute> get routes => List.unmodifiable(_routes);
  bool get isLoading => _loading;

  List<AppRoute> get activeRoutes =>
      _routes.where((r) => r.status == RouteStatus.ativa).toList();

  List<AppRoute> get pausedRoutes =>
      _routes.where((r) => r.status == RouteStatus.pausada).toList();

  List<AppRoute> get scheduledRoutes =>
      _routes.where((r) => r.status == RouteStatus.agendada).toList();

  List<AppRoute> get completedRoutes => _routes
      .where((r) =>
          r.status == RouteStatus.concluida ||
          r.status == RouteStatus.cancelada)
      .toList();

  /// Rotas nao-finalizadas (ativas, pausadas, agendadas).
  List<AppRoute> get currentRoutes => _routes
      .where((r) =>
          r.status != RouteStatus.concluida &&
          r.status != RouteStatus.cancelada)
      .toList();

  /// Retorna a rota ativa atual (se existir).
  AppRoute? get activeRoute {
    final active = activeRoutes;
    return active.isEmpty ? null : active.first;
  }

  Future<void> loadRoutes({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;

    _loading = true;
    notifyListeners();

    try {
      final routesData = await _api.get('/api/routes');
      if (routesData is! List) {
        throw const ApiException('Resposta invalida ao listar rotas.');
      }

      final deliveriesByRoute = await _loadDeliveriesByRoute();
      final loadedRoutes = <AppRoute>[];

      for (final item in routesData.whereType<Map<String, dynamic>>()) {
        final id = (item['id'] ?? '').toString();
        Map<String, dynamic> routeData = item;

        if (id.isNotEmpty) {
          try {
            final detail = await _api.get('/api/routes/$id');
            if (detail is Map<String, dynamic>) {
              routeData = detail;
            }
          } catch (_) {
            routeData = item;
          }
        }

        loadedRoutes.add(
          _routeFromApi(
            routeData,
            delivery: deliveriesByRoute[id],
          ),
        );
      }

      _routes
        ..clear()
        ..addAll(loadedRoutes);
      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadDeliveriesByRoute() async {
    try {
      final data = await _api.get('/api/stats/history?limit=200');
      if (data is! List) return {};

      final byRoute = <String, Map<String, dynamic>>{};
      for (final item in data.whereType<Map<String, dynamic>>()) {
        final routeId = item['route_id']?.toString();
        if (routeId == null || routeId.isEmpty) continue;

        final existing = byRoute[routeId];
        if (existing == null ||
            _deliveryDate(item).isAfter(_deliveryDate(existing))) {
          byRoute[routeId] = item;
        }
      }
      return byRoute;
    } catch (_) {
      return {};
    }
  }

  /// Cria uma nova rota no backend.
  /// Nota: o app ainda calcula automaticamente o status visual:
  /// - se existe rota ativa ou pausada, a nova rota aparece como agendada;
  /// - caso contrario, aparece como ativa.
  /// O backend atual persiste esse estado como entrega "in_progress".
  Future<AppRoute> createRoute({
    required String name,
    required List<RoutePoint> selectedPoints,
    String? vehicleId,
    DateTime? scheduledTime,
  }) async {
    final hasActiveOrPausedRoute = _routes.any(
      (r) => r.status == RouteStatus.ativa || r.status == RouteStatus.pausada,
    );
    final statusForNewRoute =
        hasActiveOrPausedRoute ? RouteStatus.agendada : RouteStatus.ativa;

    final labeledPoints = _labeledPoints(selectedPoints);
    final draftRoute = AppRoute(
      id: 'draft',
      name: name,
      points: labeledPoints,
      status: statusForNewRoute,
      vehicleId: vehicleId,
      scheduledTime: scheduledTime,
    );

    final start = labeledPoints.first;
    final end = labeledPoints.last;
    final distance = draftRoute.totalDistanceKm;
    final duration = _estimatedMinutesFor(draftRoute);

    final data = await _api.post(
      '/api/routes',
      body: {
        'name': name,
        'vehicleId': vehicleId,
        'startAddress': start.name,
        'endAddress': end.name,
        'distance': distance,
        'estimatedTime': duration,
        'startLat': start.latLng.latitude,
        'startLng': start.latLng.longitude,
        'endLat': end.latLng.latitude,
        'endLng': end.latLng.longitude,
      },
    );

    final routeData = data is Map<String, dynamic> ? data['route'] : null;
    if (routeData is! Map<String, dynamic>) {
      throw const ApiException('Resposta invalida ao criar rota.');
    }

    final routeId = (routeData['id'] ?? '').toString();
    if (routeId.isEmpty) {
      throw const ApiException('Backend nao retornou o ID da rota.');
    }

    await _saveRoutePois(routeId, labeledPoints.skip(1).toList());
    final deliveryId = await _createDeliveryFor(
      routeId: routeId,
      status: _deliveryStatusFor(statusForNewRoute),
      distance: distance,
      duration: duration,
    );

    final route = AppRoute(
      id: routeId,
      name: (routeData['name'] ?? name).toString(),
      points: labeledPoints,
      status: statusForNewRoute,
      vehicleId: routeData['vehicle_id']?.toString() ?? vehicleId,
      deliveryId: deliveryId,
      scheduledTime: scheduledTime,
      createdAt: _parseDate(routeData['created_at']) ?? DateTime.now(),
    );

    _routes.insert(0, route);
    notifyListeners();

    final isScheduled = statusForNewRoute == RouteStatus.agendada;
    AuditLogService.instance.addEntry(
      action: isScheduled
          ? AuditActionType.scheduleRoute
          : AuditActionType.createRoute,
      description: isScheduled
          ? 'Rota agendada: ${route.name}'
          : 'Rota criada: ${route.name}',
      entityType: 'route',
      entityId: route.id,
      metadata: {
        'status': route.status.name,
        'distanceKm': route.totalDistanceKm,
        'points': route.points.map((p) => p.label).toList(),
        'scheduledTime': route.scheduledTime?.toIso8601String(),
      },
    );

    return route;
  }

  Future<void> _saveRoutePois(
    String routeId,
    List<RoutePoint> destinationPoints,
  ) async {
    for (var i = 0; i < destinationPoints.length; i++) {
      final point = destinationPoints[i];
      final poiData = await _api.post(
        '/api/pois',
        body: {
          'name': point.name,
          'category': 'delivery',
          'address': point.name,
          'latitude': point.latLng.latitude,
          'longitude': point.latLng.longitude,
          'notes': 'Criado pelo app FastLap',
        },
      );

      final poi = poiData is Map<String, dynamic> ? poiData['poi'] : null;
      final poiId = poi is Map<String, dynamic> ? poi['id']?.toString() : null;
      if (poiId == null || poiId.isEmpty) {
        throw const ApiException('Resposta invalida ao criar ponto da rota.');
      }

      await _api.post(
        '/api/routes/$routeId/pois',
        body: {
          'poiId': poiId,
          'orderIndex': i,
        },
      );
    }
  }

  /// Muda status de uma rota.
  Future<void> updateStatus(String routeId, RouteStatus newStatus) async {
    final route = _routes.firstWhere((r) => r.id == routeId);
    final previousStatus = route.status;
    final deliveryStatus = _deliveryStatusFor(newStatus);

    if (route.deliveryId == null || route.deliveryId!.isEmpty) {
      route.deliveryId = await _createDeliveryFor(
        routeId: route.id,
        status: deliveryStatus,
        distance: route.totalDistanceKm,
        duration: _estimatedMinutesFor(route),
      );
    } else {
      await _api.put(
        '/api/stats/deliveries/${route.deliveryId}',
        body: {'status': deliveryStatus},
      );
    }

    route.status = newStatus;
    if (newStatus == RouteStatus.concluida ||
        newStatus == RouteStatus.cancelada) {
      route.completedAt = DateTime.now();
    } else {
      route.completedAt = null;
    }
    notifyListeners();

    AuditActionType action = AuditActionType.updateRoute;
    String description = 'Rota atualizada: ${route.name}';

    if (newStatus == RouteStatus.agendada) {
      action = AuditActionType.scheduleRoute;
      description = 'Rota agendada: ${route.name}';
    } else if (newStatus == RouteStatus.concluida) {
      action = AuditActionType.concludeRoute;
      description = 'Rota concluida: ${route.name}';
    } else if (newStatus == RouteStatus.cancelada) {
      action = AuditActionType.cancelRoute;
      description = 'Rota cancelada: ${route.name}';
    }

    AuditLogService.instance.addEntry(
      action: action,
      description: description,
      entityType: 'route',
      entityId: route.id,
      metadata: {
        'previousStatus': previousStatus.name,
        'newStatus': newStatus.name,
      },
    );
  }

  /// Remove uma rota.
  Future<void> removeRoute(String routeId) async {
    final routeIndex = _routes.indexWhere((r) => r.id == routeId);
    if (routeIndex == -1) return;
    final route = _routes[routeIndex];

    await _api.delete('/api/routes/$routeId');

    _routes.removeAt(routeIndex);
    notifyListeners();

    AuditLogService.instance.addEntry(
      action: AuditActionType.deleteRoute,
      description: 'Rota removida: ${route.name}',
      entityType: 'route',
      entityId: route.id,
      metadata: {
        'status': route.status.name,
        'distanceKm': route.totalDistanceKm,
      },
    );
  }

  /// Total de km de rotas concluidas hoje.
  double get todayKm {
    final now = DateTime.now();
    return _routes
        .where((r) =>
            r.status == RouteStatus.concluida &&
            r.completedAt != null &&
            r.completedAt!.day == now.day &&
            r.completedAt!.month == now.month &&
            r.completedAt!.year == now.year)
        .fold(0.0, (sum, r) => sum + r.totalDistanceKm);
  }

  int get todayCompleted {
    final now = DateTime.now();
    return _routes
        .where((r) =>
            r.status == RouteStatus.concluida &&
            r.completedAt != null &&
            r.completedAt!.day == now.day &&
            r.completedAt!.month == now.month &&
            r.completedAt!.year == now.year)
        .length;
  }

  void clear() {
    _routes.clear();
    _loaded = false;
    notifyListeners();
  }

  List<RoutePoint> _labeledPoints(List<RoutePoint> selectedPoints) {
    final start = CaxiasPOI.startPoint.copyWith(label: 'A');
    final labels = ['B', 'C', 'D', 'E'];
    final labeledPoints = <RoutePoint>[start];

    for (var i = 0; i < selectedPoints.length && i < 4; i++) {
      labeledPoints.add(selectedPoints[i].copyWith(label: labels[i]));
    }

    return labeledPoints;
  }

  AppRoute _routeFromApi(
    Map<String, dynamic> map, {
    Map<String, dynamic>? delivery,
  }) {
    final id = (map['id'] ?? '').toString();
    final points = <RoutePoint>[
      RoutePoint(
        id: '$id-start',
        name: (map['start_address'] ?? CaxiasPOI.startPoint.name).toString(),
        latLng: _latLngFrom(
          map['start_lat'],
          map['start_lng'],
          fallback: CaxiasPOI.startPoint.latLng,
        ),
        label: 'A',
      ),
    ];

    final pois = map['pois'];
    if (pois is List && pois.isNotEmpty) {
      final orderedPois = pois.whereType<Map<String, dynamic>>().toList()
        ..sort((a, b) => _toInt(a['order_index']).compareTo(
              _toInt(b['order_index']),
            ));

      final labels = ['B', 'C', 'D', 'E'];
      for (var i = 0; i < orderedPois.length && i < labels.length; i++) {
        final poi = orderedPois[i];
        points.add(
          RoutePoint(
            id: (poi['id'] ?? '$id-poi-$i').toString(),
            name: (poi['name'] ?? '').toString(),
            latLng: _latLngFrom(
              poi['latitude'],
              poi['longitude'],
              fallback: points.first.latLng,
            ),
            label: labels[i],
          ),
        );
      }
    }

    if (points.length == 1) {
      points.add(
        RoutePoint(
          id: '$id-end',
          name: (map['end_address'] ?? 'Destino').toString(),
          latLng: _latLngFrom(
            map['end_lat'],
            map['end_lng'],
            fallback: points.first.latLng,
          ),
          label: 'B',
        ),
      );
    }

    return AppRoute(
      id: id,
      name: (map['name'] ?? 'Rota').toString(),
      points: points,
      status: _routeStatusFromDelivery(delivery),
      vehicleId: map['vehicle_id']?.toString(),
      deliveryId: delivery?['id']?.toString(),
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
      completedAt: _parseDate(delivery?['completed_at']),
    );
  }

  Future<String?> _createDeliveryFor({
    required String routeId,
    required String status,
    required double distance,
    required int duration,
  }) async {
    final data = await _api.post(
      '/api/stats/deliveries',
      body: {
        'routeId': routeId,
        'status': status,
        'distance': distance,
        'duration': duration,
      },
    );

    final delivery = data is Map<String, dynamic> ? data['delivery'] : null;
    return delivery is Map<String, dynamic> ? delivery['id']?.toString() : null;
  }

  String _deliveryStatusFor(RouteStatus status) {
    switch (status) {
      case RouteStatus.concluida:
        return 'completed';
      case RouteStatus.cancelada:
        return 'cancelled';
      case RouteStatus.ativa:
      case RouteStatus.pausada:
      case RouteStatus.agendada:
        return 'in_progress';
    }
  }

  RouteStatus _routeStatusFromDelivery(Map<String, dynamic>? delivery) {
    final status = delivery?['status']?.toString();
    return switch (status) {
      'completed' => RouteStatus.concluida,
      'cancelled' => RouteStatus.cancelada,
      _ => RouteStatus.ativa,
    };
  }

  int _estimatedMinutesFor(AppRoute route) {
    final vehicle = route.vehicle;
    final minutes = vehicle != null
        ? vehicle.calculateTravelTimeMinutes(route.totalDistanceKm)
        : (route.totalDistanceKm / 30) * 60;
    return minutes.clamp(1, 24 * 60).round();
  }

  LatLng _latLngFrom(dynamic lat, dynamic lng, {required LatLng fallback}) {
    final latitude = _toDoubleOrNull(lat);
    final longitude = _toDoubleOrNull(lng);
    if (latitude == null || longitude == null) return fallback;
    return LatLng(latitude, longitude);
  }

  double? _toDoubleOrNull(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  DateTime _deliveryDate(Map<String, dynamic> delivery) {
    return _parseDate(delivery['completed_at']) ??
        _parseDate(delivery['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
