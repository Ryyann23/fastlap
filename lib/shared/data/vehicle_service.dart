import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'audit_log_service.dart';
import 'vehicle_model.dart';

class VehicleService extends ChangeNotifier {
  static final VehicleService _instance = VehicleService._internal();

  factory VehicleService() {
    return _instance;
  }

  static VehicleService get instance => _instance;

  VehicleService._internal();

  final ApiClient _api = ApiClient.instance;
  final List<Vehicle> _vehicles = [];

  Vehicle? _selectedVehicle;
  bool _loaded = false;
  bool _loading = false;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Vehicle> get availableVehicles =>
      _vehicles.where((v) => v.isAvailable).toList();
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _loading;

  Future<void> loadVehicles({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;

    _loading = true;
    notifyListeners();

    try {
      final data = await _api.get('/api/vehicles');
      if (data is! List) {
        throw const ApiException('Resposta invalida ao listar veiculos.');
      }

      final loadedVehicles =
          data.whereType<Map<String, dynamic>>().map(Vehicle.fromApi).toList();

      _vehicles
        ..clear()
        ..addAll(loadedVehicles);
      _selectedVehicle = _vehicles.where((v) => v.isSelected).firstOrNull;
      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final data = await _api.post('/api/vehicles', body: vehicle.toApi());
    final vehicleData = data is Map<String, dynamic> ? data['vehicle'] : null;
    if (vehicleData is! Map<String, dynamic>) {
      throw const ApiException('Resposta invalida ao criar veiculo.');
    }

    final savedVehicle = Vehicle.fromApi(vehicleData);
    _vehicles.insert(0, savedVehicle);
    notifyListeners();

    AuditLogService.instance.addEntry(
      action: AuditActionType.createVehicle,
      description: 'Veiculo criado: ${savedVehicle.name}',
      entityType: 'vehicle',
      entityId: savedVehicle.id,
      metadata: {
        'type': savedVehicle.type.name,
        'speedPerKm': savedVehicle.speedPerKm,
        'carryCapacity': savedVehicle.carryCapacity,
      },
    );

    return savedVehicle;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final data = await _api.put(
      '/api/vehicles/${vehicle.id}',
      body: vehicle.toApi(),
    );
    final vehicleData = data is Map<String, dynamic> ? data['vehicle'] : null;
    if (vehicleData is! Map<String, dynamic>) {
      throw const ApiException('Resposta invalida ao atualizar veiculo.');
    }

    final savedVehicle =
        Vehicle.fromApi(vehicleData).copyWith(isAvailable: vehicle.isAvailable);
    final index = _vehicles.indexWhere((v) => v.id == savedVehicle.id);
    if (index == -1) return;

    final oldVehicle = _vehicles[index];
    _vehicles[index] = savedVehicle;
    if (_selectedVehicle?.id == savedVehicle.id) {
      _selectedVehicle = savedVehicle;
    }
    notifyListeners();

    AuditLogService.instance.addEntry(
      action: AuditActionType.updateVehicle,
      description: 'Veiculo atualizado: ${savedVehicle.name}',
      entityType: 'vehicle',
      entityId: savedVehicle.id,
      metadata: {
        'oldName': oldVehicle.name,
        'newName': savedVehicle.name,
        'type': savedVehicle.type.name,
        'speedPerKm': savedVehicle.speedPerKm,
        'carryCapacity': savedVehicle.carryCapacity,
        'isAvailable': savedVehicle.isAvailable,
      },
    );
  }

  Future<void> removeVehicle(String vehicleId) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    await _api.delete('/api/vehicles/$vehicleId');

    final vehicle = _vehicles[index];
    _vehicles.removeAt(index);
    if (_selectedVehicle?.id == vehicleId) {
      _selectedVehicle = null;
    }
    notifyListeners();

    AuditLogService.instance.addEntry(
      action: AuditActionType.deleteVehicle,
      description: 'Veiculo removido: ${vehicle.name}',
      entityType: 'vehicle',
      entityId: vehicle.id,
      metadata: {
        'type': vehicle.type.name,
      },
    );
  }

  Future<void> selectVehicle(Vehicle vehicle) async {
    final data = await _api.put('/api/vehicles/${vehicle.id}/select');
    final vehicleData = data is Map<String, dynamic> ? data['vehicle'] : null;
    final selected = vehicleData is Map<String, dynamic>
        ? Vehicle.fromApi(vehicleData)
        : vehicle.copyWith(isSelected: true);

    _selectedVehicle = selected;
    for (var i = 0; i < _vehicles.length; i++) {
      final current = _vehicles[i];
      _vehicles[i] = current.copyWith(isSelected: current.id == selected.id);
    }
    notifyListeners();
  }

  void deselectVehicle() {
    _selectedVehicle = null;
    for (var i = 0; i < _vehicles.length; i++) {
      _vehicles[i] = _vehicles[i].copyWith(isSelected: false);
    }
    notifyListeners();
  }

  void clear() {
    _vehicles.clear();
    _selectedVehicle = null;
    _loaded = false;
    notifyListeners();
  }

  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}
