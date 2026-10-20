import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/auth/token_management.dart';
import 'package:shopsphere/features/auth/data/auth_repository.dart';
import 'package:shopsphere/features/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository auth;

  ProfileCubit(this.auth) : super(Initialize());

  Future<void> getUserData() async {
    emit(LoadingProfile());
    try {
      final profile = await auth.getUserProfile();
      emit(ProfileSuccess(profile: profile));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await TokenManagement.instance.clearTokens();
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}
