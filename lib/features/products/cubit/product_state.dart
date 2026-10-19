import 'package:shopsphere/features/home/data/product_model.dart';

class ProductState {}

class ProductInitialize extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  Product product;

  ProductLoaded({required this.product});
}

class ProductFailure extends ProductState {
  final String error;
  ProductFailure({required this.error});
}
