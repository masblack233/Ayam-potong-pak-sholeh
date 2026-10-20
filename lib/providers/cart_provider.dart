import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../core/constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalWeightKg =>
      _items.fold(0.0, (sum, item) => sum + item.totalWeightKg);

  double computeDeliveryFee(double distanceKm) {
    if (totalWeightKg >= AppConstants.freeDeliveryMinWeightKg &&
        distanceKm <= AppConstants.freeDeliveryMaxRadiusKm) {
      return 0;
    }
    return (distanceKm.ceil()) * AppConstants.deliveryPricePerKm;
  }

  int generateUniqueCode() {
    // 3-digit random code between 100-999
    return 100 + (DateTime.now().millisecondsSinceEpoch % 900);
  }

  void addItem(Product product, {int quantity = 1, double weightKg = 1.0}) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: _items[idx].quantity + quantity,
        weightKg: _items[idx].weightKg + weightKg,
      );
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        weightKg: weightKg,
      ));
    }
    notifyListeners();
  }

  void updateItem(String productId, {int? quantity, double? weightKg}) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    if ((quantity ?? _items[idx].quantity) <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(quantity: quantity, weightKg: weightKg);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
