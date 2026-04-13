import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Preencha todos os campos.');
      return;
    }

    if (password.length < 6) {
      _showMessage('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.register(
      name: name,
      username: username,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.ok) {
      _showMessage(result.message ?? 'Falha ao criar conta.');
      return;
    }

    _showMessage('Cadastro realizado com sucesso. Faça login.');
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final widthScale = (size.width / 393).clamp(0.86, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.06).clamp(16.0, 30.0).toDouble();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20 * widthScale,
                        horizontalPadding,
                        86 * widthScale,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: headerGradient,
                          stops: const [0.05, 0.55, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Spacer(),
                          ThemeModeButton(scale: widthScale),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -42 * widthScale),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            padding: EdgeInsets.fromLTRB(
                              22 * widthScale,
                              28 * widthScale,
                              22 * widthScale,
                              24 * widthScale,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Criar conta',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24 * widthScale,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF2C2C2C),
                                  ),
                                ),
                                SizedBox(height: 18 * widthScale),
                                AuthTextField(
                                  label: 'Nome',
                                  hint: 'Seu nome completo',
                                  icon: Icons.person_outline,
                                  controller: _nameController,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 14 * widthScale),
                                AuthTextField(
                                  label: 'Nome de usuario',
                                  hint: 'ex: motoboy01',
                                  icon: Icons.alternate_email,
                                  controller: _usernameController,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 14 * widthScale),
                                AuthTextField(
                                  label: 'E-mail',
                                  hint: 'voce@email.com',
                                  icon: Icons.mail_outline,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 14 * widthScale),
                                AuthTextField(
                                  label: 'Senha',
                                  hint: 'Minimo 6 caracteres',
                                  icon: Icons.lock_outline_rounded,
                                  controller: _passwordController,
                                  obscureText: true,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 22 * widthScale),
                                SizedBox(
                                  height: 52 * widthScale,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF8B4DDE)
                                          : const Color(0xFFFF6B00),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20 * widthScale,
                                            height: 20 * widthScale,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('CADASTRAR'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * widthScale),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
