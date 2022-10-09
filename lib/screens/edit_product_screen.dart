import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/product.dart';
import '../provider/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();

  late String title;
  late double price;
  late String description;
  late String imageUrl;
  var productId;

  var _isInt = true;

  final _initialValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInt) {
      final id = ModalRoute.of(context)!.settings.arguments;
      if (id != null) {
        final editedProduct =
            Provider.of<Products>(context).findByIndex(id as String);
        _initialValues['title'] = editedProduct.title;
        _initialValues['price'] = editedProduct.price.toString();
        _initialValues['description'] = editedProduct.description;
        _imageUrlController.text = editedProduct.imageUrl;
        productId = editedProduct.id;
      }
      _isInt = false;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      var value = _imageUrlController.text;
      if ((!value.startsWith('http') && !value.startsWith('https'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isFormValid = _form.currentState!.validate();
    if (!isFormValid) {
      return;
    }
    _form.currentState?.save();

    if (productId != null) {
      Provider.of<Products>(context, listen: false).updateProduct(
        productId,
        title,
        description,
        price,
        imageUrl,
      );
    } else {
      Provider.of<Products>(context, listen: false).addProduct(
        title,
        description,
        price,
        imageUrl,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initialValues['title'],
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_priceFocusNode),
                onSaved: (value) => {
                  if (value != null) title = value,
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initialValues['price'],
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                focusNode: _priceFocusNode,
                onSaved: (value) => price = double.parse(value as String),
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_descriptionFocusNode),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter value greater than 0';
                  }
                },
              ),
              TextFormField(
                initialValue: _initialValues['description'],
                decoration: const InputDecoration(label: Text('Description')),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onSaved: (value) => {if (value != null) description = value},
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a description';
                  if (value.length < 10) {
                    return 'Should be atleast 10 character long';
                  }
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 15, right: 10),
                    child: _imageUrlController.text.isNotEmpty
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: Image.network(_imageUrlController.text),
                          )
                        : const Center(
                            child: Text(
                              'Enter the URL',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Image Url'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      onFieldSubmitted: (_) {
                        setState(() {});
                        _saveForm();
                      },
                      focusNode: _imageUrlFocusNode,
                      onSaved: (value) => {if (value != null) imageUrl = value},
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a image';
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
