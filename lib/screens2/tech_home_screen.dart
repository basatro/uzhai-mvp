import 'package:flutter/material.dart';
import '../widgets/technician_bottom_nav.dart';
import 'tech_quote_screen.dart';

class TechHomeScreen extends StatefulWidget {
  const TechHomeScreen({super.key});

  @override
  State<TechHomeScreen> createState() => _TechHomeScreenState();
}

class _TechHomeScreenState extends State<TechHomeScreen> {
  static const Color neonOrange = Color(0xFFFF6B00);

  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "UZHAI",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: neonOrange,
            onPressed: () {},
          ),
          Switch(
            value: isActive,
            activeColor: neonOrange,
            onChanged: (value) {
              setState(() => isActive = value);
            },
          ),
        ],
      ),

      // 📄 BODY
      body: isActive
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                PlumberJobCard(
                  customerName: "Suresh Kumar",
                  area: "Anna Nagar",
                  distance: "2.3 km",
                  time: "Today · 3:00 – 5:00 PM",
                  problem: "Kitchen tap leaking continuously",
                  images: [
                    "https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea",
                  ],
                ),
                PlumberJobCard(
                  customerName: "Meena",
                  area: "Vadapalani",
                  distance: "4.1 km",
                  time: "Tomorrow · 9:00 – 11:00 AM",
                  problem: "Bathroom pipe blockage",
                  images: [
                    "https://images.unsplash.com/photo-1584622650111-993a426fbf0a",
                  ],
                ),
                PlumberJobCard(
                  customerName: "Arun",
                  area: "Kodambakkam",
                  distance: "3.0 km",
                  time: "Today · Evening",
                  problem: "Water tank overflow issue",
                  images: [
                    "https://images.unsplash.com/photo-1621905252507-b35492cc74b4",
                    "https://images.unsplash.com/photo-1503387762-592deb58ef4e",
                  ],
                ),
              ],
            )
          : const Center(
              child: Text(
                "You are offline",
                style: TextStyle(color: Colors.grey),
              ),
            ),

      // ⬇️ TECHNICIAN NAV BAR
      bottomNavigationBar: const TechnicianBottomNav(currentIndex: 0),
    );
  }
}

//////////////////// JOB CARD ////////////////////

class PlumberJobCard extends StatelessWidget {
  final String customerName;
  final String area;
  final String distance;
  final String time;
  final String problem;
  final List<String> images;

  const PlumberJobCard({
    super.key,
    required this.customerName,
    required this.area,
    required this.distance,
    required this.time,
    required this.problem,
    required this.images,
  });

  static const Color neonOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🖼️ JOB IMAGES (1:1 Instagram style)
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          /// 👤 CUSTOMER + 📏 DISTANCE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                distance,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 4),

          /// 📍 AREA
          Text(area, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 10),

          /// 🏷️ SERVICE TAG
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: neonOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "Plumber",
              style: TextStyle(
                color: neonOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// 🕒 TIME
          Text(time, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 8),

          /// 📝 PROBLEM
          Text(
            problem,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 18),

          /// ❌ DENY | ✅ ACCEPT
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text("Deny"),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechQuoteScreen(
                          customerName: customerName,
                          area: area,
                          distance: distance,
                          time: time,
                          problem: problem,
                          images: images,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
