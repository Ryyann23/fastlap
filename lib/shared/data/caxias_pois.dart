import 'package:latlong2/latlong.dart';
import 'route_model.dart';

/// Pontos de interesse REAIS de Caxias-MA (coordenadas do OpenStreetMap)
class CaxiasPOI {
  static const List<RoutePoint> allPoints = [
    // UniFacema (ponto fixo do usuario - sempre A)
    RoutePoint(
        id: 'unifacema', name: 'UniFacema', latLng: LatLng(-4.8645, -43.3573)),

    // Educação
    RoutePoint(
        id: 'ce_goncalves_dias',
        name: 'CE Gonçalves Dias',
        latLng: LatLng(-4.8639, -43.3583)),
    RoutePoint(
        id: 'colegio_caxiense',
        name: 'Colégio Caxiense',
        latLng: LatLng(-4.8640, -43.3578)),
    RoutePoint(
        id: 'escola_sesi',
        name: 'Escola SESI Caxias',
        latLng: LatLng(-4.8727, -43.3455)),
    RoutePoint(
        id: 'colegio_tiradentes',
        name: 'Colégio Militar Tiradentes IV',
        latLng: LatLng(-4.8712, -43.3400)),
    RoutePoint(
        id: 'escola_adventista',
        name: 'Escola Adventista de Caxias',
        latLng: LatLng(-4.8652, -43.3613)),
    RoutePoint(
        id: 'ui_duque_caxias',
        name: 'UI Duque de Caxias',
        latLng: LatLng(-4.8611, -43.3558)),
    RoutePoint(
        id: 'uim_eziquio',
        name: 'UIM Pref. Ezíquio Barros Filho',
        latLng: LatLng(-4.8637, -43.3578)),
    RoutePoint(
        id: 'apae_caxias',
        name: 'APAE de Caxias',
        latLng: LatLng(-4.8502, -43.3533)),

    // Religião
    RoutePoint(
        id: 'catedral',
        name: 'Catedral de Caxias',
        latLng: LatLng(-4.8650, -43.3588)),
    RoutePoint(
        id: 'igreja_rosario',
        name: 'Igreja N. Sra. do Rosário',
        latLng: LatLng(-4.8618, -43.3613)),
    RoutePoint(
        id: 'igreja_matriz',
        name: 'Igreja da Matriz',
        latLng: LatLng(-4.8641, -43.3624)),

    // Comércio / Supermercados
    RoutePoint(
        id: 'carvalho',
        name: 'Carvalho Supermercado',
        latLng: LatLng(-4.8579, -43.3499)),
    RoutePoint(
        id: 'mix_mateus',
        name: 'Mix Mateus Caxias',
        latLng: LatLng(-4.8596, -43.3479)),
    RoutePoint(
        id: 'mix_mateus_2',
        name: 'Mix Mateus 2',
        latLng: LatLng(-4.8683, -43.3660)),
    RoutePoint(
        id: 'mercado_central',
        name: 'Mercado Central',
        latLng: LatLng(-4.8604, -43.3650)),

    // Bancos
    RoutePoint(
        id: 'banco_brasil',
        name: 'Banco do Brasil',
        latLng: LatLng(-4.8624, -43.3613)),
    RoutePoint(
        id: 'caixa_economica',
        name: 'Caixa Econômica Federal',
        latLng: LatLng(-4.8619, -43.3623)),

    // Saúde
    RoutePoint(
        id: 'upa_caxias',
        name: 'UPA Caxias',
        latLng: LatLng(-4.8668, -43.3791)),

    // Turismo / Lazer
    RoutePoint(
        id: 'mirante',
        name: 'Mirante de Caxias',
        latLng: LatLng(-4.8653, -43.3574)),
    RoutePoint(
        id: 'praca_duque',
        name: 'Praça Duque de Caxias',
        latLng: LatLng(-4.8656, -43.3561)),

    // Governo / Público
    RoutePoint(
        id: 'prefeitura',
        name: 'Prefeitura Municipal',
        latLng: LatLng(-4.8622, -43.3637)),
    RoutePoint(
        id: 'rodoviaria',
        name: 'Terminal Rodoviário',
        latLng: LatLng(-4.8817, -43.3462)),

    // Esporte
    RoutePoint(
        id: 'bb_athletic',
        name: 'BB Athletic Association',
        latLng: LatLng(-4.8834, -43.3750)),

    // Cemitério
    RoutePoint(
        id: 'cemiterio',
        name: 'Cemitério N. Sra. dos Remédios',
        latLng: LatLng(-4.8563, -43.3584)),
  ];

  /// Pontos selecionáveis pelo usuário (exclui UniFacema que é fixo como ponto A)
  static List<RoutePoint> get selectablePoints =>
      allPoints.where((p) => p.id != 'unifacema').toList();

  /// Ponto fixo de início (UniFacema)
  static RoutePoint get startPoint => allPoints.first;
}
