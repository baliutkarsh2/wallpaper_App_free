import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  final List<String> _favorites = [];

  List<String> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  bool isFavorite(String imageUrl) {
    return _favorites.contains(imageUrl);
  }

  void addFavorite(String imageUrl) {
    _favorites.add(imageUrl);
    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(String imageUrl) {
    _favorites.remove(imageUrl);
    _saveFavorites();
    notifyListeners();
  }

  void _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedFavorites = prefs.getStringList('favorites');
    if (savedFavorites != null) {
      _favorites.addAll(savedFavorites);
      notifyListeners();
    }
  }

  void _saveFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favorites);
  }
}
