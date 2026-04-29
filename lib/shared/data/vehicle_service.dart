import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'vehicle_model.dart';

class VehicleService extends ChangeNotifier {
  static final VehicleService _instance = VehicleService._internal();

  factory VehicleService() {
    return _instance;
  }

  static VehicleService get instance => _instance;

  VehicleService._internal();

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

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Vehicle> get availableVehicles => _vehicles.where((v) => v.isAvailable).toList();
  Vehicle? get selectedVehicle => _selectedVehicle;

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }

  void updateVehicle(Vehicle vehicle) {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      if (_selectedVehicle?.id == vehicle.id) {
        _selectedVehicle = vehicle;
      }
      notifyListeners();
    }
  }

  void removeVehicle(String vehicleId) {
    _vehicles.removeWhere((v) => v.id == vehicleId);
    if (_selectedVehicle?.id == vehicleId) {
      _selectedVehicle = null;
    }
    notifyListeners();
  }

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    for (var v in _vehicles) {
      v.isSelected = v.id == vehicle.id;
    }
    notifyListeners();
  }

  void deselectVehicle() {
    _selectedVehicle = null;
    for (var v in _vehicles) {
      v.isSelected = false;
    }
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
