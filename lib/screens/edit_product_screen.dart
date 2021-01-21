import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _savekey = GlobalKey<FormState>();
  var _isinit = true;
  var _isLoading = false;
  var _editedProduct = Product(
    id: null,
    price: 0,
    description: "",
    imageUrl: "",
    title: "",
  );
  Map _initValues = {
    "title": "",
    "price": "",
    "imageUrl": "",
    "description": ""
  };

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _descriptionNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(() {
      _updateImageUrl();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "price": _editedProduct.price.toString(),
          "description": _editedProduct.description,
          "imageUrl": ""
        };
        _imageController.text = _editedProduct.imageUrl;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (_imageController.text.isEmpty) {
      setState(() {});
    }
    if ((!_imageController.text.startsWith("http") &&
            !_imageController.text.startsWith("https")) ||
        (!_imageController.text.endsWith("jpg") &&
            !_imageController.text.endsWith("jpeg") &&
            !_imageController.text.endsWith("png"))) {
      return;
    }
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void onSave() async {
    final isValid = _savekey.currentState.validate();
    print(isValid);
    if (!isValid) {
      return;
    }
    _savekey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An error occurred !"),
                  content: Text("Something went wrong"),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("Okay"),
                    )
                  ],
                ));
      }
    } else {
      await Provider.of<Products>(context)
          .updateProduct(_editedProduct.id, _editedProduct);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              onSave();
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _savekey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a title";
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descriptionNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a number";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than 0";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      focusNode: _descriptionNode,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description";
                        }
                        if (value.length < 10) {
                          return "please enter more than 10 chars";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: value,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          child: _imageController.text.isEmpty
                              ? Text("Enter image Url")
                              : FittedBox(
                                  child: Image.network(_imageController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "ImageUrl"),
                            controller: _imageController,
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              onSave();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image url";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid image url";
                              }
                              if (!value.endsWith(".jpg") &&
                                  !value.endsWith(".png") &&
                                  !value.endsWith("jpeg")) {
                                return "Please enter a valid image url";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: value);
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
