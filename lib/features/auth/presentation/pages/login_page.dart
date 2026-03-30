import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthScale = (size.width / 393).clamp(0.86, 1.15).toDouble();
    final horizontalPadding = (size.width * 0.06).clamp(16.0, 30.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF8A00),
                            Color(0xFFFF6A00),
                            Color(0xFFD84A05),
                          ],
                          stops: [0.05, 0.55, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: SizedBox(height: 12 * widthScale),
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
                              color: Colors.white,
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
                                    'src/img/logo.png',
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
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                SizedBox(height: 16 * widthScale),
                                AuthTextField(
                                  label: 'E-mail',
                                  hint: '[Seu e-mail]',
                                  icon: Icons.mail_outline,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 16 * widthScale),
                                AuthTextField(
                                  label: 'Senha',
                                  hint: '........',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  scale: widthScale,
                                ),
                                SizedBox(height: 22 * widthScale),
                                SizedBox(
                                  height: 52 * widthScale,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const HomePage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B00),
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
                                    child: const Text('ENTRAR'),
                                  ),
                                ),
                                SizedBox(height: 14 * widthScale),
                                Text(
                                  'Esqueceu sua senha?',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16 * widthScale,
                                    color: const Color(0xFF1F1F1F),
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
                                          color: const Color(0xFF363636),
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
                                        color: const Color(0xFF242424),
                                      ),
                                      children: const [
                                        TextSpan(text: 'Nao tem uma conta? '),
                                        TextSpan(
                                          text: 'Cadastre-se',
                                          style: TextStyle(
                                            color: Color(0xFFE86710),
                                            fontWeight: FontWeight.w600,
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
