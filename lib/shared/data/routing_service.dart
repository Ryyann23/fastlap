import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Serviço que usa a API OSRM (Open Source Routing Machine) para obter
/// rotas reais que seguem as ruas do OpenStreetMap.
class RoutingService {
  RoutingService._();
  static final RoutingService instance = RoutingService._();

  // Cache de rotas já buscadas (chave = "lat1,lng1;lat2,lng2")
  final Map<String, List<LatLng>> _cache = {};

  /// Busca a rota real (pelas ruas) entre uma lista de pontos.
  /// Retorna a lista de coordenadas que formam o caminho pelas ruas.
  /// Se falhar, retorna os pontos originais (linha reta como fallback).
  Future<List<LatLng>> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;

    final cacheKey =
        waypoints.map((p) => '${p.latitude},${p.longitude}').join(';');
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      // Formatar coordenadas para OSRM: lng,lat;lng,lat;...
      final coords =
          waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coords'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;

        if (routes != null && routes.isNotEmpty) {
          final geometry = routes[0]['geometry'] as Map<String, dynamic>;
          final coordinates = geometry['coordinates'] as List<dynamic>;

          final routePoints = coordinates.map<LatLng>((coord) {
            final c = coord as List<dynamic>;
            // GeoJSON é [longitude, latitude]
            return LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            );
          }).toList();

          _cache[cacheKey] = routePoints;
          return routePoints;
        }
      }
    } catch (_) {
      // Em caso de erro, retorna linha reta como fallback
    }

    return waypoints;
  }

  /// Limpa o cache de rotas
  void clearCache() {
    _cache.clear();
  }
}
