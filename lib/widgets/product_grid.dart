import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/provider/products.dart';
import 'package:shopping_app/widgets/product_item.dart';

import '../provider/product.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavourite;
  const ProductGrid(this.showFavourite);

  @override
  Widget build(BuildContext context) {
    final Products productData = Provider.of<Products>(context);
    final List<Product> products =
        showFavourite ? productData.favItems : productData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(),
      ),
      itemCount: products.length,
    );
  }
}
