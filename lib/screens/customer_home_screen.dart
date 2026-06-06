import 'package:flutter/material.dart';
import 'post_problem_screen.dart';
import '../widgets/customer_bottom_nav.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {"name": "Plumber", "icon": Icons.plumbing},
      {"name": "Electrician", "icon": Icons.electrical_services},
      {"name": "Catering", "icon": Icons.restaurant},
      {"name": "Event / DJ", "icon": Icons.music_note},
      {"name": "AC / Fridge", "icon": Icons.ac_unit},
      {"name": "Painter", "icon": Icons.format_paint},
      {"name": "Pest Control", "icon": Icons.bug_report},
      {"name": "House Cleaning", "icon": Icons.cleaning_services},
      {"name": "Photographer", "icon": Icons.camera_alt},
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "UZHAI",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Popular Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceCard(
                  icon: service["icon"],
                  title: service["name"],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostProblemScreen(
                          preSelectedService: service["name"],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            const Text(
              "Your Requests",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox, size: 40, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No active requests",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Post a problem to get help from nearby professionals",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🔹 FLOATING +
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PostProblemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔹 BOTTOM NAV
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }
}

// ---------------- SERVICE CARD ----------------

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: CustomerHomeScreen.primaryBlue),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
