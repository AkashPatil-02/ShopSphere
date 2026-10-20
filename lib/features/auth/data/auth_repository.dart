import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shopsphere/core/auth/token_management.dart';
import 'package:shopsphere/core/auth/token_pair.dart';
import 'package:shopsphere/features/profile/data/profile_model.dart';

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

  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }

  Future<Profile> getUserProfile() async {
    final token = await _tokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please log in first.');
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user Data: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final userData = Profile.fromJson(data);
    return userData;
  }

  void dispose() {
    _client.close();
  }
}