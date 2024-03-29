import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';
import '../provider/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem({
    Key? key,
    required this.id,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScaffoldContext = ScaffoldMessenger.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      EditProductScreen.routeName,
                      arguments: id,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: ((ctx) {
                          return AlertDialog(
                            title: const Text('Are you sure want to delete'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await Provider.of<Products>(context,
                                              listen: false)
                                          .deleteProduct(id);
                                    } catch (error) {
                                      ScaffoldContext.showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Deleting Failed!')));
                                    } finally {
                                      Navigator.of(ctx).pop();
                                    }
                                  },
                                  child: const Text('Confirm Delete'))
                            ],
                          );
                        }));
                  },
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).errorColor,
                )
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
