import 'package:shopsphere/features/cart/model/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartProduct> items;
  final int itemCount;
  final double total;

  CartLoaded({
    required this.items,
    required this.itemCount,
    required this.total,
  });
}

class CartFailure extends CartState {
  final String message;

  CartFailure(this.message);
}
