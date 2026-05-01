import 'package:flutter/foundation.dart';
import 'caxias_pois.dart';
import 'route_model.dart';
import 'api_service.dart';

/// Serviço singleton para gerenciar rotas do app
class RouteService extends ChangeNotifier {
  RouteService._();
  static final RouteService _instance = RouteService._();
  static RouteService get instance => _instance;

  final List<AppRoute> _routes = [];
  int _nextId = 1;
  bool _isLoading = false;
  String? _error;

  List<AppRoute> get routes => List.unmodifiable(_routes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppRoute> get activeRoutes =>
      _routes.where((r) => r.status == RouteStatus.ativa).toList();

  List<AppRoute> get pausedRoutes =>
      _routes.where((r) => r.status == RouteStatus.pausada).toList();

  List<AppRoute> get scheduledRoutes =>
      _routes.where((r) => r.status == RouteStatus.agendada).toList();

  List<AppRoute> get completedRoutes =>
      _routes.where((r) => r.status == RouteStatus.concluida || r.status == RouteStatus.cancelada).toList();

  /// Rotas não-finalizadas
  List<AppRoute> get currentRoutes =>
      _routes.where((r) => r.status != RouteStatus.concluida && r.status != RouteStatus.cancelada).toList();

  /// Rota ativa atual
  AppRoute? get activeRoute {
    final active = activeRoutes;
    return active.isEmpty ? null : active.first;
  }

  //==============================//
  //   createRoute (local)       //
  //==============================//
  AppRoute createRoute({
    required String name,
    required List<RoutePoint> selectedPoints,
    RouteStatus status = RouteStatus.ativa,
    String? vehicleId,
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
      vehicleId: vehicleId,
      scheduledTime: scheduledTime,
    );

    _routes.insert(0, route);
    notifyListeners();
    return route;
  }

  //==============================//
  //   loadRoutes - BACKEND      //
  //==============================//
  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getAuthToken();
      if (token != null) {
        final response = await ApiService.get('/routes/', token: token);

        if (response.ok && response.dataAsList != null) {
          // Não converter do backend por agora, manter rotas locais
        }
      }
    } catch (e) {
      _error = 'Erro ao carregar rotas';
    }

    _isLoading = false;
    notifyListeners();
  }

  //==============================//
  //  createRouteApi - BACKEND       //
  //==============================//
  Future<AppRoute?> createRouteApi({
    required String name,
    required List<RoutePoint> selectedPoints,
    RouteStatus status = RouteStatus.ativa,
    String? vehicleId,
    DateTime? scheduledTime,
    String? startAddress,
    String? endAddress,
    double? distance,
    int? estimatedTime,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
  }) async {
    // Ponto A é sempre UniFacema
    final start = CaxiasPOI.startPoint.copyWith(label: 'A');
    final labels = ['B', 'C', 'D', 'E'];
    final labeledPoints = <RoutePoint>[start];

    for (var i = 0; i < selectedPoints.length && i < 4; i++) {
      labeledPoints.add(selectedPoints[i].copyWith(label: labels[i]));
    }

    final routeData = {
      'name': name,
      'vehicleId': vehicleId,
      'startAddress': startAddress ?? 'UniFacema',
      'endAddress': endAddress ?? labeledPoints.last.name,
      'distance': distance ?? 0.0,
      'estimatedTime': estimatedTime ?? 0,
      'startLat': startLat ?? start.latLng.latitude,
      'startLng': startLng ?? start.latLng.longitude,
      'endLat': endLat ?? labeledPoints.last.latLng.latitude,
      'endLng': endLng ?? labeledPoints.last.latLng.longitude,
    };

    final token = await ApiService.getAuthToken();
    AppRoute? newRoute;

    if (token != null) {
      final response = await ApiService.post(
        '/routes/',
        body: routeData,
        token: token,
      );

      if (response.ok) {
        // Criar rota local após sucesso no backend
        newRoute = createRoute(
          name: name,
          selectedPoints: selectedPoints,
          status: status,
          vehicleId: vehicleId,
          scheduledTime: scheduledTime,
        );
      }
    }

    // Fallback: criar local
    newRoute ??= createRoute(
      name: name,
      selectedPoints: selectedPoints,
      status: status,
      vehicleId: vehicleId,
      scheduledTime: scheduledTime,
    );

    return newRoute;
  }

  //==============================//
  //   updateStatus (local)       //
  //==============================//
  void updateStatus(String routeId, RouteStatus newStatus) {
    final route = _routes.firstWhere((r) => r.id == routeId);
    route.status = newStatus;
    if (newStatus == RouteStatus.concluida || newStatus == RouteStatus.cancelada) {
      route.completedAt = DateTime.now();
    }
    notifyListeners();
  }

  //==============================//
  //   removeRoute (local)      //
  //==============================//
  void removeRoute(String routeId) {
    _routes.removeWhere((r) => r.id == routeId);
    notifyListeners();
  }

  //==============================//
  //   deleteRouteApi - BACKEND     //
  //==============================//
  Future<bool> deleteRouteApi(String routeId) async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      await ApiService.delete('/routes/$routeId', token: token);
    }

    _routes.removeWhere((r) => r.id == routeId);
    notifyListeners();
    return true;
  }

  //==============================//
  //   getRouteHistory - BACKEND  //
  //==============================//
  Future<List<AppRoute>> getRouteHistory() async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      final response = await ApiService.get('/routes/history', token: token);
      if (response.ok && response.dataAsList != null) {
        // Retornar rotas locais por agora
        return completedRoutes;
      }
    }

    // Fallback local
    return completedRoutes;
  }

  //==============================//
  //   todayKm                 //
  //==============================//
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

  //==============================//
  //   todayCompleted          //
  //==============================//
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
