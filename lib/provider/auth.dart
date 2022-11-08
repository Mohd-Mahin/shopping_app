import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProivder with ChangeNotifier {
  static const API_KEY = 'AIzaSyDb6snZ-M5geTkLvmmWT9Cgs97j2MygmCY';
  late String _token;
  String? _userId;
  DateTime? _expiryDate;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _userId != null) {
      return _token;
    }
    return null;
  }

  Future<void> signIn(String email, String password) async {
    try {
      final url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$API_KEY');
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final parsedResponse = json.decode(response.body);
      if (parsedResponse['error'] != null) {
        throw Exception(parsedResponse['error']['message']);
      }
      _token = parsedResponse['idToken'];
      _userId = parsedResponse['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(parsedResponse['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY');
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final parsedResponse = json.decode(response.body);
      if (parsedResponse['error'] != null) {
        throw Exception(parsedResponse['error']['message']);
      }
      if (parsedResponse['error'] != null) {
        throw Exception(parsedResponse['error']['message']);
      }
      _token = parsedResponse['idToken'];
      _userId = parsedResponse['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(parsedResponse['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
