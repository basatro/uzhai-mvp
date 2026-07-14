import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/role_selection_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens2/tech_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
        ),
      );

      return;
    }

    try {

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RoleSelectionScreen(),
          ),
        );

        return;
      }

      final role = doc['role'];

      if (!mounted) return;

      if (role == "customer") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerHomeScreen(),
          ),
        );

      } else if (role == "technician") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TechHomeScreen(),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RoleSelectionScreen(),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Image.asset(
          'assets/uzhai_logo.png',
          height: 200,
        ),
      ),
    );
  }
}