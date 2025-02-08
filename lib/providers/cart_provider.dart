import 'package:flutter/foundation.dart';
import '../bo/product.dart';

/// Represents an item in the shopping cart with its quantity
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price.toDouble() * quantity;
  double get totalWithVat => total * 1.2;

}

/// Manages the shopping cart state
class Cart with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  /// Returns all items in the cart
  Map<int, CartItem> get items => Map.unmodifiable(_items);

  /// Returns a list of all cart items
  List<CartItem> getAll() => _items.values.toList();

  /// Adds a product to the cart
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  /// Removes a product from the cart
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Updates the quantity of a product in the cart
  void updateQuantity(int productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        _items[productId]!.quantity = quantity;
        notifyListeners();
      }
    }
  }

  /// Clears all items from the cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Calculates the total price without VAT
  double get total => _items.values.fold(0, (sum, item) => sum + item.total);

  /// Calculates the total price with 20% VAT
  double get totalWithVat => total * 1.2;

  /// Checks if the cart is empty
  bool get isEmpty => _items.isEmpty;
}
