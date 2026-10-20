import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:shopsphere/core/models/product_model.dart';

class ProductRepository {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Product> getProduct(int id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch product: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(data);
  }
}
