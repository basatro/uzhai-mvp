import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';



void main() {
  runApp(const UzhaiApp());
}

class UzhaiApp extends StatelessWidget {
  const UzhaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoleSelectionScreen(),
    );
  }
}
