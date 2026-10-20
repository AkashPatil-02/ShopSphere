import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shopsphere/core/network/auth_endpoints.dart';

import 'package:shopsphere/features/cart/model/cart_model.dart';
import 'package:shopsphere/features/cart/cubit/storage_cubit.dart';
import 'package:shopsphere/core/hive/hive_repository.dart';
import 'package:shopsphere/core/themes/apptheme.dart';
import 'package:shopsphere/features/profile/cubit/profile_cubit.dart';
import 'package:shopsphere/features/profile/presentation/profile_screen.dart';
import 'package:shopsphere/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CartProductAdapter());
  await Hive.openBox<CartProduct>('cart');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>(
          create: (_) =>
              CartCubit(CartRepository(Hive.box<CartProduct>('cart')))
                ..loadCart(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(AuthRepository())..getUserData(),
          child: const ProfileScreen(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
