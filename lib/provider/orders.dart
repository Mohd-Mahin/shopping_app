import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String? authToken;
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders(this.authToken, this_orders);

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final parsedData = json.decode(response.body) as dynamic;
      if (parsedData == null) return;
      List<OrderItem> orderItem = [];
      parsedData.forEach((orderId, orderData) {
        orderItem.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (product) => CartItem(
                    id: product['id'],
                    title: product['title'],
                    quantity: product['quantity'],
                    price: product['price'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
      });
      _orders = orderItem.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final dateTime = DateTime.now();
    try {
      final url = Uri.parse(
          'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
      final response = await http.post(url,
          body: json.encode({
            'amount': amount,
            'dateTime': dateTime.toIso8601String(),
            'products': cartProducts
                .map((cProduct) => {
                      'id': cProduct.id,
                      'title': cProduct.title,
                      'quantity': cProduct.quantity,
                      'price': cProduct.price
                    })
                .toList()
          }));
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: amount,
          products: cartProducts,
          dateTime: dateTime,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
