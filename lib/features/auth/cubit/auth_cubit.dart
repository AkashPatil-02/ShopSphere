import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/auth/cubit/auth_state.dart';

import '../../../core/auth/auth_repository.dart';


class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository)
      : super(const LoginState());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const LoginState(status: LoginStatus.loading));

    try {
      await _authRepository.login(username: username, password: password);
      emit(const LoginState(status: LoginStatus.success));
    } catch (e) {
      emit(
        LoginState(
          status: LoginStatus.failure,
          errorMessage: 'Login failed. Check your credentials.',
        ),
      );
    }
  }
}