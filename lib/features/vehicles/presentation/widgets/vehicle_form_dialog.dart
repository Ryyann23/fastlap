import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/vehicle_model.dart';

class VehicleFormDialog extends StatefulWidget {
  const VehicleFormDialog({
    super.key,
    this.vehicle,
    required this.scale,
  });

  final Vehicle? vehicle;
  final double scale;

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _speedController;
  late TextEditingController _capacityController;
  late TextEditingController _weightController;
  late VehicleType _selectedType;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _speedController = TextEditingController(
      text: widget.vehicle?.speedPerKm.toString() ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.vehicle?.carryCapacity.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.vehicle?.weight.toString() ?? '',
    );
    _selectedType = widget.vehicle?.type ?? VehicleType.carro;
    _isAvailable = widget.vehicle?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speedController.dispose();
    _capacityController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome do veículo')),
      );
      return false;
    }
    if (_speedController.text.isEmpty || double.tryParse(_speedController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Velocidade inválida')),
      );
      return false;
    }
    if (_capacityController.text.isEmpty || double.tryParse(_capacityController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capacidade inválida')),
      );
      return false;
    }
    if (_weightController.text.isEmpty || double.tryParse(_weightController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso inválido')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.vehicle != null;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0D0F14) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEditing ? 'Editar Veículo' : 'Novo Veículo',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E1E1E),
          fontWeight: FontWeight.w600,
          fontSize: 18 * widget.scale,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
              decoration: InputDecoration(
                labelText: 'Nome do Veículo',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * widget.scale, vertical: 10 * widget.scale),
              ),
            ),
            SizedBox(height: 12 * widget.scale),

            // Type selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de Veículo',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w500,
                    fontSize: 14 * widget.scale,
                  ),
                ),
                SizedBox(height: 8 * widget.scale),
                Wrap(
                  spacing: 8 * widget.scale,
                  children: VehicleType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 48 * widget.scale) / 3,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = type),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8 * widget.scale),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? (isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00))
                                  : (isDark ? const Color(0xFF1A1D24) : const Color(0xFFF0F0F0)),
                            ),
                            child: Text(
                              type.display,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                fontWeight: FontWeight.w500,
                                fontSize: 12 * widget.scale,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 12 * widget.scale),

            // Speed field
            TextField(
              controller: _speedController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
              decoration: InputDecoration(
                labelText: 'Velocidade (km/h)',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * widget.scale, vertical: 10 * widget.scale),
              ),
            ),
            SizedBox(height: 12 * widget.scale),

            // Capacity field
            TextField(
              controller: _capacityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
              decoration: InputDecoration(
                labelText: 'Capacidade de Carga (kg)',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * widget.scale, vertical: 10 * widget.scale),
              ),
            ),
            SizedBox(height: 12 * widget.scale),

            // Weight field
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
              decoration: InputDecoration(
                labelText: 'Peso do Veículo (kg)',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * widget.scale, vertical: 10 * widget.scale),
              ),
            ),
            SizedBox(height: 12 * widget.scale),

            // Availability toggle
            SwitchListTile(
              title: Text(
                'Disponível',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  fontWeight: FontWeight.w500,
                  fontSize: 14 * widget.scale,
                ),
              ),
              subtitle: Text(
                widget.vehicle?.isAvailable != true ? 'Marque como disponível para usar em rotas' : 'Veículo pronto para uso',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12 * widget.scale,
                ),
              ),
              value: _isAvailable,
              onChanged: (value) => setState(() => _isAvailable = value),
              activeThumbColor: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!_validateForm()) return;

            final vehicle = isEditing
                ? widget.vehicle!.copyWith(
                    name: _nameController.text,
                    type: _selectedType,
                    speedPerKm: double.parse(_speedController.text),
                    carryCapacity: double.parse(_capacityController.text),
                    weight: double.parse(_weightController.text),
                    isAvailable: _isAvailable,
                  )
                : Vehicle(
                    id: const Uuid().v4(),
                    name: _nameController.text,
                    type: _selectedType,
                    speedPerKm: double.parse(_speedController.text),
                    carryCapacity: double.parse(_capacityController.text),
                    weight: double.parse(_weightController.text),
                    isAvailable: _isAvailable,
                  );

            Navigator.pop(context, vehicle);
          },
          child: Text(
            isEditing ? 'Salvar' : 'Criar',
            style: TextStyle(
              color: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF8A00),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
