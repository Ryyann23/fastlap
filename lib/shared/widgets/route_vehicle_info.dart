import 'package:flutter/material.dart';
import '../../../../shared/data/route_model.dart';
import '../../../../shared/data/route_calculator_service.dart';
import '../../../../shared/data/vehicle_service.dart';

/// Widget that shows vehicle-based route information
class RouteVehicleInfo extends StatefulWidget {
  const RouteVehicleInfo({
    super.key,
    required this.route,
    required this.scale,
  });

  final AppRoute route;
  final double scale;

  @override
  State<RouteVehicleInfo> createState() => _RouteVehicleInfoState();
}

class _RouteVehicleInfoState extends State<RouteVehicleInfo> {
  final VehicleService _vehicleService = VehicleService();
  final RouteCalculatorService _calculatorService = RouteCalculatorService();

  @override
  void initState() {
    super.initState();
    _vehicleService.addListener(_onVehicleChanged);
  }

  @override
  void dispose() {
    _vehicleService.removeListener(_onVehicleChanged);
    super.dispose();
  }

  void _onVehicleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedVehicle = _vehicleService.selectedVehicle;

    if (selectedVehicle == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * widget.scale,
          vertical: 12 * widget.scale,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D0F14) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF222328) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          'Selecione um veículo para ver o tempo estimado de rota',
          style: TextStyle(
            fontSize: 12 * widget.scale,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final travelTimeMinutes = _calculatorService.calculateRouteTravelTimeMinutes(widget.route);
    final formattedTime = travelTimeMinutes != null ? _calculatorService.formatTravelTime(travelTimeMinutes) : 'N/A';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * widget.scale,
        vertical: 12 * widget.scale,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07090E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Veículo Selecionado',
                style: TextStyle(
                  fontSize: 12 * widget.scale,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                selectedVehicle.name,
                style: TextStyle(
                  fontSize: 14 * widget.scale,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * widget.scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distância da Rota',
                      style: TextStyle(
                        fontSize: 11 * widget.scale,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2 * widget.scale),
                    Text(
                      '${widget.route.totalDistanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 16 * widget.scale,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tempo Estimado',
                      style: TextStyle(
                        fontSize: 11 * widget.scale,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2 * widget.scale),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 16 * widget.scale,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Velocidade',
                      style: TextStyle(
                        fontSize: 11 * widget.scale,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2 * widget.scale),
                    Text(
                      '${selectedVehicle.speedPerKm.toStringAsFixed(0)} km/h',
                      style: TextStyle(
                        fontSize: 16 * widget.scale,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
