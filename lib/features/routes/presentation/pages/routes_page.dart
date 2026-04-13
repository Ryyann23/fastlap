import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../../../shared/widgets/user_header_avatar.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  int selectedTab = 0;

  String _formatBrasiliaDate() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';

    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final dateText = _formatBrasiliaDate();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];

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
                  SizedBox(height: 20 * scale),
                  Text(
                    'Minhas Rotas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 36 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      fontSize: 20 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 12 * scale, horizontalPadding, 16 * scale),
              child: Column(
                children: [
                  Container(
                    height: 48 * scale,
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF31364A) : const Color(0xFFD8D8D8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: isDark ? Colors.white70 : const Color(0xFF858585), size: 22 * scale),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Buscar rotas...',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF858585),
                            fontSize: 16 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Container(
                    padding: EdgeInsets.all(4 * scale),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _RouteTabChip(
                          label: 'Ativas',
                          selected: selectedTab == 0,
                          scale: scale,
                          onTap: () => setState(() => selectedTab = 0),
                        ),
                        _RouteTabChip(
                          label: 'Agendadas',
                          selected: selectedTab == 1,
                          scale: scale,
                          onTap: () => setState(() => selectedTab = 1),
                        ),
                        _RouteTabChip(
                          label: 'Historico',
                          selected: selectedTab == 2,
                          scale: scale,
                          onTap: () => setState(() => selectedTab = 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _mainRouteCard(scale),
                  SizedBox(height: 12 * scale),
                  _smallRouteCard(
                    scale: scale,
                    title: 'Rota 03',
                    subtitle: 'Distancia: 15.2 km',
                    status: 'Pausada',
                    statusColor: const Color(0xFFFFD9CC),
                    statusTextColor: const Color(0xFF9A4A2D),
                  ),
                  SizedBox(height: 10 * scale),
                  _smallRouteCard(
                    scale: scale,
                    title: 'Rota 02',
                    subtitle: dateText,
                    status: 'Agendada',
                    statusColor: const Color(0xFFDDE4EC),
                    statusTextColor: const Color(0xFF3A4653),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FastlapBottomBar(
        scale: scale,
        currentTab: FastlapTab.rotas,
        onTabSelected: (tab) {
          if (tab == FastlapTab.inicio) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
            );
          }
          if (tab == FastlapTab.mapa) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const MapPage()),
            );
          }
          if (tab == FastlapTab.historico) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
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

  Widget _mainRouteCard(double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rota 04 - Centro',
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFF0D6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Em Progresso',
                  style: TextStyle(
                    color: const Color(0xFF267A3B),
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          _routeStepsTimeline(scale: scale, activeStepLabel: 'C'),
          SizedBox(height: 14 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Distancia:', '15.2 km', scale),
              _metric('Tempo:', '35 min', scale),
              _metric('Stops:', '5', scale),
            ],
          ),
          SizedBox(height: 10 * scale),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Varias entregas comerciais',
              style: TextStyle(
                fontSize: 15 * scale,
                color: isDark ? Colors.white : const Color(0xFF393939),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Container(height: 1, color: const Color(0xFFE2E2E2)),
          SizedBox(
            height: 52 * scale,
            child: Row(
              children: [
                Expanded(child: _actionRow(Icons.receipt_long_rounded, 'Ver Detalhes', scale)),
                Container(width: 1, height: 26 * scale, color: const Color(0xFFE2E2E2)),
                Expanded(child: _actionRow(Icons.navigation_outlined, 'Navegar', scale)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallRouteCard({
    required double scale,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
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
                  title,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: isDark ? Colors.white : const Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusTextColor,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFC7742A),
          size: 22 * scale,
        ),
        SizedBox(width: 8 * scale),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * scale,
            color: isDark ? Colors.white : const Color(0xFF2F2F2F),
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          value,
          style: TextStyle(
            fontSize: 18 * scale,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _dotStep(String label, bool active, double scale, {bool showTruck = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? (isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23))
            : const Color(0xFFCBCBCB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: showTruck
          ? Icon(Icons.local_shipping_rounded, color: Colors.white, size: 17 * scale)
          : Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? const Color(0xFFCED3E6) : const Color(0xFF676767)),
                fontWeight: FontWeight.w700,
                fontSize: 14 * scale,
              ),
            ),
    );
  }

  Widget _routeStepsTimeline({required double scale, required String activeStepLabel}) {
    final steps = ['A', 'B', 'C', 'D', 'E'];
    final activeIndex = steps.indexOf(activeStepLabel);

    return SizedBox(
      height: 30 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _stepNode(
              label: steps[i],
              active: i <= activeIndex,
              showTruck: i == activeIndex,
              scale: scale,
            ),
            if (i < steps.length - 1) _stepLine(active: i < activeIndex),
          ],
        ],
      ),
    );
  }

  Widget _stepNode({
    required String label,
    required bool active,
    required bool showTruck,
    required double scale,
  }) {
    return _dotStep(label, active, scale, showTruck: showTruck);
  }

  Widget _stepLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: active
              ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFB06CFF)
                    : const Color(0xFFE67A23))
              : const Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _RouteTabChip extends StatelessWidget {
  const _RouteTabChip({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                        : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : (isDark ? const Color(0xFF111421) : Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * scale,
              color: selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF2A2A2A)),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
