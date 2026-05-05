import 'package:flutter/material.dart';
import '../../../../../shared/data/route_model.dart';

class SearchPointsDialog extends StatefulWidget {
  final List<RoutePoint> selectablePoints;
  final Function(RoutePoint) onPointSelected;
  final double scale;
  final bool isDark;

  const SearchPointsDialog({
    super.key,
    required this.selectablePoints,
    required this.onPointSelected,
    required this.scale,
    required this.isDark,
  });

  @override
  State<SearchPointsDialog> createState() => _SearchPointsDialogState();
}

class _SearchPointsDialogState extends State<SearchPointsDialog> {
  final _searchController = TextEditingController();
  String? _searchQuery;
  late List<RoutePoint> filteredPoints;

  @override
  void initState() {
    super.initState();
    filteredPoints = widget.selectablePoints;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * widget.scale)),
      child: Container(
        height: 500 * widget.scale,
        padding: EdgeInsets.all(20 * widget.scale),
        child: Column(
          children: [
            Text(
              'Adicionar Ponto de Destino',
              style: TextStyle(
                fontSize: 20 * widget.scale,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 20 * widget.scale),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  filteredPoints = widget.selectablePoints
                      .where((p) =>
                          p.name.toLowerCase().contains(_searchQuery ?? ''))
                      .toList();
                });
              },
              style: TextStyle(
                fontSize: 16 * widget.scale,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: 'Pesquisar pontos...',
                hintStyle: TextStyle(
                  color:
                      widget.isDark ? Colors.white54 : const Color(0xFF858585),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color:
                      widget.isDark ? Colors.white54 : const Color(0xFF858585),
                  size: 20 * widget.scale,
                ),
                filled: true,
                fillColor:
                    widget.isDark ? const Color(0xFF1A1D2A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14 * widget.scale),
                  borderSide: BorderSide(
                    color: widget.isDark
                        ? const Color(0xFF31364A)
                        : const Color(0xFFD8D8D8),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14 * widget.scale),
                  borderSide: BorderSide(
                    color: widget.isDark
                        ? const Color(0xFF31364A)
                        : const Color(0xFFD8D8D8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20 * widget.scale),
            Expanded(
              child: filteredPoints.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery?.isNotEmpty == true
                            ? 'Nenhum ponto encontrado'
                            : 'Digite para buscar',
                        style: TextStyle(
                          fontSize: 16 * widget.scale,
                          color: widget.isDark
                              ? Colors.white54
                              : const Color(0xFF858585),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredPoints.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: widget.isDark
                            ? const Color(0xFF31364A)
                            : const Color(0xFFEEEEEE),
                      ),
                      itemBuilder: (context, index) {
                        final point = filteredPoints[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: widget.isDark
                                ? const Color(0xFFB06CFF)
                                : const Color(0xFFE67A23),
                            size: 22 * widget.scale,
                          ),
                          title: Text(
                            point.name,
                            style: TextStyle(
                              fontSize: 16 * widget.scale,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          trailing: Icon(
                            Icons.add_circle_outline,
                            color: widget.isDark
                                ? const Color(0xFFB06CFF)
                                : const Color(0xFFE67A23),
                            size: 24 * widget.scale,
                          ),
                          onTap: () {
                            widget.onPointSelected(point);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
