import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.scale,
  });

  final String title;
  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07090E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                    : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22 * scale),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
