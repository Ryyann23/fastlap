import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.scale = 1,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final double scale;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFE7EAF4) : const Color(0xFF222222),
          ),
        ),
        SizedBox(height: 8 * scale),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15 * scale,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15 * scale,
              color: isDark ? const Color(0xFF97A0B8) : const Color(0xFF8A8A8A),
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? const Color(0xFF9087FF) : const Color(0xFFB27B4E),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 14 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2E3345) : const Color(0xFF9D9D9D),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE86710),
                width: 1.5,
              ),
            ),
            filled: isDark,
            fillColor: isDark ? const Color(0xFF1A1D2A) : null,
          ),
        ),
      ],
    );
  }
}
