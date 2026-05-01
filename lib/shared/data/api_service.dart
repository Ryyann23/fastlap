import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ApiService - Serviço base para chamadas HTTP ao backend
/// FastLap Backend API: http://localhost:3000
class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'fastlap_auth_token';

  static String? _cachedToken;

  // Headers base para todas as requisições
  static Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final authToken = token ?? _cachedToken;
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // Salvar token JWT localmente
  static Future<void> setAuthToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Recuperar token JWT
  static Future<String?> getAuthToken() async {
    if (_cachedToken != null) return _cachedToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  // Limpar token (logout)
  static Future<void> clearAuthToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Verificar se está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // GET request
  static Future<ApiResponse> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = _getHeaders(token: token);

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  // POST request
  static Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = _getHeaders(token: token);

      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  // PUT request
  static Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = _getHeaders(token: token);

      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  // DELETE request
  static Future<ApiResponse> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = _getHeaders(token: token);

      final response = await http.delete(url, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  // Tratar resposta da API
  static ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (_) {
      data = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(data);
    } else if (statusCode == 401) {
      return ApiResponse.error('Unauthorized', statusCode: statusCode);
    } else if (statusCode == 404) {
      return ApiResponse.error('Not found', statusCode: statusCode);
    } else if (statusCode >= 500) {
      return ApiResponse.error('Erro no servidor', statusCode: statusCode);
    } else {
      final message = data is Map ? data['error'] ?? data['message'] ?? 'Erro' : 'Erro';
      return ApiResponse.error(message.toString(), statusCode: statusCode);
    }
  }
}

/// Resposta da API
class ApiResponse {
  final bool ok;
  final dynamic data;
  final String? error;
  final int? statusCode;

  ApiResponse._({
    required this.ok,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(ok: true, data: data);
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(ok: false, error: error, statusCode: statusCode);
  }

  // Helper para obter dados como Map
  Map<String, dynamic>? get dataAsMap {
    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  // Helper para obter dados como List
  List<dynamic>? get dataAsList {
    if (data is List) {
      return List<dynamic>.from(data as List);
    }
    return null;
  }
}
