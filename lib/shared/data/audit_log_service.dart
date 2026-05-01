import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuditActionType {
  login,
  logout,
  createRoute,
  updateRoute,
  deleteRoute,
  scheduleRoute,
  concludeRoute,
  cancelRoute,
  createVehicle,
  updateVehicle,
  deleteVehicle,
}

class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
    this.userName,
    this.metadata = const {},
  });

  final String id;
  final AuditActionType action;
  final String description;
  final String entityType;
  final String entityId;
  final DateTime createdAt;
  final String? userName;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action.name,
      'description': description,
      'entityType': entityType,
      'entityId': entityId,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'metadata': metadata,
    };
  }

  factory AuditLogEntry.fromMap(Map<String, dynamic> map) {
    final actionName = (map['action'] ?? '').toString();
    final action = AuditActionType.values.firstWhere(
      (item) => item.name == actionName,
      orElse: () => AuditActionType.updateRoute,
    );

    return AuditLogEntry(
      id: (map['id'] ?? '').toString(),
      action: action,
      description: (map['description'] ?? '').toString(),
      entityType: (map['entityType'] ?? '').toString(),
      entityId: (map['entityId'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ?? DateTime.now(),
      userName: map['userName']?.toString(),
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : <String, dynamic>{},
    );
  }
}

class AuditLogService extends ChangeNotifier {
  AuditLogService._();

  static final AuditLogService instance = AuditLogService._();

  static const String _auditLogKey = 'fastlap_audit_logs';

  final List<AuditLogEntry> _entries = [];
  bool _loaded = false;

  List<AuditLogEntry> get entries => List.unmodifiable(_entries);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_auditLogKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          decoded
              .map((item) => AuditLogEntry.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList(),
        );
    }
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _loaded = true;
    notifyListeners();
  }

  Future<void> addEntry({
    required AuditActionType action,
    required String description,
    required String entityType,
    required String entityId,
    String? userName,
    Map<String, dynamic> metadata = const {},
  }) async {
    await ensureLoaded();

    final entry = AuditLogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      action: action,
      description: description,
      entityType: entityType,
      entityId: entityId,
      createdAt: DateTime.now(),
      userName: userName,
      metadata: metadata,
    );

    _entries.insert(0, entry);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _entries.map((e) => e.toMap()).toList();
    await prefs.setString(_auditLogKey, jsonEncode(payload));
  }
}
