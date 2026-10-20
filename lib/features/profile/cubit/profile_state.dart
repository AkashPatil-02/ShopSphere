import 'package:shopsphere/features/profile/data/profile_model.dart';

class ProfileState {}

class Initialize extends ProfileState {}

class LoadingProfile extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final Profile profile;

  ProfileSuccess({required this.profile});
}

class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure({required this.error});
}
