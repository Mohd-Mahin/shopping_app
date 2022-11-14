import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';
import 'package:shopping_app/widgets/app_drawer.dart';
import 'package:shopping_app/widgets/user_product_item.dart';
import '../provider/products.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isLoading = false;

  Future refreshData(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  void initState() {
    _isLoading = true;
    Provider.of<Products>(context, listen: false).fetchProducts(true).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? Flex(
              direction: Axis.vertical,
              children: const [
                Expanded(child: Center(child: CircularProgressIndicator()))
              ],
            )
          : RefreshIndicator(
              onRefresh: () => refreshData(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: productData.items.length,
                  itemBuilder: (ctx, index) => UserProductItem(
                      id: productData.items[index].id,
                      title: productData.items[index].title,
                      imageUrl: productData.items[index].imageUrl),
                ),
              ),
            ),
    );
  }
}
