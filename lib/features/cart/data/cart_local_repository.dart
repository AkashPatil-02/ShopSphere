import 'package:hive_ce/hive.dart';
import 'package:shopsphere/features/cart/data/cart_model.dart';

class CartLocalRepository {
  final Box<CartProduct> _box;

  CartLocalRepository(this._box);

  List<CartProduct> get items => _box.values.toList();

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  double get total => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> addToCart(CartProduct product) async {
    final existing = _box.get(product.id);

    if (existing != null) {
      await _box.put(
        product.id,
        existing.copyWith(quantity: existing.quantity + product.quantity),
      );
    } else {
      await _box.put(product.id, product);
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final product = _box.get(id);
    if (product == null) return;

    if (quantity <= 0) {
      await _box.delete(id);
    } else {
      await _box.put(id, product.copyWith(quantity: quantity));
    }
  }

  Future<void> removeFromCart(int id) async {
    await _box.delete(id);
  }

  Future<void> clearCart() async {
    await _box.clear();
  }
}
