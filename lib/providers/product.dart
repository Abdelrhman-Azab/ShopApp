import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.description,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void setfavValue(bool newFav) {
    isFavorite = newFav;
    notifyListeners();
  }

  void changeFavorite(String token, String userId) async {
    final url =
        "https://flutterupdate-d58bc.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    var oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        setfavValue(oldStatus);
      }
    } catch (error) {
      setfavValue(oldStatus);
    }
  }
}
