import 'package:flutter/material.dart';
import '../../../../shared/data/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.scale,
    this.onEdit,
    this.onDelete,
    this.onSelect,
  });

  final Vehicle vehicle;
  final double scale;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSelect;

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
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07090E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: vehicle.isSelected
            ? Border.all(
                color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
                width: 2,
              )
            : null,
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
              if (vehicle.isSelected)
                Container(
                  width: 24 * scale,
                  height: 24 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                          : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 14 * scale),
                )
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  '⚡ ${vehicle.speedPerKm.toStringAsFixed(0)} km/h',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '📦 ${vehicle.carryCapacity.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSelect,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                              : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Text(
                        vehicle.isSelected ? 'SELECIONADO' : 'SELECIONAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6 * scale),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDark ? const Color(0xFF1A1D24) : const Color(0xFFF0F0F0),
                    ),
                    child: Icon(Icons.edit, size: 14 * scale, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ),
              SizedBox(width: 6 * scale),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                    child: Icon(Icons.delete, size: 14 * scale, color: Colors.red[400]),
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
