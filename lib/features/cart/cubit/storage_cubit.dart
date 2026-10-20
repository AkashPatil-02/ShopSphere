import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/cart/data/cart_api_service.dart';
import 'package:shopsphere/features/cart/data/add_to_cart.dart';
import 'package:shopsphere/features/cart/data/cart_model.dart';
import 'package:shopsphere/features/cart/data/cart_local_repository.dart';
import 'package:shopsphere/features/cart/cubit/storage_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartLocalRepository repository;

  CartCubit(this.repository) : super(CartInitial());

  void loadCart() {
    emit(CartLoading());
    _emitCart();
  }

  void _emitCart() {
    emit(
      CartLoaded(
        items: repository.items,
        itemCount: repository.itemCount,
        total: repository.total,
      ),
    );
  }

  Future<void> addToCart(CartProduct product) async {
    try {
      await repository.addToCart(product);
      _emitCart();
    } catch (e) {
      emit(CartFailure('Failed to add product to cart: $e'));
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    try {
      await repository.updateQuantity(id, quantity);
      _emitCart();
    } catch (e) {
      emit(CartFailure('Failed to update quantity: $e'));
    }
  }

  Future<void> removeFromCart(int id) async {
    try {
      await repository.removeFromCart(id);
      _emitCart();
    } catch (e) {
      emit(CartFailure('Failed to remove product: $e'));
    }
  }

  Future<void> clearCart() async {
    try {
      await repository.clearCart();
      _emitCart();
    } catch (e) {
      emit(CartFailure('Failed to clear cart: $e'));
    }
  } 

Future<Map<String, dynamic>> syncCartToDummyJson({
  required int userId,
  required CartApiService cartep,
}) async {
  final items = repository.items;

  if (items.isEmpty) {
    throw Exception('Your cart is empty.');
  }

  final request = AddCartRequest(
    userId: userId,
    products: items.map((item) {
      return AddCartProduct(
        id: item.id,
        quantity: item.quantity,
      );
    }).toList(),
  );
  final response = await cartep.checkout(request);
  await clearCart();
  return response;

}

}
