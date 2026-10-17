import 'dart:convert';
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

  Future<List<Product>> getAllProducts()async{
    final response = await _client.get(
      Uri.parse('$_baseUrl/products?limit=20&skip=0 '),
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
}