import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;

  String get _baseUrl {
    if (kIsWeb) return ApiConfig.webBaseUrl;
    return ApiConfig.baseUrl;
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is List) return decoded;
      if (decoded is Map && decoded.containsKey('results')) {
        return decoded['results'] as List;
      }
      return [decoded];
    }
    throw ApiException(response.statusCode, _parseError(response));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.put(
      uri,
      headers: _headers,
      body: json.encode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.patch(
      uri,
      headers: _headers,
      body: json.encode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode >= 300) {
      throw ApiException(response.statusCode, _parseError(response));
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(response.statusCode, _parseError(response));
  }

  String _parseError(http.Response response) {
    try {
      final body = json.decode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        if (body.containsKey('detail')) return body['detail'];
        if (body.containsKey('error')) return body['error'];
        // Collect field errors
        final errors = <String>[];
        body.forEach((key, value) {
          if (value is List) {
            errors.add('$key: ${value.join(', ')}');
          } else {
            errors.add('$key: $value');
          }
        });
        return errors.join('\n');
      }
      return body.toString();
    } catch (_) {
      return 'Erreur ${response.statusCode}';
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}
