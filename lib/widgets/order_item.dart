import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderItem;

  const OrderItem({
    Key? key,
    required this.orderItem,
  }) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = widget.orderItem.products.length > 1 ? 100 : 70;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.orderItem.amount}'),
            subtitle: Text(
              DateFormat('dd-MM-yyyy hh:mm').format(widget.orderItem.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                if (_isExpanded)
                  _animationController.forward();
                else
                  _animationController.reverse();
              },
            ),
          ),
          FadeTransition(
            opacity: opacityAnimation,
            child: AnimatedContainer(
              curve: Curves.linear,
              duration: const Duration(milliseconds: 100),
              height: _isExpanded ? height : 20,
              child: ListView(
                children: widget.orderItem.products
                    .map(
                      (prod) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prod.title,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Text(
                              '\$${prod.price} - ${prod.quantity}X',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
