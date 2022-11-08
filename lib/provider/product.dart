import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String token, String userId) async {
    final oldState = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token');
      final response = await http.put(
        url,
        body: json.encode(isFavourite),
      );

      if (response.statusCode >= 400) {
        throw Exception('Not able to update');
      }
    } catch (error) {
      isFavourite = oldState;
      notifyListeners();
      throw error;
    }
  }
}
