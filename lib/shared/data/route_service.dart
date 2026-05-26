import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'audit_log_service.dart';
import 'caxias_pois.dart';
import 'local_app_store.dart';
import 'route_model.dart';

/// Servico singleton para gerenciar rotas salvas localmente no app.
class RouteService extends ChangeNotifier {
  RouteService._();
  static final RouteService _instance = RouteService._();
  static RouteService get instance => _instance;

  static const Uuid _uuid = Uuid();

  final LocalAppStore _store = LocalAppStore.instance;
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
      final loadedRoutes = (await _store.getUserCollection('routesByUser'))
          .map(AppRoute.fromMap)
          .where((route) => route.points.length >= 2)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _routes
        ..clear()
        ..addAll(loadedRoutes);
      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cria uma nova rota local.
  /// Se ja existe rota ativa ou pausada, a nova rota entra como agendada.
  Future<AppRoute> createRoute({
    required String name,
    required List<RoutePoint> selectedPoints,
    String? vehicleId,
    DateTime? scheduledTime,
  }) async {
    await loadRoutes();

    final hasActiveOrPausedRoute = _routes.any(
      (r) => r.status == RouteStatus.ativa || r.status == RouteStatus.pausada,
    );
    final statusForNewRoute =
        hasActiveOrPausedRoute ? RouteStatus.agendada : RouteStatus.ativa;

    final labeledPoints = _labeledPoints(selectedPoints);
    final route = AppRoute(
      id: _uuid.v4(),
      name: name,
      points: labeledPoints,
      status: statusForNewRoute,
      vehicleId: vehicleId,
      deliveryId: _uuid.v4(),
      scheduledTime: scheduledTime,
      createdAt: DateTime.now(),
    );

    _routes.insert(0, route);
    await _saveRoutes();
    notifyListeners();

    final isScheduled = statusForNewRoute == RouteStatus.agendada;
    await AuditLogService.instance.addEntry(
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
        'durationMinutes': _estimatedMinutesFor(route),
        'points': route.points.map((p) => p.label).toList(),
        'scheduledTime': route.scheduledTime?.toIso8601String(),
      },
    );

    return route;
  }

  /// Muda status de uma rota.
  Future<void> updateStatus(String routeId, RouteStatus newStatus) async {
    await loadRoutes();

    final route = _routes.firstWhere((r) => r.id == routeId);
    final previousStatus = route.status;

    route.deliveryId ??= _uuid.v4();
    route.status = newStatus;
    if (newStatus == RouteStatus.concluida ||
        newStatus == RouteStatus.cancelada) {
      route.completedAt = DateTime.now();
    } else {
      route.completedAt = null;
    }

    await _saveRoutes();
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

    await AuditLogService.instance.addEntry(
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
    await loadRoutes();

    final routeIndex = _routes.indexWhere((r) => r.id == routeId);
    if (routeIndex == -1) return;
    final route = _routes[routeIndex];

    _routes.removeAt(routeIndex);
    await _saveRoutes();
    notifyListeners();

    await AuditLogService.instance.addEntry(
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

  int _estimatedMinutesFor(AppRoute route) {
    final vehicle = route.vehicle;
    final minutes = vehicle != null
        ? vehicle.calculateTravelTimeMinutes(route.totalDistanceKm)
        : (route.totalDistanceKm / 30) * 60;
    return minutes.clamp(1, 24 * 60).round();
  }

  Future<void> _saveRoutes() async {
    await _store.saveUserCollection(
      'routesByUser',
      _routes.map((route) => route.toMap()).toList(),
    );
  }
}
