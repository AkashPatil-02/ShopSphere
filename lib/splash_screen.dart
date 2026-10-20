import 'package:flutter/material.dart';
import 'package:shopsphere/core/auth/token_management.dart';
import 'package:shopsphere/core/widgets/navbar.dart';
import 'package:shopsphere/features/auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await TokenManagement.instance.getAccessToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const NavBar()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              size: 72,
              color: Colors.blueAccent,
            ),
            SizedBox(height: 24),
            Text(
              'ShopSphere',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 28),
            Text(
              'Groceries to Furnitures, we got you covered',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
