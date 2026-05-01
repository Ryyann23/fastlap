import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'api_service.dart';

/// Modelo de POI
class Poi {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final String? notes;
  final DateTime createdAt;

  const Poi({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.notes,
    required this.createdAt,
  });

  factory Poi.fromMap(Map<String, dynamic> map) {
    return Poi(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      latitude: (map['latitude'] ?? map['lat'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? map['lng'] ?? 0.0).toDouble(),
      notes: map['notes']?.toString(),
      createdAt: DateTime.tryParse((map['created_at'] ?? map['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Poi copyWith({
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return Poi(
      id: id,
      userId: userId,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

/// Serviço de POIs
class PoiService extends ChangeNotifier {
  static final PoiService _instance = PoiService._internal();
  factory PoiService() => _instance;
  static PoiService get instance => _instance;

  PoiService._internal();

  final List<Poi> _pois = [];
  bool _isLoading = false;
  String? _error;

  List<Poi> get pois => List.unmodifiable(_pois);
  bool get isLoading => _isLoading;
  String? get error => _error;

  //==============================//
  //    loadPois - BACKEND       //
  //==============================//
  Future<void> loadPois() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/pois/');

      if (response.ok && response.dataAsList != null) {
        _pois.clear();
        for (final item in response.dataAsList!) {
          _pois.add(Poi.fromMap(Map<String, dynamic>.from(item as Map)));
        }
      }
    } catch (e) {
      _error = 'Erro ao carregar POIs';
    }

    _isLoading = false;
    notifyListeners();
  }

  //==============================//
  //   createPoi - BACKEND      //
  //==============================//
  Future<Poi?> createPoi({
    required String name,
    required String category,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    final body = {
      'name': name,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };

    final token = await ApiService.getAuthToken();
    Poi? newPoi;

    if (token != null) {
      final response = await ApiService.post('/pois/', body: body, token: token);
      if (response.ok && response.dataAsMap != null) {
        newPoi = Poi.fromMap(response.dataAsMap!);
      }
    }

    if (newPoi == null) {
      // Fallback local
      newPoi = Poi(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: '',
        name: name,
        category: category,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        createdAt: DateTime.now(),
      );
    }

    _pois.add(newPoi);
    notifyListeners();
    return newPoi;
  }

  //==============================//
  //   updatePoi - BACKEND      //
  //==============================//
  Future<bool> updatePoiData(String poiId, {
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (category != null) body['category'] = category;
    if (address != null) body['address'] = address;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (notes != null) body['notes'] = notes;

    final token = await ApiService.getAuthToken();
    if (token != null) {
      await ApiService.put('/pois/$poiId', body: body, token: token);
    }

    // Atualizar local
    final index = _pois.indexWhere((p) => p.id == poiId);
    if (index != -1) {
      _pois[index] = _pois[index].copyWith(
        name: name,
        category: category,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
      notifyListeners();
    }

    return true;
  }

  //==============================//
  //   deletePoi - BACKEND      //
  //==============================//
  Future<bool> deletePoi(String poiId) async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      await ApiService.delete('/pois/$poiId', token: token);
    }

    _pois.removeWhere((p) => p.id == poiId);
    notifyListeners();
    return true;
  }

  //==============================//
  //  getNearbyPois - BACKEND   //
  //==============================//
  Future<List<Poi>> getNearbyPois({
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      final response = await ApiService.get(
        '/pois/nearby?lat=$lat&lng=$lng&radius=$radiusKm',
        token: token,
      );
      if (response.ok && response.dataAsList != null) {
        return response.dataAsList!
            .map((item) => Poi.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    }

    // Fallback local: calcular distância usando latlong2
    const distance = latlong.Distance();
    return _pois.where((p) {
      final dist = distance.as(
        latlong.LengthUnit.Kilometer,
        latlong.LatLng(lat, lng),
        latlong.LatLng(p.latitude, p.longitude),
      );
      return dist <= radiusKm;
    }).toList();
  }

  //==============================//
  //    addPoi (local)          //
  //==============================//
  void addPoi(Poi poi) {
    _pois.add(poi);
    notifyListeners();
  }

  //==============================//
  //    getPoiById            //
  //==============================//
  Poi? getPoiById(String id) {
    try {
      return _pois.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  //==============================//
  //    getPoisByCategory     //
  //==============================//
  List<Poi> getPoisByCategory(String category) {
    return _pois.where((p) => p.category == category).toList();
  }
}
