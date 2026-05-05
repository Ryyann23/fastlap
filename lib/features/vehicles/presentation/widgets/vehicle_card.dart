// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../shared/data/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.scale,
    this.onEdit,
    this.onDelete,
  });

  final Vehicle vehicle;
  final double scale;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _getVehicleIcon() {
    return switch (vehicle.type) {
      VehicleType.moto => '🏍️',
      VehicleType.carro => '🚗',
      VehicleType.caminhao => '🚚',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07090E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getVehicleIcon(),
                style: TextStyle(fontSize: 24 * scale),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                      ),
                    ),
                    Text(
                      vehicle.type.display,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '⚡ ${vehicle.speedPerKm.toStringAsFixed(0)} km/h',
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                '📦 ${vehicle.carryCapacity.toStringAsFixed(0)} kg',
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                '⚖️ ${vehicle.weight.toStringAsFixed(0)} kg',
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          // Availability status
          Row(
            children: [
              Icon(
                vehicle.isAvailable ? Icons.check_circle : Icons.cancel,
                size: 16 * scale,
                color: vehicle.isAvailable ? Colors.green : Colors.red,
              ),
              SizedBox(width: 4 * scale),
              Text(
                vehicle.isAvailable ? 'Disponível' : 'Indisponível',
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                  color: vehicle.isAvailable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),

          Row(
            children: [
              const Spacer(),
              Row(children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? const Color(0xFF1A1D24)
                            : const Color(0xFFF0F0F0),
                      ),
                      child: Icon(Icons.edit,
                          size: 14 * scale,
                          color: isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                  ),
                ),
              ]),
              SizedBox(width: 6 * scale),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                    child: Icon(Icons.delete,
                        size: 14 * scale, color: Colors.red[400]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
