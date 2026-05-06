import 'package:latlong2/latlong.dart';
import 'vehicle_model.dart';
import 'vehicle_service.dart';

enum RouteStatus { ativa, pausada, agendada, concluida, cancelada }

class RoutePoint {
  const RoutePoint({
    required this.id,
    required this.name,
    required this.latLng,
    this.label = '',
  });

  final String id;
  final String name;
  final LatLng latLng;
  final String label; // A, B, C, D, E

  RoutePoint copyWith({String? label}) {
    return RoutePoint(
      id: id,
      name: name,
      latLng: latLng,
      label: label ?? this.label,
    );
  }
}

class AppRoute {
  AppRoute({
    required this.id,
    required this.name,
    required this.points,
    required this.status,
    this.vehicleId,
    this.scheduledTime,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final List<RoutePoint> points; // de 2 a 5 pontos (A=início + até 4 destinos)
  RouteStatus status;
  final String? vehicleId;
  DateTime? scheduledTime;
  final DateTime createdAt;
  DateTime? completedAt;

  double get totalDistanceKm {
    const distance = Distance();
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distance.as(
          LengthUnit.Kilometer, points[i].latLng, points[i + 1].latLng);
    }
    return total;
  }

  Vehicle? get vehicle {
    if (vehicleId == null) return null;
    return VehicleService.instance.getVehicleById(vehicleId!);
  }

  String get estimatedTime {
    final v = vehicle;
    if (v != null) {
      final minutes = v.calculateTravelTimeMinutes(totalDistanceKm).round();
      if (minutes < 60) return '$minutes min';
      return '${minutes ~/ 60}h ${minutes % 60}min';
    }
    // Fallback
    final hours = totalDistanceKm / 30;
    final minutes = (hours * 60).round();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60}h ${minutes % 60}min';
  }
}
