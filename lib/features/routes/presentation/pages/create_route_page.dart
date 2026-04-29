import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/data/caxias_pois.dart';
import '../../../../shared/data/route_model.dart';
import '../../../../shared/data/route_service.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  final _nameController = TextEditingController();
  RouteStatus _selectedStatus = RouteStatus.ativa;
  DateTime? _scheduledTime;
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

  void _createRoute() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a rota')),
      );
      return;
    }
    if (_selectedPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos 1 ponto de destino')),
      );
      return;
    }
    if (_selectedStatus == RouteStatus.agendada && _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o horário do agendamento')),
      );
      return;
    }

    RouteService.instance.createRoute(
      name: _nameController.text.trim(),
      selectedPoints: _selectedPoints,
      status: _selectedStatus,
      scheduledTime: _scheduledTime,
    );

    Navigator.of(context).pop(true);
  }

  Future<void> _pickScheduledTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      locale: const Locale('pt', 'BR'),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];
    final labels = ['B', 'C', 'D', 'E'];
    final selectablePoints = CaxiasPOI.selectablePoints
        .where((p) => !_selectedPoints.any((s) => s.id == p.id))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(horizontalPadding, 10 * scale, horizontalPadding, 20 * scale),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22 * scale),
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
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 16 * scale, horizontalPadding, 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da rota
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
                          color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20 * scale),

                  // Status
                  Text(
                    'Status da Rota',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      _statusChip('Ativa', RouteStatus.ativa, scale),
                      SizedBox(width: 8 * scale),
                      _statusChip('Pausada', RouteStatus.pausada, scale),
                      SizedBox(width: 8 * scale),
                      _statusChip('Agendada', RouteStatus.agendada, scale),
                    ],
                  ),

                  if (_selectedStatus == RouteStatus.agendada) ...[
                    SizedBox(height: 12 * scale),
                    GestureDetector(
                      onTap: _pickScheduledTime,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14 * scale),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: isDark ? Colors.white70 : const Color(0xFF858585),
                              size: 22 * scale,
                            ),
                            SizedBox(width: 10 * scale),
                            Text(
                              _scheduledTime == null
                                  ? 'Selecionar data e horário'
                                  : DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(_scheduledTime!),
                              style: TextStyle(
                                color: _scheduledTime == null
                                    ? (isDark ? Colors.white54 : const Color(0xFF858585))
                                    : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                                fontSize: 16 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20 * scale),

                  // Ponto A fixo
                  Text(
                    'Ponto de Partida (fixo)',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  _pointTile(
                    label: 'A',
                    name: CaxiasPOI.startPoint.name,
                    scale: scale,
                    isFixed: true,
                  ),

                  SizedBox(height: 20 * scale),

                  // Pontos selecionados
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pontos de Destino (${_selectedPoints.length}/4)',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),

                  for (var i = 0; i < _selectedPoints.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8 * scale),
                      child: _pointTile(
                        label: labels[i],
                        name: _selectedPoints[i].name,
                        scale: scale,
                        onRemove: () => _removePoint(i),
                      ),
                    ),

                  if (_selectedPoints.length < 4) ...[
                    SizedBox(height: 4 * scale),
                    Text(
                      'Selecione um ponto:',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: isDark ? Colors.white70 : const Color(0xFF858585),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Container(
                      constraints: BoxConstraints(maxHeight: 220 * scale),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 4 * scale),
                        itemCount: selectablePoints.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF31364A) : const Color(0xFFEEEEEE),
                        ),
                        itemBuilder: (context, index) {
                          final point = selectablePoints[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
                              size: 22 * scale,
                            ),
                            title: Text(
                              point.name,
                              style: TextStyle(
                                fontSize: 15 * scale,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                            trailing: Icon(
                              Icons.add_circle_outline,
                              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
                              size: 22 * scale,
                            ),
                            onTap: () => _addPoint(point),
                          );
                        },
                      ),
                    ),
                  ],

                  SizedBox(height: 24 * scale),

                  // Botão criar
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
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, RouteStatus status, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _selectedStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: selected
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                        : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                  )
                : null,
            color: selected ? null : (isDark ? const Color(0xFF1A1D2A) : Colors.white),
            border: selected
                ? null
                : Border.all(
                    color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                  ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF2A2A2A)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pointTile({
    required String label,
    required String name,
    required double scale,
    bool isFixed = false,
    VoidCallback? onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15 * scale,
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16 * scale,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isFixed)
            Icon(Icons.lock_outline, color: const Color(0xFF858585), size: 20 * scale),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.remove_circle_outline,
                color: const Color(0xFFE04A4A),
                size: 22 * scale,
              ),
            ),
        ],
      ),
    );
  }
}
