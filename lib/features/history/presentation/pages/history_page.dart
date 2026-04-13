import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../../../shared/widgets/user_header_avatar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDate;

  List<_HistoryRouteItem> _buildItems() {
    final now = DateTime.now().toUtc().add(const Duration(hours: -3));
    final today = DateTime(now.year, now.month, now.day);

    return [
      _HistoryRouteItem('Rota #12 - Zona Sul', today, 'Concluido'),
      _HistoryRouteItem('Rota #11 - Centro', today.subtract(const Duration(days: 1)), 'Concluido'),
      _HistoryRouteItem('Rota #10 - Praia', today.subtract(const Duration(days: 2)), 'Concluido'),
      _HistoryRouteItem('Rota #09 - Norte', today.subtract(const Duration(days: 3)), 'Concluido'),
      _HistoryRouteItem('Rota #08 - Leste', today.subtract(const Duration(days: 5)), 'Concluido'),
    ];
  }

  String _formatBrasiliaDateHeader() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';

    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  String _formatItemDate(DateTime date) {
    final formatted = DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final dateHeader = _formatBrasiliaDateHeader();
    final headerGradient = isDark
      ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
      : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];

    final allItems = _buildItems();
    final filteredItems = _selectedDate == null
        ? allItems
        : allItems.where((item) => _sameDate(item.date, _selectedDate!)).toList();

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
              16 * scale,
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
                      SizedBox(
                        height: 34 * scale,
                        child: Image.asset('src/img/logo.png', fit: BoxFit.contain),
                      ),
                      const Spacer(),
                      ThemeModeButton(scale: scale),
                      SizedBox(width: 10 * scale),
                      UserHeaderAvatar(radius: 20 * scale),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    'Historico de Rotas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 42 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    dateHeader,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      fontSize: 18 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      14 * scale,
                      horizontalPadding,
                      8 * scale,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12 * scale),
                        padding: EdgeInsets.all(14 * scale),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 17 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF141414),
                                    ),
                                  ),
                                  SizedBox(height: 3 * scale),
                                  Text(
                                    'Data: ${_formatItemDate(item.date)}',
                                    style: TextStyle(
                                      fontSize: 15 * scale,
                                      color: isDark ? Colors.white : const Color(0xFF232323),
                                    ),
                                  ),
                                  SizedBox(height: 2 * scale),
                                  Text(
                                    'Status: ${item.status}',
                                    style: TextStyle(
                                      fontSize: 15 * scale,
                                      color: isDark ? Colors.white : const Color(0xFF232323),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            Column(
                              children: [
                                Icon(
                                  Icons.outlined_flag_rounded,
                                  size: 28 * scale,
                                  color: isDark ? Colors.white : const Color(0xFF1D1D1D),
                                ),
                                SizedBox(height: 22 * scale),
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 30 * scale,
                                  color: const Color(0xFF5C8C61),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    6 * scale,
                    horizontalPadding,
                    10 * scale,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFB88649),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          ),
                          child: Text(
                            'Ver Tudo',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF9B6E35),
                              fontSize: 16 * scale,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final now = DateTime.now().toUtc().add(const Duration(hours: -3));
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? now,
                              firstDate: now.subtract(const Duration(days: 30)),
                              lastDate: now,
                              locale: const Locale('pt', 'BR'),
                            );

                            if (picked != null) {
                              setState(() {
                                _selectedDate = DateTime(picked.year, picked.month, picked.day);
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFB88649),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          ),
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            color: isDark ? Colors.white : const Color(0xFF9B6E35),
                            size: 20 * scale,
                          ),
                          label: Text(
                            'Filtrar por Data',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF9B6E35),
                              fontSize: 16 * scale,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FastlapBottomBar(
        scale: scale,
        currentTab: FastlapTab.historico,
        onTabSelected: (tab) {
          if (tab == FastlapTab.inicio) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
            );
          }
          if (tab == FastlapTab.rotas) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const RoutesPage()),
            );
          }
          if (tab == FastlapTab.mapa) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const MapPage()),
            );
          }
          if (tab == FastlapTab.perfil) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class _HistoryRouteItem {
  const _HistoryRouteItem(this.title, this.date, this.status);

  final String title;
  final DateTime date;
  final String status;
}
