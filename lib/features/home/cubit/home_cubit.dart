import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/home/cubit/home_state.dart';
import 'package:shopsphere/core/network/home_endpoints.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeEndpoints endpoints;
  List<String> _categories = [];

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
    try {
      final products = await endpoints.getAllProducts();
      emit(ProductsSuccess(products, null));
    } catch (e) {
      emit(ProductsFailure(e.toString(), _categories));
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    emit(ProductsLoading());
    try {
      final products = await endpoints.getProductsByCategory(category);
      emit(ProductsSuccess(products, category));
    } catch (e) {
      emit(ProductsFailure(e.toString(), _categories));
    }
  }
  List<String> get categories => _categories;
}