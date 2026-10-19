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
  final int skip;
  final int total;
  final bool isLoadingMore;
  ProductsSuccess({
    required this.products,
    this.category,
    required this.skip,
    required this.total,
    this.isLoadingMore = false,
  });

  bool get hasMore => products.length < total;

  ProductsSuccess copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    int? skip,
  }) => ProductsSuccess(
    products: products ?? this.products,
    category: category,
    skip: skip ?? this.skip,
    total: total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class ProductsFailure extends HomeState {
  final String error;
  final List<String> categories;
  ProductsFailure(this.error, this.categories);
}
