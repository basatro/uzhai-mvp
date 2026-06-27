import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/technician_bottom_nav.dart';
import 'tech_quote_screen.dart';

class TechHomeScreen extends StatefulWidget {
  const TechHomeScreen({super.key});

  @override
  State<TechHomeScreen> createState() => _TechHomeScreenState();
}

class _TechHomeScreenState extends State<TechHomeScreen> {
  static const Color neonOrange = Color(0xFFFF6B00);

  String? specialization;

  @override
  void initState() {
    super.initState();
    loadTechnician();
  }

  Future<void> loadTechnician() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    specialization = doc['specialization'];
    setState(() {});
  }

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
        ],
      ),

      body: specialization == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<QuerySnapshot>(
              // 🔍 FIX 1 — Removed orderBy() to test if composite index is the issue
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('category', isEqualTo: specialization)
                  .where('status', isEqualTo: 'open')
                  .snapshots(),
              builder: (context, snapshot) {

                // 🔍 FIX 2 — Debug prints to inspect what Firestore is returning
                print("Specialization: $specialization");
                print("Docs found: ${snapshot.data?.docs.length}");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No $specialization Jobs Available",
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final job = snapshot.data!.docs[index];

                    // 🔍 FIX 2 — Print each document's full data
                    print(job.data());

                    // ✅ STEP 1 — jobId and customerId now passed to JobCard
                    return JobCard(
                      jobId: job.id,
                      customerId: job['customerId'],
                      customerName: job['customerName'],
                      area: job['location'],
                      distance: "",
                      time: "",
                      problem: job['description'],
                      images: const [],
                      category: job['category'],
                    );
                  },
                );
              },
            ),

      // ⬇️ TECHNICIAN NAV BAR
      bottomNavigationBar: const TechnicianBottomNav(currentIndex: 0),
    );
  }
}

//////////////////// JOB CARD ////////////////////

class JobCard extends StatelessWidget {
  // ✅ STEP 2 — jobId and customerId added above customerName
  final String jobId;
  final String customerId;
  final String customerName;
  final String area;
  final String distance;
  final String time;
  final String problem;
  final List<String> images;
  final String category;

  // ✅ STEP 3 — Constructor updated with jobId and customerId
  const JobCard({
    super.key,
    required this.jobId,
    required this.customerId,
    required this.customerName,
    required this.area,
    required this.distance,
    required this.time,
    required this.problem,
    required this.images,
    required this.category,
  });

  static const Color neonOrange = Color(0xFFFF6B00);

  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Skip Job"),
          content: const Text(
            "Are you sure you want to skip this job?\n\nThis job won't appear in your feed again.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Job skipped successfully"),
                  ),
                );
                // TODO:
                // Later we'll update Firestore:
                //
                // skippedBy: [technicianUID]
                //
                // so this technician never sees this job again.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

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

          // Images only render if non-empty
          if (images.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 1,
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

          if (images.isNotEmpty) const SizedBox(height: 16),

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
              if (distance.isNotEmpty)
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
            child: Text(
              category,
              style: const TextStyle(
                color: neonOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// 🕒 TIME — only show if non-empty
          if (time.isNotEmpty)
            Text(time, style: const TextStyle(color: Colors.grey)),

          if (time.isNotEmpty) const SizedBox(height: 8),

          /// 📝 PROBLEM
          Text(
            problem,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 18),

          /// ⏭️ SKIP | ✅ ACCEPT
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showSkipDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text("Skip"),
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
  jobId: jobId,
  customerId: customerId,
  customerName: customerName,
  area: area,
  distance: distance,
  time: time,
  problem: problem,
  images: images,
)
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