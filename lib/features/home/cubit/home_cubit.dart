import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/home/cubit/home_state.dart';
import 'package:shopsphere/core/network/home_endpoints.dart';
import 'package:shopsphere/features/home/data/product_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeEndpoints endpoints;
  List<String> _categories = [];
  String? selectedCategory;
  String _searchQuery = '';
  int _skip = 0;
  static const int _limit = 20;


  String _currentSort = "Rating";
  HomeCubit(this.endpoints) : super(Initialize());

  Future<void> loadCategories() async {
    emit(Loading());
    try {
      _categories = await endpoints.getCategories();
      emit(Success(_categories));

      await loadAllProducts();
    } catch (e) {
      emit(Failure(e.toString()));
    }
  }

  Future<void> loadAllProducts() async {
    emit(ProductsLoading());
    selectedCategory = null;
    try {
      final result = await endpoints.getAllProducts(skip: 0);
      emit(ProductsSuccess(
        products: result.products,
        category: null,
        skip: 0,
        total: result.total,
      ));
    } catch (e) {
      emit(ProductsFailure(e.toString(), _categories));
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    emit(ProductsLoading());
    selectedCategory = category;
    try {
      final products = await endpoints.getProductsByCategory(category);
      emit(ProductsSuccess(
        products: products,
        category: category,
        skip: 0,
        total: products.length, // category endpoint returns all at once
      ));
    } catch (e) {
      emit(ProductsFailure(e.toString(), _categories));
    }
  }

  Future<void> loadMoreProducts() async {
    final current = state;
    if (current is! ProductsSuccess) return;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final result = await endpoints.getAllProducts(skip: current.skip + 20);
      final updatedProducts = [...current.products,...result.products,];
      emit(current.copyWith(
        products: _sortProducts(updatedProducts),
        skip: current.skip + 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Roll back isLoadingMore on error so user can retry
      emit(current.copyWith(isLoadingMore: false));
    }
  }
  Future<void> refreshProducts() async {
  if (selectedCategory != null) {
    await loadProductsByCategory(selectedCategory!);
  } else {
    await loadAllProducts();
  }
}

List<Product> _sortProducts(List<Product> products){
  final sorted = List<Product>.of(products);

  switch(_currentSort){
    case 'Rating':
      sorted.sort((a,b)=>b.rating.compareTo(a.rating));
      break;

    case 'Title':
    sorted.sort((a,b)=>a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    break;

    case 'Price Low to High':
    sorted.sort((a,b)=>a.price.compareTo(b.price));
    break;

    case 'Price High to Low':
    sorted.sort((a,b)=>b.price.compareTo(a.price));
    break;

    case 'None':
    refreshProducts();
    break;
  }
  return sorted;
}

void sortProducts(String option) {
  _currentSort = option;

  final state = this.state;

  if (state is ProductsSuccess) {
    emit(
      ProductsSuccess(
        products: _sortProducts(state.products),
        category: state.category,
        total: state.total,
        skip: 0,
        isLoadingMore: state.isLoadingMore,
      ),
    );
  }
}

Future<void> searchProducts(String query) async {
  _searchQuery = query.trim();
  _skip = 0;

  if (_searchQuery.isEmpty) {
    await loadAllProducts();
    return;
  }

  emit(ProductsLoading());

  try {
    final result = await endpoints.searchProducts(
      query: _searchQuery,
      skip: _skip,
      limit: _limit,
    );

    _skip = result.products.length;

    emit(
      ProductsSuccess(
        products: _sortProducts(result.products),
        category: null,
        isLoadingMore: false,
        skip: _skip,
        total: result.total
      ),
    );
  } catch (e) {
    emit(ProductsFailure(e.toString(),_categories));
  }
}


  List<String> get categories => _categories;
}