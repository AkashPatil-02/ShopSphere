import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/features/home/presentation/home_screen.dart';
import 'package:shopsphere/features/profile/presentation/profile_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  bool darkIcon = false;
  String date = "";
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final List<Widget> _screens = [const HomeScreen(), const ProfileScreen()];

  @override
  void initState() {
    //initialize();
    super.initState();
  }

  // Future<void> initialize() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     darkIcon = prefs.getBool('dark') ?? false;
  //     date = prefs.getString('date') ?? "";
  //   });
  //   DateTime now = DateTime.now();
  //   prefs.setString('date', now.day.toString());
  // }

  // void changeTheme() {
  //   context.read<Themecubit>().toggleTheme();
  //   setState(() {
  //     darkIcon = !darkIcon;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    const bottomGradientColor = Color.fromARGB(255, 52, 41, 83);
    const navBarBarColor = Color.fromARGB(255, 28, 22, 48);
    const activeCircleColor = Color(0xFF6750A4);

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        key: _bottomNavigationKey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: bottomGradientColor,
        color: navBarBarColor,
        buttonBackgroundColor: activeCircleColor,
        height: 60,
        items: <Widget>[
          Icon(
            Icons.shopping_bag_rounded,
            color: _currentIndex == 0 ? Colors.blueAccent : Colors.white60,
            size: 30,
          ),
          Icon(
            Icons.person_2_rounded,
            color: _currentIndex == 1 ? Colors.blueAccent : Colors.white60,
            size: 30,
          ),
        ],
      ),
    );
  }
}
