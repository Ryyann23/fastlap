import 'package:flutter/foundation.dart';

import 'caxias_pois.dart';
import 'route_model.dart';

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

  List<AppRoute> get completedRoutes =>
      _routes.where((r) => r.status == RouteStatus.concluida || r.status == RouteStatus.cancelada).toList();

  /// Rotas não-finalizadas (ativas, pausadas, agendadas)
  List<AppRoute> get currentRoutes =>
      _routes.where((r) => r.status != RouteStatus.concluida && r.status != RouteStatus.cancelada).toList();

  /// Retorna a rota ativa atual (se existir)
  AppRoute? get activeRoute {
    final active = activeRoutes;
    return active.isEmpty ? null : active.first;
  }

  /// Cria uma nova rota
  AppRoute createRoute({
    required String name,
    required List<RoutePoint> selectedPoints,
    required RouteStatus status,
    DateTime? scheduledTime,
  }) {
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
      status: status,
      scheduledTime: scheduledTime,
    );

    _routes.insert(0, route);
    notifyListeners();
    return route;
  }

  /// Muda status de uma rota
  void updateStatus(String routeId, RouteStatus newStatus) {
    final route = _routes.firstWhere((r) => r.id == routeId);
    route.status = newStatus;
    if (newStatus == RouteStatus.concluida || newStatus == RouteStatus.cancelada) {
      route.completedAt = DateTime.now();
    }
    notifyListeners();
  }

  /// Remove uma rota
  void removeRoute(String routeId) {
    _routes.removeWhere((r) => r.id == routeId);
    notifyListeners();
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
