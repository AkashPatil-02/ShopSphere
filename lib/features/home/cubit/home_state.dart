import 'package:shopsphere/features/home/data/product_model.dart';

class HomeState {}

class Initialize extends HomeState {}

class Loading extends HomeState {}

class Success extends HomeState {
  final List<String> entries;
  Success(this.entries);
}

class Failure extends HomeState {
  final String error;
  Failure(this.error);
}

class Empty extends HomeState {}


class ProductsLoading extends HomeState {}

class ProductsSuccess extends HomeState {
  final List<Product> products;
  final String? category;
  ProductsSuccess(this.products, this.category);
}

class ProductsFailure extends HomeState {
  final String error;
  final List<String> categories;
  ProductsFailure(this.error, this.categories);
}