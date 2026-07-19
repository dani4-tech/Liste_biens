import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';

class ApiService {
  // IP de mon PC
  static const String baseUrl = 'http://192.168.1.152:5000/api';

  /// Tente une connexion. Retourne l'utilisateur si succès, lève une exception sinon.
  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur de connexion');
    }
  }

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/produits'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Impossible de charger les produits');
    }
  }
}