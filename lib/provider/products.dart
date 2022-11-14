import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

class Products with ChangeNotifier {
  String? authToken;
  String? userId;
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description:
    //       'Warm and cozy - exactly what you need for the winter. Warm and cozy - exactly what you need for the winter. Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  Map<String, bool> favourites = {};

  var _showFavouriteOnly = false;
  Products(this.authToken, this.userId, this._products);

  List<Product> get items {
    return [..._products];
  }

  List<Product> get favItems {
    return _products.where((element) => element.isFavourite).toList();
  }

  void showFavouriteOnly() {
    _showFavouriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavouriteOnly = false;
    notifyListeners();
  }

  Future<dynamic> fetchFavourites() async {
    try {
      final url = Uri.parse(
          'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final response = await http.get(url);
      favourites = {...json.decode(response.body)};
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final parsedResponse = json.decode(response.body) as dynamic;
      await fetchFavourites();

      if (parsedResponse == null) return;
      final List<Product> products = [];
      parsedResponse.forEach((key, value) {
        products.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavourite: favourites[key] ?? false,
          ),
        );
      });
      _products = products;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(
    String title,
    String description,
    double price,
    String imageUrl,
  ) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': title,
          'description': description,
          'price': price,
          'imageUrl': imageUrl,
          'creatorId': userId
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> updateProduct(
    String id,
    String title,
    String description,
    double price,
    String imageUrl,
  ) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final prodIndex = _products.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      await http.patch(
        url,
        body: json.encode({
          'title': title,
          'description': description,
          'price': price,
          'imageUrl': imageUrl,
          // 'isFavourite': _products[prodIndex].isFavourite
        }),
      );
      _products[prodIndex] = Product(
        id: id,
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isFavourite: _products[prodIndex].isFavourite,
      );
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-c5b12-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    var existingProductIndex =
        _products.indexWhere((element) => element.id == id);
    dynamic existingProduct = _products[existingProductIndex];

    try {
      _products.removeAt(existingProductIndex);
      notifyListeners();
      final resp = await http.delete(url);

      if (resp.statusCode >= 400) {
        throw Exception('Not able to delete');
      }
      existingProduct = null;
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw error;
    }
  }

  Product findByIndex(String index) {
    return _products.firstWhere((element) => element.id == index);
  }
}
