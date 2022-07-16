import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/provider/cart.dart';
import 'package:shopping_app/provider/product.dart';
import 'package:shopping_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: ((ctx, value, child) => IconButton(
                  onPressed: () {
                    product.toggleFavourite();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icon(
                    product.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                  ),
                )),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.secondary,
          ),
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
