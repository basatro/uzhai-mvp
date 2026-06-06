import 'package:flutter/material.dart';
import 'tech_chat_detail_screen.dart';
import '../widgets/technician_bottom_nav.dart';

const Color neonOrange = Color(0xFFFF6B00);

class TechChatListScreen extends StatelessWidget {
  const TechChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 📄 CHAT LIST
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TechChatCard(
            customerName: "Suresh Kumar",
            area: "Anna Nagar",
            time: "Today · 3:00 – 5:00 PM",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TechChatDetailScreen(
                    customerName: "Suresh Kumar",
                    service: "Plumber",
                  ),
                ),
              );
            },
          ),

          _TechChatCard(
            customerName: "Meena",
            area: "Vadapalani",
            time: "Tomorrow · 9:00 – 11:00 AM",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TechChatDetailScreen(
                    customerName: "Meena",
                    service: "Plumber",
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ⬇️ TECH NAV BAR
      bottomNavigationBar: const TechnicianBottomNav(currentIndex: 2),
    );
  }
}

//////////////////// CHAT CARD ////////////////////

class _TechChatCard extends StatelessWidget {
  final String customerName;
  final String area;
  final String time;
  final VoidCallback onTap;

  const _TechChatCard({
    required this.customerName,
    required this.area,
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
            // 👤 CUSTOMER
            Text(
              customerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 4),

            // 📍 AREA
            Text(
              area,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 6),

            // 🕒 TIME
            Text(
              time,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            // 🟢 STATUS
            const Text(
              "Active",
              style: TextStyle(
                color: neonOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
