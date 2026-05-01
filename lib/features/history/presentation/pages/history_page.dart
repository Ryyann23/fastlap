import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/data/route_model.dart';
import '../../../../shared/data/route_service.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../../../shared/widgets/user_header_avatar.dart';
import '../../../../shared/widgets/navigation_utils.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    RouteService.instance.addListener(_onRoutesChanged);
  }

  @override
  void dispose() {
    RouteService.instance.removeListener(_onRoutesChanged);
    super.dispose();
  }

  void _onRoutesChanged() {
    if (mounted) setState(() {});
  }

  String _formatBrasiliaDateHeader() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM | HH:mm", 'pt_BR').format(brasiliaNow);
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

  List<AppRoute> _filteredHistory() {
    final completed = RouteService.instance.completedRoutes;
    if (_selectedDate == null) return completed;
    return completed.where((r) {
      final date = r.completedAt ?? r.createdAt;
      return _sameDate(date, _selectedDate!);
    }).toList();
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

    final historyItems = _filteredHistory();

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
                    'Histórico de Rotas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 36 * scale,
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
                  child: historyItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64 * scale,
                                color: isDark ? Colors.white24 : const Color(0xFFCCCCCC),
                              ),
                              SizedBox(height: 12 * scale),
                              Text(
                                'Nenhuma rota no histórico',
                                style: TextStyle(
                                  fontSize: 17 * scale,
                                  color: isDark ? Colors.white38 : const Color(0xFF999999),
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                'Rotas concluídas ou canceladas aparecerão aqui',
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  color: isDark ? Colors.white24 : const Color(0xFFBBBBBB),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            14 * scale,
                            horizontalPadding,
                            8 * scale,
                          ),
                          itemCount: historyItems.length,
                          itemBuilder: (context, index) {
                            final route = historyItems[index];
                            return _historyCard(route, scale);
                          },
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
            Navigator.of(context).pushReplacement(noAnimationRoute(const HomePage()));
          }
          if (tab == FastlapTab.rotas) {
            Navigator.of(context).pushReplacement(noAnimationRoute(const RoutesPage()));
          }
          if (tab == FastlapTab.mapa) {
            Navigator.of(context).pushReplacement(noAnimationRoute(const MapPage()));
          }
          if (tab == FastlapTab.perfil) {
            Navigator.of(context).pushReplacement(noAnimationRoute(const ProfilePage()));
          }
        },
      ),
    );
  }

  Widget _historyCard(AppRoute route, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = route.completedAt ?? route.createdAt;
    final isConcluida = route.status == RouteStatus.concluida;

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
                  route.name,
                  style: TextStyle(
                    fontSize: 17 * scale,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF141414),
                  ),
                ),
                SizedBox(height: 3 * scale),
                Text(
                  'Data: ${_formatItemDate(date)}',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    color: isDark ? Colors.white70 : const Color(0xFF232323),
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Distância: ${route.totalDistanceKm.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    color: isDark ? Colors.white70 : const Color(0xFF232323),
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Pontos: ${route.points.map((p) => p.label).join(' → ')}',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: isDark ? Colors.white54 : const Color(0xFF555555),
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Status: ${isConcluida ? "Concluída" : "Cancelada"}',
                  style: TextStyle(
                    fontSize: 15 * scale,
                    color: isDark ? Colors.white70 : const Color(0xFF232323),
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
                color: isDark ? Colors.white54 : const Color(0xFF1D1D1D),
              ),
              SizedBox(height: 22 * scale),
              Icon(
                isConcluida
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                size: 30 * scale,
                color: isConcluida
                    ? const Color(0xFF5C8C61)
                    : const Color(0xFFE04A4A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
