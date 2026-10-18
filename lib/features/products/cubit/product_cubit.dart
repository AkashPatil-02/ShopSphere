import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/network/product_endpoints.dart';
import 'package:shopsphere/features/home/data/product_model.dart';
import 'package:shopsphere/features/products/cubit/product_state.dart';

class ProductCubit extends Cubit<ProductState>{
  final ProductEndpoints endpoints;
  ProductCubit(this.endpoints):super(ProductInitialize());

  Future<void> getProductDetails(int id)async{
    emit(ProductLoading());
    try {
      final Product data = await endpoints.getProduct(id);
      emit(ProductLoaded(product: data)); 
    } catch (e) {
      emit(ProductFailure(error: e.toString()));
    }
  }

}