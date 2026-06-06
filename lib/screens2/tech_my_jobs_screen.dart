import 'package:flutter/material.dart';
import '../widgets/technician_bottom_nav.dart';

class TechMyJobsScreen extends StatefulWidget {
  const TechMyJobsScreen({super.key});

  @override
  State<TechMyJobsScreen> createState() => _TechMyJobsScreenState();
}

class _TechMyJobsScreenState extends State<TechMyJobsScreen>
    with SingleTickerProviderStateMixin {
  static const Color neonOrange = Color(0xFFFF6B00);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Jobs",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: neonOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: neonOrange,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      // 📄 BODY
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveJobs(),
          _CompletedJobs(),
          _CancelledJobs(),
        ],
      ),

      // ⬇️ TECH NAV BAR (My Jobs = index 1)
      bottomNavigationBar: const TechnicianBottomNav(currentIndex: 1),
    );
  }
}

//////////////// ACTIVE //////////////////

class _ActiveJobs extends StatelessWidget {
  const _ActiveJobs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ActiveJobTile(
          customer: "Ramesh Kumar",
          area: "Anna Nagar",
          time: "Today · 3:00 – 5:00 PM",
        ),
      ],
    );
  }
}

//////////////// COMPLETED //////////////////

class _CompletedJobs extends StatelessWidget {
  const _CompletedJobs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _JobTile(
          customer: "Meena",
          area: "Vadapalani",
          time: "12 Sep 2025",
          status: "Completed",
        ),
      ],
    );
  }
}

//////////////// CANCELLED //////////////////

class _CancelledJobs extends StatelessWidget {
  const _CancelledJobs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _JobTile(
          customer: "Suresh",
          area: "Kodambakkam",
          time: "10 Sep 2025",
          status: "Cancelled",
        ),
      ],
    );
  }
}

//////////////// ACTIVE JOB TILE (WITH CANCEL) //////////////////

class _ActiveJobTile extends StatelessWidget {
  final String customer;
  final String area;
  final String time;

  const _ActiveJobTile({
    required this.customer,
    required this.area,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 CUSTOMER
          Text(
            customer,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 4),

          // 📍 AREA
          Text(area, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 6),

          // 🕒 TIME
          Text(time, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          // 🟢 STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Active",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ❌ CANCEL BUTTON
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // UI only – later confirmation dialog
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Cancel Job",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////// GENERIC JOB TILE //////////////////

class _JobTile extends StatelessWidget {
  final String customer;
  final String area;
  final String time;
  final String status;

  const _JobTile({
    required this.customer,
    required this.area,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor =
        status == "Completed" ? Colors.blueGrey : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customer,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(area, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
