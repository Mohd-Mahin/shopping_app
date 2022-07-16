import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/cart_screen.dart';
import 'package:shopping_app/widgets/badge.dart';
import '../provider/cart.dart';
import '../widgets/product_grid.dart';

enum FilterOptions { Favourites, All }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var showFavourite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              setState(() => {
                    if (value == FilterOptions.Favourites)
                      {showFavourite = true}
                    else
                      {showFavourite = false}
                  });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.Favourites,
                child: Text('Favourite Items'),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text('All Items'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (context, cartData, ch) => Badge(
              value: cartData.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      body: ProductGrid(showFavourite),
    );
  }
}
