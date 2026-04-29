import 'vehicle_model.dart';
import 'route_model.dart';
import 'vehicle_service.dart';

/// Service to calculate route information based on the selected vehicle
class RouteCalculatorService {
  static final RouteCalculatorService _instance = RouteCalculatorService._internal();

  factory RouteCalculatorService() {
    return _instance;
  }

  static RouteCalculatorService get instance => _instance;

  RouteCalculatorService._internal();

  final VehicleService _vehicleService = VehicleService();

  /// Calculates the time in minutes for a vehicle to complete a route
  /// Returns null if no vehicle is selected
  int? calculateRouteTravelTimeMinutes(AppRoute route) {
    final vehicle = _vehicleService.selectedVehicle;
    if (vehicle == null) return null;

    final travelTimeMinutes = vehicle.calculateTravelTimeMinutes(route.totalDistanceKm);
    return travelTimeMinutes.toInt();
  }

  /// Calculates the time in hours and minutes format
  String formatTravelTime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h${minutes}m';
    }
  }

  /// Gets the estimated speed for the selected vehicle
  double? getSelectedVehicleSpeed() {
    return _vehicleService.selectedVehicle?.speedPerKm;
  }

  /// Gets the carry capacity for the selected vehicle
  double? getSelectedVehicleCapacity() {
    return _vehicleService.selectedVehicle?.carryCapacity;
  }

  /// Calculates how many loads are needed for a given weight
  int? calculateRequiredLoads(double weightNeeded) {
    final vehicle = _vehicleService.selectedVehicle;
    if (vehicle == null) return null;

    return vehicle.calculateRequiredLoads(weightNeeded);
  }

  /// Gets a summary string for the selected vehicle
  String? getSelectedVehicleSummary() {
    final vehicle = _vehicleService.selectedVehicle;
    if (vehicle == null) return null;

    return '${vehicle.name} (${vehicle.type.display})';
  }
}
