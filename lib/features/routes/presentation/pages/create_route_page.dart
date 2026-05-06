import 'package:flutter/material.dart';

import '../../../../shared/data/caxias_pois.dart';
import '../../../../shared/data/route_model.dart';
import '../../../../shared/data/route_service.dart';
import '../../../../shared/data/vehicle_model.dart';
import '../../../../shared/data/vehicle_service.dart';
import '../../../../shared/utils/app_responsive.dart';
import 'point_chip.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  final _nameController = TextEditingController();
  String? _selectedVehicleId;
  final List<RoutePoint> _selectedPoints = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPoint(RoutePoint point) {
    if (_selectedPoints.length >= 4) return;
    if (_selectedPoints.any((p) => p.id == point.id)) return;
    setState(() => _selectedPoints.add(point));
  }

  void _removePoint(int index) {
    setState(() => _selectedPoints.removeAt(index));
  }

  Future<void> _showAddPointDialog(double scale, bool isDark) async {
    final selectable = CaxiasPOI.selectablePoints
        .where((p) => !_selectedPoints.any((s) => s.id == p.id))
        .toList();

    final remainingSlots = 4 - _selectedPoints.length;
    if (remainingSlots <= 0) return;

    final selectedPoints = await showDialog<List<RoutePoint>>(
      context: context,
      builder: (ctx) => _SearchPointsDialog(
        points: selectable,
        scale: scale,
        isDark: isDark,
        maxSelection: remainingSlots,
      ),
    );

    if (selectedPoints != null && selectedPoints.isNotEmpty) {
      for (final point in selectedPoints) {
        _addPoint(point);
      }
    }
  }

  void _createRoute() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a rota')),
      );
      return;
    }
    if (_selectedPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione pelo menos 1 ponto de destino')),
      );
      return;
    }
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um veículo disponível')),
      );
      return;
    }

    final createdRoute = RouteService.instance.createRoute(
      name: _nameController.text.trim(),
      selectedPoints: _selectedPoints,
      vehicleId: _selectedVehicleId!,
    );

    Navigator.of(context).pop(createdRoute.status);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = AppResponsive.scale(context);
    final horizontalPadding = AppResponsive.pagePadding(context);
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];
    final labels = ['B', 'C', 'D', 'E'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                horizontalPadding, 10 * scale, horizontalPadding, 20 * scale),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40 * scale,
                      height: 40 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 22 * scale),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Text(
                    'Nova Rota',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding, 16 * scale, horizontalPadding, 16 * scale),
              children: [
                Text(
                  'Nome da Rota',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8 * scale),
                TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 16 * scale,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: Rota do Centro',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF858585),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF31364A)
                            : const Color(0xFFD8D8D8),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF31364A)
                            : const Color(0xFFD8D8D8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'Pontos atuais (${1 + _selectedPoints.length}/5)',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Column(
                  children: [
                    PointChip(
                      label: 'A',
                      name: CaxiasPOI.startPoint.name,
                      scale: scale,
                      isFixed: true,
                    ),
                    ...List.generate(
                      _selectedPoints.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(top: 8 * scale),
                        child: PointChip(
                          label: labels[i],
                          name: _selectedPoints[i].name,
                          scale: scale,
                          onRemove: () => _removePoint(i),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * scale),
                if (_selectedPoints.length < 4)
                  GestureDetector(
                    onTap: () => _showAddPointDialog(scale, isDark),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 16 * scale),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFB06CFF)
                              : const Color(0xFFE67A23),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: isDark
                                ? const Color(0xFFB06CFF)
                                : const Color(0xFFE67A23),
                            size: 24 * scale,
                          ),
                          SizedBox(width: 12 * scale),
                          Text(
                            'Adicionar próximo ponto',
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFB06CFF)
                                  : const Color(0xFFE67A23),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 24 * scale),
                Text(
                  'Selecionar Veículo',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8 * scale),
                GestureDetector(
                  onTap: () async {
                    final selectedVehicleId = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _SearchVehiclesDialog(
                        scale: scale,
                        isDark: isDark,
                        vehicles: VehicleService.instance.availableVehicles,
                        selectedVehicleId: _selectedVehicleId,
                      ),
                    );

                    if (selectedVehicleId != null) {
                      setState(() => _selectedVehicleId = selectedVehicleId);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale, vertical: 14 * scale),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF31364A)
                            : const Color(0xFFD8D8D8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF858585),
                          size: 22 * scale,
                        ),
                        SizedBox(width: 10 * scale),
                        Expanded(
                          child: Text(
                            _selectedVehicleId == null
                                ? 'Escolha um veículo disponível'
                                : (VehicleService.instance
                                        .getVehicleById(_selectedVehicleId!)
                                        ?.name ??
                                    'Veículo selecionado'),
                            style: TextStyle(
                              fontSize: 15 * scale,
                              color: _selectedVehicleId == null
                                  ? (isDark
                                      ? Colors.white54
                                      : const Color(0xFF858585))
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A)),
                              fontWeight: _selectedVehicleId == null
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF858585),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                GestureDetector(
                  onTap: _createRoute,
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
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CRIAR ROTA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17 * scale,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPointsDialog extends StatefulWidget {
  const _SearchPointsDialog({
    required this.points,
    required this.scale,
    required this.isDark,
    required this.maxSelection,
  });

  final List<RoutePoint> points;
  final double scale;
  final bool isDark;
  final int maxSelection;

  @override
  State<_SearchPointsDialog> createState() => _SearchPointsDialogState();
}

class _SearchPointsDialogState extends State<_SearchPointsDialog> {
  final _controller = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final isDark = widget.isDark;
    final filtered = widget.points
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1D2A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: 500 * scale, maxWidth: 400 * scale),
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Buscar ponto',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Text(
                  '${_selectedIds.length}/${widget.maxSelection}',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 15 * scale,
              ),
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF858585),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white70 : const Color(0xFF858585),
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F1220) : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum ponto encontrado',
                        style: TextStyle(
                          color:
                              isDark ? Colors.white54 : const Color(0xFF858585),
                          fontSize: 14 * scale,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF31364A)
                            : const Color(0xFFEEEEEE),
                      ),
                      itemBuilder: (context, index) {
                        final point = filtered[index];
                        final isSelected = _selectedIds.contains(point.id);
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: isDark
                                ? const Color(0xFFB06CFF)
                                : const Color(0xFFE67A23),
                            size: 22 * scale,
                          ),
                          title: Text(
                            point.name,
                            style: TextStyle(
                              fontSize: 15 * scale,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: isDark
                                      ? const Color(0xFFB06CFF)
                                      : const Color(0xFFE67A23),
                                  size: 20 * scale,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked,
                                  color: isDark
                                      ? Colors.white38
                                      : const Color(0xFFB0B0B0),
                                  size: 20 * scale,
                                ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(point.id);
                              } else if (_selectedIds.length <
                                  widget.maxSelection) {
                                _selectedIds.add(point.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            SizedBox(height: 12 * scale),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        final selectedPoints = widget.points
                            .where((p) => _selectedIds.contains(p.id))
                            .toList();
                        Navigator.of(context).pop(selectedPoints);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF8B4DDE)
                      : const Color(0xFFE67A23),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark
                      ? const Color(0xFF2A2E40)
                      : const Color(0xFFE0E0E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                ),
                child: Text(
                  'Adicionar selecionados',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
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

class _SearchVehiclesDialog extends StatefulWidget {
  const _SearchVehiclesDialog({
    required this.scale,
    required this.isDark,
    required this.vehicles,
    required this.selectedVehicleId,
  });

  final double scale;
  final bool isDark;
  final List<Vehicle> vehicles;
  final String? selectedVehicleId;

  @override
  State<_SearchVehiclesDialog> createState() => _SearchVehiclesDialogState();
}

class _SearchVehiclesDialogState extends State<_SearchVehiclesDialog> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final isDark = widget.isDark;
    final filtered = widget.vehicles.where((v) {
      final q = _query.toLowerCase();
      return v.name.toLowerCase().contains(q) ||
          v.type.display.toLowerCase().contains(q);
    }).toList();

    String emojiFor(VehicleType t) {
      switch (t) {
        case VehicleType.moto:
          return '🏍️';
        case VehicleType.carro:
          return '🚗';
        case VehicleType.caminhao:
          return '🚚';
      }
    }

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1D2A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: 500 * scale, maxWidth: 400 * scale),
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar veículo',
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 12 * scale),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 15 * scale,
              ),
              decoration: InputDecoration(
                hintText: 'Pesquisar veículo...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF858585),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white70 : const Color(0xFF858585),
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F1220) : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Center(
                        child: Text(
                          'Nenhum veículo encontrado',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF858585),
                            fontSize: 14 * scale,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF31364A)
                            : const Color(0xFFEEEEEE),
                      ),
                      itemBuilder: (context, index) {
                        final vehicle = filtered[index];
                        final isSelected =
                            widget.selectedVehicleId == vehicle.id;
                        return ListTile(
                          dense: true,
                          leading: Text(
                            emojiFor(vehicle.type),
                            style: TextStyle(fontSize: 20 * scale),
                          ),
                          title: Text(
                            vehicle.name,
                            style: TextStyle(
                              fontSize: 15 * scale,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${vehicle.speedPerKm.toStringAsFixed(0)} km/h • ${vehicle.carryCapacity.toStringAsFixed(0)} kg',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: isDark
                                      ? const Color(0xFFB06CFF)
                                      : const Color(0xFFE67A23),
                                  size: 20 * scale,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(vehicle.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
