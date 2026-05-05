import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.scale,
    this.compact = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final compactScale = compact ? scale * 0.88 : scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 * scale : 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
              : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24 * compactScale),
          SizedBox(height: 6 * compactScale),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
              fontSize: 11.5 * compactScale,
            ),
          ),
          SizedBox(height: 5 * compactScale),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 29 * compactScale,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 4 * compactScale),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 11.5 * compactScale,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
