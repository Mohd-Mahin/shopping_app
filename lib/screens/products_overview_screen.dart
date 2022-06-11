import 'package:flutter/material.dart';
import 'package:shopping_app/widgets/product_item.dart';

import '../widgets/product_grid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
      ),
      body: ProductGrid(),
    );
  }
}
