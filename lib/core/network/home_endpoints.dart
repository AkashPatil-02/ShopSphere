import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:shopsphere/features/home/data/product_model.dart';

class HomeEndpoints {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  HomeEndpoints({http.Client? client}) : _client = client ?? http.Client();

  Future<List<String>> getCategories() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/category-list'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<String>();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/category/$category'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = data['products'] as List<dynamic>;
    return rawList
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<({List<Product> products, int total})> getAllProducts({
    int skip = 0,
    int limit = 20,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = data['products'] as List<dynamic>;
    final total = data['total'] as int;
    final products = rawList
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    return (products: products, total: total);
  }

  Future<({List<Product> products, int total})> searchProducts({
    required String query,
    int skip = 0,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/products/search').replace(
      queryParameters: {'q': query, 'limit': '$limit', 'skip': '$skip'},
    );

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search products: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = data['products'] as List<dynamic>;
    final total = data['total'] as int;

    final products = rawList
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return (products: products, total: total);
  }
}
