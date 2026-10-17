import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/home/cubit/home_state.dart';
import 'package:shopsphere/core/network/home_endpoints.dart';

class HomeCubit extends Cubit<HomeState>{
  final HomeEndpoints endpoints;
  HomeCubit(this.endpoints): super(Initialize());
  
  Future<void> loadCategories()async{
    emit(Loading());
    try {
      final entries = await endpoints.getCategories();
      emit(Success(entries));
    } catch (e) {
      emit(Failure(e.toString()));
    }
  }
}