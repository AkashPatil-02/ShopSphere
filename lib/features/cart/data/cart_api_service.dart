import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shopsphere/features/cart/data/add_to_cart.dart';

class CartApiService {
  CartApiService({http.Client? client}) : _client = client ?? http.Client();
  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client _client;

  Future<Map<String, dynamic>> checkout(AddCartRequest request) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add cart: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void dispose() {
    _client.close();
  }
}
