import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/data/auth_service.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../../../shared/widgets/user_header_avatar.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatBrasiliaNow() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM | HH:mm", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';

    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final userFuture = AuthService().getActiveUser();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final dateTimeText = _formatBrasiliaNow();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];

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
              22 * scale,
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
                  SizedBox(height: 22 * scale),
                  FutureBuilder<LocalAuthUser?>(
                    future: userFuture,
                    builder: (context, snapshot) {
                      final name = snapshot.data?.name.trim();
                      final welcomeName = (name == null || name.isEmpty)
                          ? 'USUARIO'
                          : name.toUpperCase();

                      return Text(
                        'Bem vindo, $welcomeName',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 28 * scale,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    dateTimeText,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16 * scale,
                horizontalPadding,
                16 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Dia',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                      fontSize: 34 * scale,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    height: 176 * scale,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SummaryCard(
                          title: 'ENTREGAS HOJE',
                          value: '32',
                          subtitle: 'Concluidas: 28 |\nPendentes: 4',
                          icon: Icons.inventory_2_outlined,
                          scale: scale,
                        ),
                        SizedBox(width: 10 * scale),
                        SummaryCard(
                          title: 'TEMPO ESTIMADO',
                          value: '2h 45min',
                          subtitle: 'Tempo Total de\nRota',
                          icon: Icons.access_time,
                          scale: scale,
                        ),
                        SizedBox(width: 10 * scale),
                        SummaryCard(
                          title: 'KMs PERCORRIDOS',
                          value: '84.7',
                          subtitle: 'Hoje',
                          icon: Icons.speed,
                          scale: scale,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Container(
                    width: double.infinity,
                    height: 62 * scale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
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
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'INICIAR NOVA ROTA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17 * scale,
                            ),
                          ),
                        ),
                        Container(
                          width: 44 * scale,
                          height: 44 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.26),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 26 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  Text(
                    'Acesso Rapido',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                      fontSize: 34 * scale,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12 * scale,
                    crossAxisSpacing: 12 * scale,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      QuickActionCard(
                        title: 'Minhas Rotas',
                        icon: Icons.map_outlined,
                        scale: scale,
                      ),
                      QuickActionCard(
                        title: 'Entregas',
                        icon: Icons.inventory_2_outlined,
                        scale: scale,
                      ),
                      QuickActionCard(
                        title: 'Veiculo',
                        icon: Icons.local_shipping_outlined,
                        scale: scale,
                      ),
                      QuickActionCard(
                        title: 'Relatorios',
                        icon: Icons.insert_chart_outlined,
                        scale: scale,
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FastlapBottomBar(
        scale: scale,
        currentTab: FastlapTab.inicio,
        onTabSelected: (tab) {
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
}
