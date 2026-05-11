import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'FASTLAP_API_URL',
    defaultValue: 'http://localhost:3000',
  );

  http.Client? _defaultClient;
  http.Client? _clientOverride;

  String? _accessToken;
  String? _refreshToken;

  bool get hasSession => _accessToken != null && _accessToken!.isNotEmpty;

  void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  void setClientForTesting(http.Client client) {
    _clientOverride = client;
  }

  void resetClientForTesting() {
    _clientOverride?.close();
    _clientOverride = null;
    clearTokens();
  }

  Future<dynamic> get(String path, {bool auth = true}) {
    return _request('GET', path, auth: auth);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _request('POST', path, body: body, auth: auth);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _request('PUT', path, body: body, auth: auth);
  }

  Future<dynamic> delete(String path, {bool auth = true}) {
    return _request('DELETE', path, auth: auth);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool auth,
    bool retryOnUnauthorized = true,
  }) async {
    final response = await _send(method, path, body: body, auth: auth);

    if (auth &&
        response.statusCode == 401 &&
        retryOnUnauthorized &&
        _refreshToken != null) {
      final refreshed = await _refresh();
      if (refreshed) {
        return _request(
          method,
          path,
          body: body,
          auth: auth,
          retryOnUnauthorized: false,
        );
      }
    }

    return _decode(response);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool auth,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    final client = _clientOverride ?? (_defaultClient ??= http.Client());
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (auth && _accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
    final payload = body == null ? null : jsonEncode(body);

    return switch (method) {
      'GET' => client.get(uri, headers: headers),
      'POST' => client.post(uri, headers: headers, body: payload),
      'PUT' => client.put(uri, headers: headers, body: payload),
      'DELETE' => client.delete(uri, headers: headers),
      _ => throw ApiException('Metodo HTTP invalido: $method'),
    };
  }

  dynamic _decode(http.Response response) {
    final body = response.body.trim();
    final decoded = body.isEmpty ? null : jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    var message = 'Erro ao comunicar com o backend.';
    if (decoded is Map<String, dynamic>) {
      message = (decoded['error'] ?? decoded['message'] ?? message).toString();
    }

    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<bool> _refresh() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final decoded = await post(
        '/api/auth/refresh',
        body: {'refreshToken': refreshToken},
        auth: false,
      );
      if (decoded is! Map<String, dynamic>) return false;

      final accessToken = decoded['accessToken']?.toString();
      final newRefreshToken = decoded['refreshToken']?.toString();
      if (accessToken == null ||
          accessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        return false;
      }

      setTokens(accessToken: accessToken, refreshToken: newRefreshToken);
      return true;
    } catch (_) {
      clearTokens();
      return false;
    }
  }
}
