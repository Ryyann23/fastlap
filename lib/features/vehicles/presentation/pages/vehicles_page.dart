// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../shared/data/vehicle_model.dart';
import '../../../../shared/data/vehicle_service.dart';
import '../../../../shared/utils/app_responsive.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_form_dialog.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final VehicleService _vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    _vehicleService.addListener(_onVehiclesChanged);
  }

  @override
  void dispose() {
    _vehicleService.removeListener(_onVehiclesChanged);
    super.dispose();
  }

  void _onVehiclesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showVehicleForm({Vehicle? vehicle}) async {
    final result = await showDialog<Vehicle>(
      context: context,
      builder: (_) => VehicleFormDialog(
        vehicle: vehicle,
        scale: _getScale(),
      ),
    );

    if (result == null) return;

    if (vehicle == null) {
      _vehicleService.addVehicle(result);
    } else {
      _vehicleService.updateVehicle(result);
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja apagar ${vehicle.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Apagar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _vehicleService.removeVehicle(vehicle.id);
    }
  }

  double _getScale() {
    return AppResponsive.scale(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = _getScale();
    final horizontalPadding = AppResponsive.pagePadding(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _vehicleService.selectedVehicle);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10 * scale,
                horizontalPadding,
                22 * scale,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [
                          Color(0xFF6A35C8),
                          Color(0xFF8A46DB),
                          Color(0xFFAE66F2)
                        ]
                      : const [
                          Color(0xFFFF8A00),
                          Color(0xFFFF6A00),
                          Color(0xFFD84A05)
                        ],
                  stops: const [0.05, 0.55, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(
                              context, _vehicleService.selectedVehicle),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        ThemeModeButton(scale: scale),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Veículos',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 30 * scale,
                      ),
                    ),
                    SizedBox(height: 3 * scale),
                    Text(
                      'Gerencie seus veículos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 16 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * scale),
                    if (_vehicleService.vehicles.isEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40 * scale),
                          Text(
                            '🚗',
                            style: TextStyle(fontSize: 60 * scale),
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            'Nenhum veículo cadastrado',
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E1E1E),
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            'Adicione seu primeiro veículo para começar',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meus Veículos',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E1E1E),
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          ..._vehicleService.vehicles.map((vehicle) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12 * scale),
                              child: VehicleCard(
                                vehicle: vehicle,
                                scale: scale,
                                onEdit: () =>
                                    _showVehicleForm(vehicle: vehicle),
                                onDelete: () => _deleteVehicle(vehicle),
                              ),
                            );
                          }),
                        ],
                      ),
                    SizedBox(height: 16 * scale),
                  ],
                ),
              ),
            ),

            // Create button
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                16 * scale,
              ),
              child: GestureDetector(
                onTap: () => _showVehicleForm(),
                child: Container(
                  width: double.infinity,
                  height: 56 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                          : const [Color(0xFFFF7A3D), Color(0xFFFF8A00)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20 * scale),
                      SizedBox(width: 8 * scale),
                      Text(
                        'NOVO VEÍCULO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
