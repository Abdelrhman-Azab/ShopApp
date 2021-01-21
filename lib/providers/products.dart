import 'dart:convert';
import '../models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get favoriteItems {
    return _items.where((proditem) => proditem.isFavorite).toList();
  }

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutterupdate-d58bc.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          "https://flutterupdate-d58bc.firebaseio.com/userFavorites/$userId.json?auth=$authToken";
      final favoriteUsers = await http.get(url);
      final favoriteData = json.decode(favoriteUsers.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (productId, productData) {
          loadedProducts.add(
            Product(
                id: productId,
                title: productData['title'],
                price: productData['price'],
                description: productData['description'],
                imageUrl: productData['imageUrl'],
                isFavorite: favoriteData == null
                    ? false
                    : favoriteData[productId] ?? false),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://flutterupdate-d58bc.firebaseio.com/products.json?auth=$authToken";
    try {
      final responce = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "creatorId": userId
        }),
      );

      final newProduct = Product(
          id: json.decode(responce.body)['name'],
          title: product.title,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    final url =
        "https://flutterupdate-d58bc.firebaseio.com/products/$id.json?auth=$authToken";
    await http.patch(url,
        body: json.encode({
          "title": newProduct.title,
          "price": newProduct.price,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
        }));
    if (productIndex >= 0) {
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutterupdate-d58bc.firebaseio.com/products/$id.json?auth=$authToken";
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(productIndex, existingProduct);
      notifyListeners();
      throw HttpException("Couldn't delete this product");
    }
    existingProduct = null;
  }
}
