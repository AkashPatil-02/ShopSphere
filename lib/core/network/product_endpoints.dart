import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:shopsphere/features/home/data/product_model.dart';

class ProductEndpoints {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductEndpoints({http.Client? client}) : _client = client ?? http.Client();

  Future<Product> getProduct(int id)async{
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String,dynamic>;
    final product = Product.fromJson(data);

    return (product);
  }
}