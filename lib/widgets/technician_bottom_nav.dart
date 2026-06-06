import 'package:flutter/material.dart';

import '../screens2/tech_home_screen.dart';
import '../screens2/tech_my_jobs_screen.dart';
import '../screens2/tech_chat_list_screen.dart';
import '../screens2/tech_profile_screen.dart';

class TechnicianBottomNav extends StatelessWidget {
  final int currentIndex;

  const TechnicianBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const Color neonOrange = Color(0xFFFF6B00);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; // ⛔ prevent reload

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const TechHomeScreen(); // Jobs
        break;

      case 1:
        nextScreen = const TechMyJobsScreen(); // My Jobs
        break;

      case 2:
        nextScreen = const TechChatListScreen(); // Chat
        break;

      case 3:
        nextScreen = const TechProfileScreen(); // Profile
        break;

      default:
        nextScreen = const TechHomeScreen();
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
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: neonOrange,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_repair_service),
          label: "Jobs",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: "My Jobs",
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
