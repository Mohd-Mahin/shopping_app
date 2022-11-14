import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProivder with ChangeNotifier {
  static const API_KEY = 'AIzaSyDb6snZ-M5geTkLvmmWT9Cgs97j2MygmCY';
  late String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _userId != null) {
      return _token;
    }
    return null;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authCred')) return false;

    final authCred =
        json.decode(prefs.getString('authCred')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(authCred['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _expiryDate = expiryDate;
    _userId = authCred['userId'];
    _token = authCred['token'];
    autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> setResponse(dynamic response) async {
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
    autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate?.toIso8601String(),
    });
    prefs.setString('authCred', userData);
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
      setResponse(response);
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
      setResponse(response);
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _authTimer = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpire =
        _expiryDate?.difference(DateTime.now()).inSeconds ?? 300;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
}
