import 'package:flutter_test/flutter_test.dart';

import 'package:fastlap/shared/data/vehicle_model.dart';

void main() {
  group('Vehicle', () {
    test('calcula tempo de viagem em minutos', () {
      final vehicle = Vehicle(
        id: 'v1',
        name: 'Moto',
        type: VehicleType.moto,
        speedPerKm: 60,
        carryCapacity: 20,
        weight: 120,
      );

      expect(vehicle.calculateTravelTimeMinutes(30), 30);
      expect(vehicle.calculateTravelTimeMinutes(0), 0);
    });

    test('calcula quantidade de cargas necessarias', () {
      final vehicle = Vehicle(
        id: 'v1',
        name: 'Moto',
        type: VehicleType.moto,
        speedPerKm: 60,
        carryCapacity: 20,
        weight: 120,
      );

      expect(vehicle.calculateRequiredLoads(1), 1);
      expect(vehicle.calculateRequiredLoads(20), 1);
      expect(vehicle.calculateRequiredLoads(45), 3);
    });

    test('converte dados da API para modelo do app', () {
      final vehicle = Vehicle.fromApi({
        'id': 'v1',
        'name': 'Van',
        'type': 'carro',
        'speed': '50',
        'capacity': 120,
        'weight': '900',
        'is_selected': true,
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(vehicle.id, 'v1');
      expect(vehicle.name, 'Van');
      expect(vehicle.type, VehicleType.carro);
      expect(vehicle.speedPerKm, 50);
      expect(vehicle.carryCapacity, 120);
      expect(vehicle.weight, 900);
      expect(vehicle.isSelected, isTrue);
    });
  });
}
