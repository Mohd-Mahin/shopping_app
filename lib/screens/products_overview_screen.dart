import 'package:flutter/material.dart';
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
                  child: Text('Favourite Items'),
                  value: FilterOptions.Favourites),
              const PopupMenuItem(
                  child: Text('All Items'), value: FilterOptions.All),
            ],
          )
        ],
      ),
      body: ProductGrid(showFavourite),
    );
  }
}
