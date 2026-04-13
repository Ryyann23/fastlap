import 'package:flutter/material.dart';

enum FastlapTab { inicio, rotas, mapa, historico, perfil }

class FastlapBottomBar extends StatelessWidget {
  const FastlapBottomBar({
    super.key,
    required this.scale,
    required this.currentTab,
    required this.onTabSelected,
  });

  final double scale;
  final FastlapTab currentTab;
  final ValueChanged<FastlapTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0F14) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x22000000),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isActive: currentTab == FastlapTab.inicio,
                scale: scale,
                onTap: () => onTabSelected(FastlapTab.inicio),
              ),
              _BottomItem(
                icon: Icons.alt_route_rounded,
                label: 'Rotas',
                isActive: currentTab == FastlapTab.rotas,
                scale: scale,
                onTap: () => onTabSelected(FastlapTab.rotas),
              ),
              _BottomItem(
                icon: Icons.map_outlined,
                label: 'Mapa',
                isActive: currentTab == FastlapTab.mapa,
                scale: scale,
                onTap: () => onTabSelected(FastlapTab.mapa),
              ),
              _BottomItem(
                icon: Icons.history,
                label: 'Historico',
                isActive: currentTab == FastlapTab.historico,
                scale: scale,
                onTap: () => onTabSelected(FastlapTab.historico),
              ),
              _BottomItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                isActive: currentTab == FastlapTab.perfil,
                scale: scale,
                onTap: () => onTabSelected(FastlapTab.perfil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFFB06CFF) : const Color(0xFFE86710);
    final inactiveColor = isDark ? const Color(0xFFC8CCD8) : const Color(0xFF3F3F3F);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24 * scale,
              color: isActive ? activeColor : inactiveColor,
            ),
            SizedBox(height: 2 * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
