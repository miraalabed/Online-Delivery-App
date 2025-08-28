import 'package:flutter/material.dart';
import 'cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  List<String> get shopNames {
    final shops = _items.values
        .where((item) => item.quantity > 0)
        .map((item) => item.shopName)
        .toSet()
        .toList();
    return shops;
  }

  List<CartItem> itemsByShop(String shopName) {
    return _items.values
        .where((item) => item.shopName == shopName && item.quantity > 0)
        .toList();
  }

  int get itemCount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double totalPriceByShop(String shopName) {
    double total = 0.0;
    _items.forEach((key, item) {
      if (item.shopName == shopName) {
        total += item.price * item.quantity;
      }
    });
    return total;
  }

  void addItem(CartItem item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += item.quantity;

      if (item.notes != null && item.notes!.trim().isNotEmpty) {
        _items[item.id]!.notes = item.notes;
      }
    } else {
      _items[item.id] = item;
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity = quantity;
      notifyListeners();
    }
  }

  void updateNotes(String id, String notes) {
    if (_items.containsKey(id)) {
      _items[id]!.notes = notes;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clearShopItems(String shopName) {
    _items.removeWhere((key, item) => item.shopName == shopName);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<CartItem> get favorites =>
      _items.values.where((item) => item.liked).toList();

  void addToFavorites(CartItem item) {
    if (!_items.containsKey(item.id)) {
      _items[item.id] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        shopName: item.shopName,
        quantity: item.quantity,
        notes: item.notes,
        description: item.description,
        liked: true,
        workingHours: item.workingHours,
        shopId: item.shopId,
      );
    } else {
      _items[item.id]!.liked = true;
    }
    notifyListeners();
  }

  void removeFromFavorites(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.liked = false;
      notifyListeners();
    }
  }

  void updateLiked(String id, bool liked, {CartItem? item}) {
    if (_items.containsKey(id)) {
      _items[id]!.liked = liked;
      notifyListeners();
    } else if (liked && item != null) {
      _items[id] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        shopName: item.shopName,
        quantity: item.quantity,
        notes: item.notes,
        description: item.description,
        liked: true,
        workingHours: item.workingHours,
        shopId: item.shopId,
      );
      notifyListeners();
    }
  }
}
