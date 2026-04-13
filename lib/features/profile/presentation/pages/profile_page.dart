import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  late Future<LocalAuthUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getActiveUser();
  }

  String _formatBrasiliaDateHeader() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw = DateFormat("EEE, d 'de' MMMM", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';

    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  Future<void> _reloadUser() async {
    setState(() {
      _userFuture = _authService.getActiveUser();
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) return;

    var bytes = picked.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      try {
        bytes = await picked.files.single.xFile.readAsBytes();
      } catch (_) {
        bytes = null;
      }
    }

    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel ler a imagem selecionada.')),
      );
      return;
    }

    await _authService.updateAvatar(base64Encode(bytes));
    if (!mounted) return;

    await _reloadUser();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil atualizada.')),
    );
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
                      SizedBox(
                        height: 34 * scale,
                        child: Image.asset('src/img/logo.png', fit: BoxFit.contain),
                      ),
                      const Spacer(),
                      ThemeModeButton(scale: scale),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    'Pagina de Perfil',
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
            child: FutureBuilder<LocalAuthUser?>(
              future: _userFuture,
              builder: (context, snapshot) {
                final user = snapshot.data;
                final name = (user?.name.trim().isNotEmpty == true) ? user!.name.trim() : 'USUARIO';
                final username = (user?.username.trim().isNotEmpty == true)
                    ? user!.username.trim()
                    : 'nao definido';
                final email = (user?.email.trim().isNotEmpty == true) ? user!.email.trim() : 'nao definido';
                final memberSince = DateFormat('dd/MM/yyyy').format(user?.createdAt ?? DateTime.now());

                return SingleChildScrollView(
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
                          color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
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
                              name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 24 * scale,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF111111),
                              ),
                            ),
                            SizedBox(height: 10 * scale),
                            _infoRow(Icons.person_outline, 'Nome Completo: $name', scale, isDark: isDark),
                            _infoRow(Icons.alternate_email, 'Usuario: $username', scale, isDark: isDark),
                            _infoRow(Icons.mail_outline, 'Email: $email', scale, isDark: isDark),
                            _infoRow(
                              Icons.calendar_month_outlined,
                              'Membro Desde: $memberSince',
                              scale,
                              isDark: isDark,
                            ),
                            SizedBox(height: 8 * scale),
                            _actionButton(
                              'Configuracoes',
                              scale,
                              isDark: isDark,
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
                                );
                                if (!context.mounted) return;
                                await _reloadUser();
                              },
                            ),
                            SizedBox(height: 8 * scale),
                            _actionButton('Ajuda', scale, isDark: isDark),
                            SizedBox(height: 8 * scale),
                            _actionButton(
                              'Sair',
                              scale,
                              isDark: isDark,
                              onPressed: () async {
                                await _authService.logout();
                                if (!context.mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                                  (_) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -74 * scale,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                _avatarCircle(user, scale: scale),
                                Positioned(
                                  right: 8 * scale,
                                  bottom: 6 * scale,
                                  child: Container(
                                    width: 30 * scale,
                                    height: 30 * scale,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE86710),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 16 * scale,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _avatarCircle(LocalAuthUser? user, {required double scale}) {
    final avatarBytes = _avatarBytes(user?.avatarBase64);

    return Container(
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
          image: avatarBytes == null
              ? null
              : DecorationImage(
                  image: MemoryImage(avatarBytes),
                  fit: BoxFit.cover,
                ),
        ),
        child: avatarBytes == null
            ? Icon(
                Icons.account_circle,
                size: 96 * scale,
                color: const Color(0xFF9AA0A6),
              )
            : null,
      ),
    );
  }

  Uint8List? _avatarBytes(String? base64Data) {
    if (base64Data == null || base64Data.isEmpty) return null;
    try {
      return base64Decode(base64Data);
    } catch (_) {
      return null;
    }
  }

  Widget _infoRow(IconData icon, String text, double scale, {required bool isDark}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1 * scale),
            child: Icon(
              icon,
              size: 22 * scale,
              color: isDark ? const Color(0xFFC8CEDF) : const Color(0xFF606060),
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF181818),
                fontSize: 17 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String title,
    double scale, {
    required bool isDark,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDark ? const Color(0xFF49506A) : const Color(0xFF929292)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isDark ? const Color(0xFFE0E5F4) : const Color(0xFF1D1D1D),
            fontSize: 16 * scale,
          ),
        ),
      ),
    );
  }
}
