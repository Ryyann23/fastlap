import 'package:flutter/material.dart';

class PointChip extends StatelessWidget {
  final String label;
  final String name;
  final double scale;
  final bool isFixed;
  final VoidCallback? onRemove;

  const PointChip({
    super.key,
    required this.label,
    required this.name,
    required this.scale,
    this.isFixed = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: isDark ? const Color(0xFF31364A) : const Color(0xFFE67A23),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24 * scale,
            height: 24 * scale,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12 * scale,
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              'Ponto $label - $name',
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isFixed)
            Icon(Icons.lock_outline,
                color: const Color(0xFF858585), size: 16 * scale)
          else
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                color: const Color(0xFFE04A4A),
                size: 18 * scale,
              ),
            ),
        ],
      ),
    );
  }
}
