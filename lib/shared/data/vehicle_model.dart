enum VehicleType { moto, carro, caminhao }

extension VehicleTypeDisplay on VehicleType {
  String get display {
    return switch (this) {
      VehicleType.moto => 'Moto',
      VehicleType.carro => 'Carro',
      VehicleType.caminhao => 'Caminhão',
    };
  }
}

class Vehicle {
  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.speedPerKm,
    required this.carryCapacity,
    required this.weight,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final VehicleType type;
  final double speedPerKm; // km/h
  final double carryCapacity; // em kg
  final double weight; // em kg
  final bool isAvailable;
  final DateTime createdAt;
  bool isSelected = false;

  Vehicle copyWith({
    String? id,
    String? name,
    VehicleType? type,
    double? speedPerKm,
    double? carryCapacity,
    double? weight,
    bool? isAvailable,
    DateTime? createdAt,
    bool? isSelected,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      speedPerKm: speedPerKm ?? this.speedPerKm,
      carryCapacity: carryCapacity ?? this.carryCapacity,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    )..isSelected = isSelected ?? this.isSelected;
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    final typeName = (map['type'] ?? '').toString().toLowerCase();
    final type = VehicleType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => VehicleType.carro,
    );

    return Vehicle(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      type: type,
      speedPerKm: _toDouble(map['speedPerKm'] ?? map['speed']),
      carryCapacity: _toDouble(map['carryCapacity'] ?? map['capacity']),
      weight: _toDouble(map['weight']),
      isAvailable: map['isAvailable'] is bool
          ? map['isAvailable'] as bool
          : (map['is_available'] is bool ? map['is_available'] as bool : true),
      createdAt: DateTime.tryParse(
            (map['created_at'] ?? map['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    )..isSelected = map['is_selected'] == true || map['isSelected'] == true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'speedPerKm': speedPerKm,
      'carryCapacity': carryCapacity,
      'weight': weight,
      'isAvailable': isAvailable,
      'isSelected': isSelected,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Calcula o tempo estimado de viagem em minutos
  double calculateTravelTimeMinutes(double distanceKm) {
    if (speedPerKm <= 0) return 0;
    return (distanceKm / speedPerKm) * 60;
  }

  // Calcula quantas cargas são necessárias para uma rota
  int calculateRequiredLoads(double weightNeeded) {
    if (carryCapacity <= 0) return 0;
    return (weightNeeded / carryCapacity).ceil();
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
