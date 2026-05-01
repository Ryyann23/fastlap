import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../shared/data/audit_log_service.dart';
import '../../../../shared/widgets/theme_mode_button.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  AuditActionType? _selectedAction;

  @override
  void initState() {
    super.initState();
    AuditLogService.instance.ensureLoaded();
    AuditLogService.instance.addListener(_onLogsChanged);
  }

  @override
  void dispose() {
    AuditLogService.instance.removeListener(_onLogsChanged);
    super.dispose();
  }

  void _onLogsChanged() {
    if (mounted) setState(() {});
  }

  String _formatBrasiliaNow() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM | HH:mm", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';
    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  List<AuditLogEntry> _filteredEntries() {
    final entries = AuditLogService.instance.entries;
    if (_selectedAction == null) return entries;
    return entries.where((e) => e.action == _selectedAction).toList();
  }

  String _actionLabel(AuditActionType action) {
    switch (action) {
      case AuditActionType.login:
        return 'Login';
      case AuditActionType.logout:
        return 'Logout';
      case AuditActionType.createRoute:
        return 'Criar rota';
      case AuditActionType.updateRoute:
        return 'Editar rota';
      case AuditActionType.deleteRoute:
        return 'Excluir rota';
      case AuditActionType.scheduleRoute:
        return 'Agendar rota';
      case AuditActionType.concludeRoute:
        return 'Concluir rota';
      case AuditActionType.cancelRoute:
        return 'Cancelar rota';
      case AuditActionType.createVehicle:
        return 'Criar veículo';
      case AuditActionType.updateVehicle:
        return 'Editar veículo';
      case AuditActionType.deleteVehicle:
        return 'Excluir veículo';
    }
  }

  Future<void> _exportCsv(List<AuditLogEntry> entries) async {
    final rows = <List<dynamic>>[
      ['Data/Hora', 'Ação', 'Descrição', 'Entidade', 'ID Entidade', 'Usuário'],
      ...entries.map(
        (e) => [
          DateFormat("dd/MM/yyyy HH:mm", 'pt_BR').format(e.createdAt),
          _actionLabel(e.action),
          e.description,
          e.entityType,
          e.entityId,
          e.userName ?? '',
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar relatório CSV',
      fileName: 'relatorio_fastlap.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (path == null) return;
    final file = File(path);
    await file.writeAsString(csv);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relatório CSV exportado com sucesso.')),
    );
  }

  Future<void> _exportPdf(List<AuditLogEntry> entries) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFF8A00),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Relatórios FastLap',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                pw.Text(
                  DateFormat("dd/MM/yyyy HH:mm", 'pt_BR').format(DateTime.now()),
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFFF8A00), width: 0.6),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFD84A05),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerLeft,
            },
            headers: ['Data/Hora', 'Ação', 'Descrição', 'Entidade', 'Usuário'],
            data: entries
                .map(
                  (e) => [
                    DateFormat("dd/MM/yyyy HH:mm", 'pt_BR').format(e.createdAt),
                    _actionLabel(e.action),
                    e.description,
                    '${e.entityType} (${e.entityId})',
                    e.userName ?? '-',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar relatório PDF',
      fileName: 'relatorio_fastlap.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (path == null) return;
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relatório PDF exportado com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final dateTimeText = _formatBrasiliaNow();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];
    final entries = _filteredEntries();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              10 * scale,
              horizontalPadding,
              18 * scale,
            ),
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
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                      const Spacer(),
                      ThemeModeButton(scale: scale),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Relatórios',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 34 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    dateTimeText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 18 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 12 * scale, horizontalPadding, 8 * scale),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AuditActionType?>(
                    value: _selectedAction,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por ação',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<AuditActionType?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...AuditActionType.values.map(
                        (a) => DropdownMenuItem<AuditActionType?>(
                          value: a,
                          child: Text(_actionLabel(a)),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedAction = value),
                  ),
                ),
                SizedBox(width: 8 * scale),
                IconButton(
                  tooltip: 'Exportar CSV',
                  onPressed: entries.isEmpty ? null : () => _exportCsv(entries),
                  icon: const Icon(Icons.table_chart_outlined),
                ),
                IconButton(
                  tooltip: 'Exportar PDF',
                  onPressed: entries.isEmpty ? null : () => _exportPdf(entries),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum evento encontrado.',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: isDark ? Colors.white54 : const Color(0xFF666666),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8 * scale,
                      horizontalPadding,
                      10 * scale,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10 * scale),
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE86710),
                            ),
                            SizedBox(width: 10 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _actionLabel(entry.action),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16 * scale,
                                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                                    ),
                                  ),
                                  SizedBox(height: 2 * scale),
                                  Text(
                                    entry.description,
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      color: isDark ? Colors.white70 : const Color(0xFF353535),
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    '${DateFormat("dd/MM/yyyy HH:mm", 'pt_BR').format(entry.createdAt)} • ${entry.entityType} #${entry.entityId}',
                                    style: TextStyle(
                                      fontSize: 12 * scale,
                                      color: isDark ? Colors.white54 : const Color(0xFF666666),
                                    ),
                                  ),
                                  if (entry.userName != null && entry.userName!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2 * scale),
                                      child: Text(
                                        'Usuário: ${entry.userName}',
                                        style: TextStyle(
                                          fontSize: 12 * scale,
                                          color: isDark ? Colors.white54 : const Color(0xFF666666),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
