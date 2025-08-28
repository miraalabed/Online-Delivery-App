import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  final Set<String> removedIds = {};

  List<Map<String, dynamic>> get favorites => _favorites
      .where((item) => !removedIds.contains(item['id'].toString()))
      .toList();

  void toggleFavorite(Map<String, dynamic> item) {
    final id = item['id'].toString();
    if (_favorites.any((fav) => fav['id'].toString() == id)) {
      _favorites.removeWhere((fav) => fav['id'].toString() == id);
      removedIds.remove(id);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    if (removedIds.contains(id)) return false;
    return _favorites.any((fav) => fav['id'].toString() == id);
  }

  void toggleRemoved(String id) {
    if (removedIds.contains(id)) {
      removedIds.remove(id);
    } else {
      removedIds.add(id);
    }
    notifyListeners();
  }

  void applyRemovedOnBack() {
    _favorites.removeWhere(
      (item) => removedIds.contains(item['id'].toString()),
    );
    removedIds.clear();
    notifyListeners();
  }
}
