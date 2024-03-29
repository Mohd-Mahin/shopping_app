import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/provider/cart.dart';
import 'package:shopping_app/provider/orders.dart';
import 'package:shopping_app/provider/products.dart';
import 'package:shopping_app/screens/cart_screen.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';
import 'package:shopping_app/screens/orders_screen.dart';
import 'package:shopping_app/screens/product_detail_screen.dart';
import 'package:shopping_app/screens/products_overview_screen.dart';
import 'package:shopping_app/screens/splash_screen.dart';
import 'package:shopping_app/screens/user_products_screen.dart';
import 'package:shopping_app/screens/auth_screen.dart';
import './provider/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProivder()),
          ChangeNotifierProxyProvider<AuthProivder, Products>(
            create: (_) => Products(null, null, []),
            update: (_, auth, previousSnapshot) => Products(
                auth.token,
                auth.userId,
                previousSnapshot == null ? [] : previousSnapshot.items),
          ),
          ChangeNotifierProvider(
            create: (_) => Cart(),
          ),
          ChangeNotifierProxyProvider<AuthProivder, Orders>(
            create: (_) => Orders(null, null, []),
            update: (_, auth, previousSnapshot) => Orders(
                auth.token,
                auth.userId,
                previousSnapshot == null ? [] : previousSnapshot.orders),
          )
        ],
        child: Consumer<AuthProivder>(
          builder: (context, value, _) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                fontFamily: 'Lato',
                primarySwatch: Colors.purple,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      secondary: Colors.orange,
                      primary: Colors.purple,
                    ),
              ),
              home: !value.isAuth
                  ? FutureBuilder(
                      future: value.tryAutoLogin(),
                      builder: (ctx, asyncSnapshot) =>
                          asyncSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                    )
                  : const ProductsOverviewScreen(),
              // home: const ProductsOverviewScreen(),
              routes: {
                ProductDetailScreen.routeName: (_) =>
                    const ProductDetailScreen(),
                CartScreen.routeName: (_) => const CartScreen(),
                OrdersScreen.routeName: (_) => const OrdersScreen(),
                UserProductsScreen.routeName: (_) => const UserProductsScreen(),
                EditProductScreen.routeName: (_) => const EditProductScreen()
              },
            );
          },
        ));
  }
}
