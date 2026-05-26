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

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      latLng: LatLng(
        _toDouble(map['latitude']),
        _toDouble(map['longitude']),
      ),
      label: (map['label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'label': label,
    };
  }
}

class AppRoute {
  AppRoute({
    required this.id,
    required this.name,
    required this.points,
    required this.status,
    this.vehicleId,
    this.deliveryId,
    this.scheduledTime,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final List<RoutePoint> points; // de 2 a 5 pontos (A=início + até 4 destinos)
  RouteStatus status;
  final String? vehicleId;
  String? deliveryId;
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

  factory AppRoute.fromMap(Map<String, dynamic> map) {
    final statusName = (map['status'] ?? '').toString();
    final status = RouteStatus.values.firstWhere(
      (item) => item.name == statusName,
      orElse: () => RouteStatus.ativa,
    );

    return AppRoute(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? 'Rota').toString(),
      points: _routePointsFromMap(map['points']),
      status: status,
      vehicleId: map['vehicleId']?.toString(),
      deliveryId: map['deliveryId']?.toString(),
      scheduledTime: _parseDate(map['scheduledTime']),
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      completedAt: _parseDate(map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'points': points.map((point) => point.toMap()).toList(),
      'status': status.name,
      'vehicleId': vehicleId,
      'deliveryId': deliveryId,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

List<RoutePoint> _routePointsFromMap(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => RoutePoint.fromMap(Map<String, dynamic>.from(item)))
      .toList();
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
