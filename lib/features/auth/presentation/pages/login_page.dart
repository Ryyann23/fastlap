import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import 'register_page.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Preencha e-mail e senha.');
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.ok) {
      _showMessage(result.message ?? 'Falha no login.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
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
                        26 * widthScale,
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
                                SizedBox(
                                  height: 74 * widthScale,
                                  child: Image.asset(
                                    isDark ? 'src/img/logo.png' : 'src/img/logo.jpg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: 10 * widthScale),
                                Text(
                                  'Faca seu login',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18 * widthScale,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF2C2C2C),
                                  ),
                                ),
                                SizedBox(height: 16 * widthScale),
                                AuthTextField(
                                  label: 'E-mail ou usuario',
                                  hint: '[Seu e-mail ou usuario]',
                                  icon: Icons.mail_outline,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 16 * widthScale),
                                AuthTextField(
                                  label: 'Senha',
                                  hint: '........',
                                  icon: Icons.lock_outline_rounded,
                                  controller: _passwordController,
                                  obscureText: true,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 22 * widthScale),
                                SizedBox(
                                  height: 52 * widthScale,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF8B4DDE)
                                          : const Color(0xFFFF6B00),
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      textStyle: TextStyle(
                                        fontSize: 18 * widthScale,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                        : const Text('ENTRAR'),
                                  ),
                                ),
                                SizedBox(height: 14 * widthScale),
                                Text(
                                  'Esqueceu sua senha?',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16 * widthScale,
                                    color: isDark ? const Color(0xFFD5DAEA) : const Color(0xFF1F1F1F),
                                  ),
                                ),
                                SizedBox(height: 16 * widthScale),
                                Row(
                                  children: [
                                    const Expanded(child: Divider(color: Color(0xFF9C9C9C))),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12 * widthScale),
                                      child: Text(
                                        'Ou entre com',
                                        style: TextStyle(
                                          fontSize: 15 * widthScale,
                                          color: isDark ? const Color(0xFFC8CEDF) : const Color(0xFF363636),
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider(color: Color(0xFF9C9C9C))),
                                  ],
                                ),
                                SizedBox(height: 12 * widthScale),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 46 * widthScale,
                                      height: 46 * widthScale,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(color: const Color(0xFFDDDDDD)),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.google,
                                        color: const Color(0xFF4285F4),
                                        size: 20 * widthScale,
                                      ),
                                    ),
                                    SizedBox(width: 14 * widthScale),
                                    Container(
                                      width: 46 * widthScale,
                                      height: 46 * widthScale,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(color: const Color(0xFFDDDDDD)),
                                      ),
                                      child: Icon(
                                        Icons.apple,
                                        color: const Color(0xFF2B2B2B),
                                        size: 24 * widthScale,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 18 * widthScale),
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16 * widthScale,
                                        color: isDark ? const Color(0xFFE0E5F4) : const Color(0xFF242424),
                                      ),
                                      children: [
                                        const TextSpan(text: 'Nao tem uma conta? '),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) => const RegisterPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Cadastre-se',
                                              style: TextStyle(
                                                color: isDark
                                                    ? const Color(0xFFB06CFF)
                                                    : const Color(0xFFE86710),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16 * widthScale,
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
