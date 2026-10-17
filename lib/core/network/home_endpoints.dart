import 'dart:convert';

import 'package:http/http.dart' as http;

class HomeEndpoints {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  HomeEndpoints({http.Client? client})
      : _client = client ?? http.Client();
  

  Future<List<String>> getCategories()async{
    final response = await _client.get(
      Uri.parse('https://dummyjson.com/products/category-list'),
      headers: {'Content-Type': 'application/json'},
      
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    print("Dataaaaaa $data");
    return data.cast<String>();
  }
}