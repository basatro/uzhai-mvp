import 'package:flutter/material.dart';

import '../screens/customer_home_screen.dart';
import '../screens/customer_booked_screen.dart';
import '../screens/customer_chat_list_screen.dart';
import '../screens/customer_profile_screen.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; // ⛔ prevent reload

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const CustomerHomeScreen();
        break;

      case 1:
        nextScreen = const CustomerBookedScreen(); // ✅ BOOKED
        break;

      case 2:
        nextScreen = CustomerChatListScreen();
        break;

      case 3:
        nextScreen = const CustomerProfileScreen();
        break;

      default:
        nextScreen = const CustomerHomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: "Booked",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
