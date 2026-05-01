import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'audit_log_service.dart';
import 'vehicle_model.dart';
import 'api_service.dart';

class VehicleService extends ChangeNotifier {
  static final VehicleService _instance = VehicleService._internal();

  factory VehicleService() {
    return _instance;
  }

  static VehicleService get instance => _instance;

  VehicleService._internal();

  // Lista local em memória (cache)
  final List<Vehicle> _vehicles = [
    Vehicle(
      id: const Uuid().v4(),
      name: 'Moto Padrão',
      type: VehicleType.moto,
      speedPerKm: 80.0,
      carryCapacity: 50.0,
      weight: 150.0,
      isAvailable: true,
    ),
    Vehicle(
      id: const Uuid().v4(),
      name: 'Carro Padrão',
      type: VehicleType.carro,
      speedPerKm: 100.0,
      carryCapacity: 500.0,
      weight: 1500.0,
      isAvailable: true,
    ),
  ];

  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Vehicle> get availableVehicles => _vehicles.where((v) => v.isAvailable).toList();
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  //==============================//
  //    loadVehicles - BACKEND     //
  //==============================//
  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getAuthToken();
      if (token != null) {
        final response = await ApiService.get('/vehicles/', token: token);

        if (response.ok && response.dataAsList != null) {
          _vehicles.clear();
          for (final item in response.dataAsList!) {
            final map = Map<String, dynamic>.from(item as Map);
            _vehicles.add(_vehicleFromMap(map));
          }
        }
      }
    } catch (e) {
      _error = 'Erro ao carregar veículos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Vehicle _vehicleFromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      type: _parseVehicleType(map['type']?.toString()),
      speedPerKm: (map['speed'] ?? map['speedPerKm'] ?? 80.0).toDouble(),
      carryCapacity: (map['capacity'] ?? map['carryCapacity'] ?? 500.0).toDouble(),
      weight: (map['weight'] ?? 1500.0).toDouble(),
      isAvailable: map['is_available'] ?? map['isAvailable'] ?? true,
    );
  }

  VehicleType _parseVehicleType(String? type) {
    switch (type?.toLowerCase()) {
      case 'moto':
        return VehicleType.moto;
      case 'caminhao':
        return VehicleType.caminhao;
      default:
        return VehicleType.carro;
    }
  }

  //==============================//
  //   createVehicle - BACKEND     //
  //==============================//
  Future<bool> createVehicle({
    required String name,
    required VehicleType type,
    double speedPerKm = 80,
    double carryCapacity = 500,
    double weight = 1500,
  }) async {
    final vehicle = Vehicle(
      id: const Uuid().v4(),
      name: name,
      type: type,
      speedPerKm: speedPerKm,
      carryCapacity: carryCapacity,
      weight: weight,
      isAvailable: true,
    );

    final token = await ApiService.getAuthToken();
    if (token != null) {
      final response = await ApiService.post(
        '/vehicles/',
        body: {
          'name': name,
          'type': type.name,
          'speed': speedPerKm,
          'capacity': carryCapacity,
          'weight': weight,
        },
        token: token,
      );

      if (response.ok && response.dataAsMap != null) {
        final newVehicle = _vehicleFromMap(response.dataAsMap!);
        _vehicles.add(newVehicle);
        notifyListeners();
        return true;
      }
    }

    // Fallback local
    _vehicles.add(vehicle);
    notifyListeners();
    return true;

    AuditLogService.instance.addEntry(
      action: AuditActionType.createVehicle,
      description: 'Veículo criado: ${vehicle.name}',
      entityType: 'vehicle',
      entityId: vehicle.id,
      metadata: {
        'type': vehicle.type.name,
        'speedPerKm': vehicle.speedPerKm,
        'carryCapacity': vehicle.carryCapacity,
      },
    );
  }

  //==============================//
  //   updateVehicle - BACKEND    //
  //==============================//
  Future<bool> updateVehicleData(String vehicleId, {
    String? name,
    VehicleType? type,
    double? speedPerKm,
    double? carryCapacity,
    double? weight,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (type != null) body['type'] = type.name;
    if (speedPerKm != null) body['speed'] = speedPerKm;
    if (carryCapacity != null) body['capacity'] = carryCapacity;
    if (weight != null) body['weight'] = weight;

    final token = await ApiService.getAuthToken();
    if (token != null) {
      await ApiService.put('/vehicles/$vehicleId', body: body, token: token);
    }

    // Atualizar local
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      final old = _vehicles[index];
      _vehicles[index] = Vehicle(
        id: old.id,
        name: name ?? old.name,
        type: type ?? old.type,
        speedPerKm: speedPerKm ?? old.speedPerKm,
        carryCapacity: carryCapacity ?? old.carryCapacity,
        weight: weight ?? old.weight,
        isAvailable: old.isAvailable,
        createdAt: old.createdAt,
      )..isSelected = old.isSelected;
      final oldVehicle = _vehicles[index];
      _vehicles[index] = vehicle;
      if (_selectedVehicle?.id == vehicle.id) {
        _selectedVehicle = vehicle;
      }
      notifyListeners();

      AuditLogService.instance.addEntry(
        action: AuditActionType.updateVehicle,
        description: 'Veículo atualizado: ${vehicle.name}',
        entityType: 'vehicle',
        entityId: vehicle.id,
        metadata: {
          'oldName': oldVehicle.name,
          'newName': vehicle.name,
          'type': vehicle.type.name,
          'speedPerKm': vehicle.speedPerKm,
          'carryCapacity': vehicle.carryCapacity,
          'isAvailable': vehicle.isAvailable,
        },
      );
    }

    return true;
  }

  //==============================//
  //   deleteVehicle - BACKEND    //
  //==============================//
  Future<bool> deleteVehicle(String vehicleId) async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      await ApiService.delete('/vehicles/$vehicleId', token: token);
    }

    _vehicles.removeWhere((v) => v.id == vehicleId);
  void removeVehicle(String vehicleId) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    final vehicle = _vehicles[index];
    _vehicles.removeAt(index);
    if (_selectedVehicle?.id == vehicleId) {
      _selectedVehicle = null;
    }
    notifyListeners();
    return true;

    AuditLogService.instance.addEntry(
      action: AuditActionType.deleteVehicle,
      description: 'Veículo removido: ${vehicle.name}',
      entityType: 'vehicle',
      entityId: vehicle.id,
      metadata: {
        'type': vehicle.type.name,
      },
    );
  }

  //==============================//
  //  selectVehicle - BACKEND    //
  //==============================//
  Future<bool> selectVehicle(Vehicle vehicle) async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      await ApiService.put('/vehicles/${vehicle.id}/select', token: token);
    }

    // Atualizar local
    _selectedVehicle = vehicle;
    for (var v in _vehicles) {
      v.isSelected = v.id == vehicle.id;
    }
    notifyListeners();
    return true;
  }

  //==============================//
  //    deselectVehicle         //
  //==============================//
  void deselectVehicle() {
    _selectedVehicle = null;
    for (var v in _vehicles) {
      v.isSelected = false;
    }
    notifyListeners();
  }

  //==============================//
  //    getVehicleById          //
  //==============================//
  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  //==============================//
  //    addVehicle (local)       //
  //==============================//
  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }

//==============================//
  //    removeVehicle (local)    //
  //==============================//
  void removeVehicle(String vehicleId) {
    deleteVehicle(vehicleId);
  }

  //==============================//
  //    updateVehicle (local)    //
  //==============================//
  void updateVehicle(Vehicle vehicle) {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      notifyListeners();
    }
  }
}
