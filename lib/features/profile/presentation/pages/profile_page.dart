import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _formatBrasiliaDateHeader() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';

    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 393).clamp(0.85, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.04).clamp(12.0, 20.0).toDouble();
    final dateHeader = _formatBrasiliaDateHeader();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF8A00),
                  Color(0xFFFF6A00),
                  Color(0xFFD84A05),
                ],
                stops: [0.05, 0.55, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
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
                      Container(
                        width: 40 * scale,
                        height: 40 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 22 * scale,
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      CircleAvatar(
                        radius: 20 * scale,
                        backgroundColor: const Color(0xFFFFA95B),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24 * scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    'Pagina de Perfil',
                    style: TextStyle(
                      color: const Color(0xFFF8D3B7),
                      fontWeight: FontWeight.w500,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                84 * scale,
                horizontalPadding,
                14 * scale,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      18 * scale,
                      82 * scale,
                      18 * scale,
                      18 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'USUARIO',
                          style: TextStyle(
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        _infoRow(Icons.person_outline, 'Nome Completo: USUARIO', scale),
                        _infoRow(Icons.mail_outline, 'Email: teste123@gmail.com', scale),
                        _infoRow(Icons.work_outline, 'Cargo: teste', scale),
                        _infoRow(Icons.calendar_month_outlined, 'Membro Desde: 11/09/2001', scale),
                        SizedBox(height: 8 * scale),
                        _actionButton('Alterar Senha', scale),
                        SizedBox(height: 8 * scale),
                        _actionButton('Configuracoes', scale),
                        SizedBox(height: 8 * scale),
                        _actionButton('Ajuda', scale),
                        SizedBox(height: 8 * scale),
                        _actionButton('Sair', scale),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -74 * scale,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 144 * scale,
                        height: 144 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(72),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(5 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7E7E7),
                            borderRadius: BorderRadius.circular(68),
                            border: Border.all(color: const Color(0xFFD3D3D3), width: 1.2),
                          ),
                          child: Icon(
                            Icons.account_circle,
                            size: 96 * scale,
                            color: const Color(0xFF9AA0A6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FastlapBottomBar(
        scale: scale,
        currentTab: FastlapTab.perfil,
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
          if (tab == FastlapTab.historico) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
            );
          }
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1 * scale),
            child: Icon(icon, size: 22 * scale, color: const Color(0xFF606060)),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF181818),
                fontSize: 17 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String title, double scale) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF929292)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF1D1D1D),
            fontSize: 16 * scale,
          ),
        ),
      ),
    );
  }
}
