import 'package:flutter/material.dart';
import 'customer_chat_detail_screen.dart';
import '../widgets/customer_bottom_nav.dart';

const Color primaryBlue = Color(0xFF1E88E5);

class CustomerChatListScreen extends StatelessWidget {
  const CustomerChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChatJobCard(
            name: "Ramesh",
            service: "Plumber",
            time: "Today · 3:00 – 5:00 PM",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerChatDetailScreen(
                    technicianName: "Ramesh",
                    service: "Plumber",
                  ),
                ),
              );
            },
          ),

          _ChatJobCard(
            name: "Suresh",
            service: "Electrician",
            time: "Tomorrow · 10:00 – 12:00 PM",
            onTap: () {},
          ),
        ],
      ),

      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }
}

class _ChatJobCard extends StatelessWidget {
  final String name;
  final String service;
  final String time;
  final VoidCallback onTap;

  const _ChatJobCard({
    required this.name,
    required this.service,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$name ($service)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            const Text(
              "Active",
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
