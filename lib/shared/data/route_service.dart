import 'package:flutter/foundation.dart';

import 'caxias_pois.dart';
import 'route_model.dart';
import 'audit_log_service.dart';

/// Serviço singleton para gerenciar rotas do app
class RouteService extends ChangeNotifier {
  RouteService._();
  static final RouteService _instance = RouteService._();
  static RouteService get instance => _instance;

  final List<AppRoute> _routes = [];
  int _nextId = 1;

  List<AppRoute> get routes => List.unmodifiable(_routes);

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

  /// Rotas não-finalizadas (ativas, pausadas, agendadas)
  List<AppRoute> get currentRoutes => _routes
      .where((r) =>
          r.status != RouteStatus.concluida &&
          r.status != RouteStatus.cancelada)
      .toList();

  /// Retorna a rota ativa atual (se existir)
  AppRoute? get activeRoute {
    final active = activeRoutes;
    return active.isEmpty ? null : active.first;
  }

  /// Cria uma nova rota
  /// Nota: O status é determinado automaticamente:
  /// - Se existe uma rota ativa ou pausada, a nova rota será 'agendada'
  /// - Caso contrário, será 'ativa'
  AppRoute createRoute({
    required String name,
    required List<RoutePoint> selectedPoints,
    String? vehicleId,
    DateTime? scheduledTime,
  }) {
    // Determina automaticamente o status baseado em rotas existentes
    final hasActiveOrPausedRoute = _routes.any(
      (r) => r.status == RouteStatus.ativa || r.status == RouteStatus.pausada,
    );
    final statusForNewRoute =
        hasActiveOrPausedRoute ? RouteStatus.agendada : RouteStatus.ativa;

    // Ponto A é sempre UniFacema
    final start = CaxiasPOI.startPoint.copyWith(label: 'A');
    final labels = ['B', 'C', 'D', 'E'];
    final labeledPoints = <RoutePoint>[start];

    for (var i = 0; i < selectedPoints.length && i < 4; i++) {
      labeledPoints.add(selectedPoints[i].copyWith(label: labels[i]));
    }

    final route = AppRoute(
      id: '${_nextId++}',
      name: name,
      points: labeledPoints,
      status: statusForNewRoute,
      vehicleId: vehicleId,
      scheduledTime: scheduledTime,
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

  /// Muda status de uma rota
  void updateStatus(String routeId, RouteStatus newStatus) {
    final route = _routes.firstWhere((r) => r.id == routeId);
    final previousStatus = route.status;
    route.status = newStatus;
    if (newStatus == RouteStatus.concluida ||
        newStatus == RouteStatus.cancelada) {
      route.completedAt = DateTime.now();
    }
    notifyListeners();

    AuditActionType action = AuditActionType.updateRoute;
    String description = 'Rota atualizada: ${route.name}';

    if (newStatus == RouteStatus.agendada) {
      action = AuditActionType.scheduleRoute;
      description = 'Rota agendada: ${route.name}';
    } else if (newStatus == RouteStatus.concluida) {
      action = AuditActionType.concludeRoute;
      description = 'Rota concluída: ${route.name}';
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

  /// Remove uma rota
  void removeRoute(String routeId) {
    final routeIndex = _routes.indexWhere((r) => r.id == routeId);
    if (routeIndex == -1) return;
    final route = _routes[routeIndex];

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

  /// Total de KMs de rotas concluídas hoje
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
}
