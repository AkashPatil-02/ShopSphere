import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shopsphere/core/auth/token_management.dart';

import 'token_pair.dart';

class AuthRepository {
  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client _client;
  final TokenManagement _tokenManager = TokenManagement.instance;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    await _tokenManager.saveTokens(
      TokenPair(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      ),
    );
  }

  // REFRESH ACCESS TOKEN
  Future<void> refreshTokens() async {
    final refreshToken = await _tokenManager.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available. Please log in.');
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken, 'expiresInMins': 30}),
    );

    if (response.statusCode != 200) {
      await _tokenManager.clearTokens();
      throw Exception('Session expired. Please log in again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    await _tokenManager.saveTokens(
      TokenPair(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String? ?? refreshToken,
      ),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }

  // OPTIONAL: CALL THIS WHEN THE PROTECTED ENDPOINT RETURNS 401
  Future<http.Response> getProtectedResource(String endpoint) async {
    Future<http.Response> makeRequest() async {
      final token = await _tokenManager.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please log in first.');
      }

      return _client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    var response = await makeRequest();

    if (response.statusCode == 401) {
      try {
        await refreshTokens();
        response = await makeRequest();
      } catch (_) {
        await _tokenManager.clearTokens();
        rethrow;
      }
    }

    return response;
  }

  void dispose() {
    _client.close();
  }
}
