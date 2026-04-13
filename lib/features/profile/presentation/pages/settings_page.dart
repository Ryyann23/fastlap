import 'package:flutter/material.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/widgets/theme_mode_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _loadingUser = true;
  bool _savingProfile = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getActiveUser();
    if (!mounted) return;

    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email;
    }

    setState(() => _loadingUser = false);
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty) {
      _showMessage('Preencha nome, usuario e e-mail.');
      return;
    }

    setState(() => _savingProfile = true);
    final result = await _authService.updateProfile(
      name: name,
      username: username,
      email: email,
    );
    if (!mounted) return;
    setState(() => _savingProfile = false);

    _showMessage(result.message ?? (result.ok ? 'Perfil atualizado.' : 'Erro ao atualizar.'));
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showMessage('Informe a senha atual e a nova senha.');
      return;
    }

    setState(() => _changingPassword = true);
    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (!mounted) return;
    setState(() => _changingPassword = false);

    if (result.ok) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
    }

    _showMessage(result.message ?? (result.ok ? 'Senha atualizada.' : 'Falha ao atualizar senha.'));
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar perfil'),
        content: const Text('Essa acao remove sua conta localmente neste dispositivo. Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Apagar')),
        ],
      ),
    );

    if (confirmed != true) return;

    await _authService.deleteProfile();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(horizontalPadding, 10 * scale, horizontalPadding, 16 * scale),
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
                    'Configuracoes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 34 * scale,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    'Gerencie seu perfil local',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 16 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loadingUser
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      14 * scale,
                      horizontalPadding,
                      18 * scale,
                    ),
                    child: Column(
                      children: [
                        _sectionCard(
                          context,
                          title: 'Conta',
                          child: Column(
                            children: [
                              AuthTextField(
                                label: 'Nome completo',
                                hint: 'Seu nome',
                                icon: Icons.person_outline,
                                controller: _nameController,
                                scale: scale,
                              ),
                              SizedBox(height: 12 * scale),
                              AuthTextField(
                                label: 'Usuario',
                                hint: 'Seu usuario',
                                icon: Icons.alternate_email,
                                controller: _usernameController,
                                scale: scale,
                              ),
                              SizedBox(height: 12 * scale),
                              AuthTextField(
                                label: 'E-mail',
                                hint: 'voce@email.com',
                                icon: Icons.mail_outline,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                scale: scale,
                              ),
                              SizedBox(height: 16 * scale),
                              SizedBox(
                                width: double.infinity,
                                height: 48 * scale,
                                child: ElevatedButton(
                                  onPressed: _savingProfile ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? const Color(0xFF8B4DDE) : const Color(0xFFFF6B00),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _savingProfile
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Salvar alteracoes'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        _sectionCard(
                          context,
                          title: 'Seguranca',
                          child: Column(
                            children: [
                              AuthTextField(
                                label: 'Senha atual',
                                hint: 'Digite sua senha atual',
                                icon: Icons.lock_outline,
                                controller: _currentPasswordController,
                                obscureText: true,
                                scale: scale,
                              ),
                              SizedBox(height: 12 * scale),
                              AuthTextField(
                                label: 'Nova senha',
                                hint: 'Minimo 6 caracteres',
                                icon: Icons.lock_reset,
                                controller: _newPasswordController,
                                obscureText: true,
                                scale: scale,
                              ),
                              SizedBox(height: 16 * scale),
                              SizedBox(
                                width: double.infinity,
                                height: 48 * scale,
                                child: OutlinedButton(
                                  onPressed: _changingPassword ? null : _changePassword,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE86710),
                                    ),
                                    foregroundColor: isDark ? Colors.white : const Color(0xFF1D1D1D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _changingPassword
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Alterar senha'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        _sectionCard(
                          context,
                          title: 'Zona de risco',
                          child: SizedBox(
                            width: double.infinity,
                            height: 48 * scale,
                            child: OutlinedButton.icon(
                              onPressed: _deleteProfile,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFD14242)),
                                foregroundColor: const Color(0xFFD14242),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.delete_forever_outlined),
                              label: const Text('Apagar perfil'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
