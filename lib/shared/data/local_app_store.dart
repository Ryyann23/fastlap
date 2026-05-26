import 'dart:convert';

import 'local_key_value_store.dart';
import 'local_key_value_store_factory.dart';
import 'local_key_value_store_memory.dart';

class LocalAppStore {
  LocalAppStore._(this._store);

  static final LocalAppStore instance =
      LocalAppStore._(createLocalKeyValueStore());

  static const _collectionsByUser = [
    'vehiclesByUser',
    'routesByUser',
    'auditLogsByUser',
  ];

  LocalKeyValueStore _store;
  Map<String, dynamic>? _cache;
  bool _loaded = false;

  Future<String?> getActiveUserId() async {
    final data = await _data();
    final activeUserId = data['activeUserId']?.toString();
    return activeUserId == null || activeUserId.isEmpty ? null : activeUserId;
  }

  Future<void> setActiveUserId(String? userId) async {
    final data = await _data();
    data['activeUserId'] = userId;
    await _persist();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final data = await _data();
    return _mapList(data['users']);
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final users = await getUsers();
    for (final user in users) {
      if (user['id']?.toString() == id) return user;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final users = await getUsers();
    for (final user in users) {
      if (user['email']?.toString().toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final normalized = username.trim().toLowerCase();
    final users = await getUsers();
    for (final user in users) {
      if (user['username']?.toString().toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  Future<void> upsertUser(Map<String, dynamic> user) async {
    final data = await _data();
    final users = _mapList(data['users']);
    final id = user['id']?.toString() ?? '';
    final index = users.indexWhere((item) => item['id']?.toString() == id);

    if (index == -1) {
      users.add(user);
    } else {
      users[index] = user;
    }

    data['users'] = users;
    await _persist();
  }

  Future<void> removeUser(String userId) async {
    final data = await _data();
    final users = _mapList(data['users'])
        .where((item) => item['id']?.toString() != userId)
        .toList();
    data['users'] = users;

    if (data['activeUserId']?.toString() == userId) {
      data['activeUserId'] = null;
    }

    for (final collection in _collectionsByUser) {
      final map = _collectionMap(data, collection);
      map.remove(userId);
      data[collection] = map;
    }

    await _persist();
  }

  Future<List<Map<String, dynamic>>> getUserCollection(
    String collection, {
    String? userId,
  }) async {
    final data = await _data();
    final id = userId ?? await getActiveUserId();
    if (id == null || id.isEmpty) return [];

    final map = _collectionMap(data, collection);
    return _mapList(map[id]);
  }

  Future<void> saveUserCollection(
    String collection,
    List<Map<String, dynamic>> values, {
    String? userId,
  }) async {
    final data = await _data();
    final id = userId ?? await getActiveUserId();
    if (id == null || id.isEmpty) return;

    final map = _collectionMap(data, collection);
    map[id] = values;
    data[collection] = map;
    await _persist();
  }

  void resetForTesting() {
    _store = MemoryLocalKeyValueStore();
    _cache = _emptyData();
    _loaded = true;
  }

  Future<void> clearAll() async {
    _cache = _emptyData();
    _loaded = true;
    await _store.clear();
  }

  Future<Map<String, dynamic>> _data() async {
    if (_loaded && _cache != null) return _cache!;

    final raw = await _store.read();
    if (raw == null || raw.trim().isEmpty) {
      _cache = _emptyData();
      _loaded = true;
      return _cache!;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _cache = _normalizeData(decoded);
      } else if (decoded is Map) {
        _cache = _normalizeData(Map<String, dynamic>.from(decoded));
      } else {
        _cache = _emptyData();
      }
    } catch (_) {
      _cache = _emptyData();
    }

    _loaded = true;
    return _cache!;
  }

  Future<void> _persist() async {
    final data = _cache ?? _emptyData();
    await _store.write(jsonEncode(data));
  }

  Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    final normalized = _emptyData();
    normalized.addAll(data);
    normalized['users'] = _mapList(normalized['users']);
    for (final collection in _collectionsByUser) {
      normalized[collection] = _collectionMap(normalized, collection);
    }
    return normalized;
  }

  Map<String, dynamic> _emptyData() {
    return {
      'schemaVersion': 1,
      'activeUserId': null,
      'users': <Map<String, dynamic>>[],
      'vehiclesByUser': <String, dynamic>{},
      'routesByUser': <String, dynamic>{},
      'auditLogsByUser': <String, dynamic>{},
    };
  }

  Map<String, dynamic> _collectionMap(
    Map<String, dynamic> data,
    String collection,
  ) {
    final value = data[collection];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
