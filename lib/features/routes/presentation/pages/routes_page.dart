import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../shared/data/route_model.dart';
import '../../../../shared/data/route_service.dart';
import '../../../../shared/utils/app_responsive.dart';
import '../../../../shared/widgets/fastlap_bottom_bar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../../../shared/widgets/user_header_avatar.dart';
import '../../../../shared/widgets/navigation_utils.dart';
import 'create_route_page.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  int selectedTab = 0;

  String _formatBrasiliaDate() {
    final brasiliaNow = DateTime.now().toUtc().add(const Duration(hours: -3));
    final raw =
        DateFormat("EEE, d 'de' MMMM | HH:mm", 'pt_BR').format(brasiliaNow);
    if (raw.isEmpty) return '';
    final withoutDot = raw.replaceAll('.', '');
    return withoutDot[0].toUpperCase() + withoutDot.substring(1);
  }

  @override
  void initState() {
    super.initState();
    RouteService.instance.addListener(_onRoutesChanged);
  }

  @override
  void dispose() {
    RouteService.instance.removeListener(_onRoutesChanged);
    super.dispose();
  }

  void _onRoutesChanged() {
    if (mounted) setState(() {});
  }

  List<AppRoute> _filteredRoutes() {
    final service = RouteService.instance;
    switch (selectedTab) {
      case 0:
        return service.routes
            .where((r) =>
                r.status == RouteStatus.ativa ||
                r.status == RouteStatus.pausada)
            .toList();
      case 1:
        return service.scheduledRoutes;
      case 2:
        return service.completedRoutes;
      default:
        return service.routes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = AppResponsive.scale(context);
    final horizontalPadding = AppResponsive.pagePadding(context);
    final dateText = _formatBrasiliaDate();
    final headerGradient = isDark
        ? const [Color(0xFF6A35C8), Color(0xFF8A46DB), Color(0xFFAE66F2)]
        : const [Color(0xFFFF8A00), Color(0xFFFF6A00), Color(0xFFD84A05)];
    final routes = _filteredRoutes();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                horizontalPadding, 10 * scale, horizontalPadding, 20 * scale),
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
                        child: Image.asset('src/img/logo.png',
                            fit: BoxFit.contain),
                      ),
                      const Spacer(),
                      ThemeModeButton(scale: scale),
                      SizedBox(width: 10 * scale),
                      UserHeaderAvatar(radius: 20 * scale),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                  Text(
                    'Minhas Rotas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 32 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    dateText,
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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 12 * scale, horizontalPadding, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4 * scale),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1A1D2A) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _RouteTabChip(
                              label: 'Ativas',
                              selected: selectedTab == 0,
                              scale: scale,
                              onTap: () => setState(() => selectedTab = 0),
                            ),
                            _RouteTabChip(
                              label: 'Agendadas',
                              selected: selectedTab == 1,
                              scale: scale,
                              onTap: () => setState(() => selectedTab = 1),
                            ),
                            _RouteTabChip(
                              label: 'Histórico',
                              selected: selectedTab == 2,
                              scale: scale,
                              onTap: () => setState(() => selectedTab = 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                    ],
                  ),
                ),
                Expanded(
                  child: routes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.alt_route_rounded,
                                size: 64 * scale,
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFCCCCCC),
                              ),
                              SizedBox(height: 12 * scale),
                              Text(
                                selectedTab == 0
                                    ? 'Nenhuma rota ativa'
                                    : selectedTab == 1
                                        ? 'Nenhuma rota agendada'
                                        : 'Nenhuma rota no histórico',
                                style: TextStyle(
                                  fontSize: 17 * scale,
                                  color: isDark
                                      ? Colors.white38
                                      : const Color(0xFF999999),
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                'Crie uma nova rota para começar',
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  color: isDark
                                      ? Colors.white24
                                      : const Color(0xFFBBBBBB),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 0,
                              horizontalPadding, 16 * scale),
                          itemCount: routes.length,
                          itemBuilder: (context, index) {
                            final route = routes[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12 * scale),
                              child: _routeCard(route, scale),
                            );
                          },
                        ),
                ),
                // Botão criar nova rota
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 0, horizontalPadding, 12 * scale),
                  child: GestureDetector(
                    onTap: () async {
                      final result =
                          await Navigator.of(context).push<RouteStatus?>(
                        MaterialPageRoute(
                            builder: (_) => const CreateRoutePage()),
                      );
                      if (result != null && mounted) {
                        setState(() {
                          // Se a rota foi criada como agendada, vai para a aba de agendadas
                          if (result == RouteStatus.agendada) {
                            selectedTab = 1;
                          }
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                              : const [Color(0xFFFF7A3D), Color(0xFFFF8A00)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CRIAR NOVA ROTA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17 * scale,
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          Container(
                            width: 36 * scale,
                            height: 36 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.26),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.add,
                                color: Colors.white, size: 22 * scale),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FastlapBottomBar(
        scale: scale,
        currentTab: FastlapTab.rotas,
        onTabSelected: (tab) {
          if (tab == FastlapTab.inicio) {
            Navigator.of(context)
                .pushReplacement(noAnimationRoute(const HomePage()));
          }
          if (tab == FastlapTab.mapa) {
            Navigator.of(context)
                .pushReplacement(noAnimationRoute(const MapPage()));
          }
          if (tab == FastlapTab.historico) {
            Navigator.of(context)
                .pushReplacement(noAnimationRoute(const HistoryPage()));
          }
          if (tab == FastlapTab.perfil) {
            Navigator.of(context)
                .pushReplacement(noAnimationRoute(const ProfilePage()));
          }
        },
      ),
    );
  }

  Widget _routeCard(AppRoute route, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    switch (route.status) {
      case RouteStatus.ativa:
        statusBgColor = const Color(0xFFCFF0D6);
        statusTextColor = const Color(0xFF267A3B);
        statusLabel = 'Ativa';
      case RouteStatus.pausada:
        statusBgColor = const Color(0xFFFFD9CC);
        statusTextColor = const Color(0xFF9A4A2D);
        statusLabel = 'Pausada';
      case RouteStatus.agendada:
        statusBgColor = const Color(0xFFDDE4EC);
        statusTextColor = const Color(0xFF3A4653);
        statusLabel = 'Agendada';
      case RouteStatus.concluida:
        statusBgColor = const Color(0xFFD4E8D9);
        statusTextColor = const Color(0xFF1B6B2E);
        statusLabel = 'Concluída';
      case RouteStatus.cancelada:
        statusBgColor = const Color(0xFFFFD6D6);
        statusTextColor = const Color(0xFFA93333);
        statusLabel = 'Cancelada';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  route.name,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),

          // Timeline dos pontos
          _routeStepsTimeline(route, scale),
          SizedBox(height: 14 * scale),

          // Métricas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Distância:',
                  '${route.totalDistanceKm.toStringAsFixed(1)} km', scale),
              _metric('Tempo:', route.estimatedTime, scale),
              _metric('Pontos:', '${route.points.length}', scale),
            ],
          ),
          SizedBox(height: 10 * scale),

          // Lista de pontos resumida
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              route.points.map((p) => '${p.label}: ${p.name}').join(' → '),
              style: TextStyle(
                fontSize: 13 * scale,
                color: isDark ? Colors.white70 : const Color(0xFF555555),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (route.status == RouteStatus.agendada &&
              route.scheduledTime != null) ...[
            SizedBox(height: 6 * scale),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 16 * scale, color: const Color(0xFF858585)),
                SizedBox(width: 4 * scale),
                Text(
                  DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR')
                      .format(route.scheduledTime!),
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: isDark ? Colors.white70 : const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 10 * scale),
          Container(
              height: 1,
              color:
                  isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),

          // Ações
          SizedBox(
            height: 52 * scale,
            child: _buildActions(route, scale),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppRoute route, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (route.status) {
      case RouteStatus.ativa:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.pause_circle_outline, 'Pausar', scale,
                    onTap: () {
              RouteService.instance.updateStatus(route.id, RouteStatus.pausada);
            })),
            Container(
                width: 1,
                height: 26 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.check_circle_outline, 'Concluir', scale,
                    onTap: () {
              RouteService.instance
                  .updateStatus(route.id, RouteStatus.concluida);
            })),
            Container(
                width: 1,
                height: 26 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.cancel_outlined, 'Cancelar', scale,
                    onTap: () {
              RouteService.instance
                  .updateStatus(route.id, RouteStatus.cancelada);
            })),
          ],
        );
      case RouteStatus.pausada:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.play_circle_outline, 'Retomar', scale,
                    onTap: () {
              RouteService.instance.updateStatus(route.id, RouteStatus.ativa);
            })),
            Container(
                width: 1,
                height: 26 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.cancel_outlined, 'Cancelar', scale,
                    onTap: () {
              RouteService.instance
                  .updateStatus(route.id, RouteStatus.cancelada);
            })),
          ],
        );
      case RouteStatus.agendada:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.play_circle_outline, 'Iniciar', scale,
                    onTap: () {
              RouteService.instance.updateStatus(route.id, RouteStatus.ativa);
            })),
            Container(
                width: 1,
                height: 26 * scale,
                color:
                    isDark ? const Color(0xFF31364A) : const Color(0xFFE2E2E2)),
            Expanded(
                child: _actionRow(Icons.cancel_outlined, 'Cancelar', scale,
                    onTap: () {
              RouteService.instance
                  .updateStatus(route.id, RouteStatus.cancelada);
            })),
          ],
        );
      case RouteStatus.concluida:
      case RouteStatus.cancelada:
        return Row(
          children: [
            Expanded(
                child: _actionRow(Icons.map_outlined, 'Ver no Mapa', scale,
                    onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const MapPage()),
              );
            })),
          ],
        );
    }
  }

  Widget _routeStepsTimeline(AppRoute route, double scale) {
    return SizedBox(
      height: 30 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < route.points.length; i++) ...[
            _dotStep(route.points[i].label, true, scale),
            if (i < route.points.length - 1) _stepLine(),
          ],
        ],
      ),
    );
  }

  Widget _dotStep(String label, bool active, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? (isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23))
            : const Color(0xFFCBCBCB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14 * scale,
        ),
      ),
    );
  }

  Widget _stepLine() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFE67A23),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, double scale,
      {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFFB06CFF) : const Color(0xFFC7742A),
            size: 22 * scale,
          ),
          SizedBox(width: 6 * scale),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, double scale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * scale,
            color: isDark ? Colors.white70 : const Color(0xFF2F2F2F),
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          value,
          style: TextStyle(
            fontSize: 18 * scale,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RouteTabChip extends StatelessWidget {
  const _RouteTabChip({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF8B4DDE), Color(0xFFB06CFF)]
                        : const [Color(0xFFFF8C22), Color(0xFFFF6B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected
                ? null
                : (isDark ? const Color(0xFF111421) : Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * scale,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white : const Color(0xFF2A2A2A)),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
