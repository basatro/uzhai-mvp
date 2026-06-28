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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: "Pending"),
            Tab(text: "Active"),
            Tab(text: "History"),   // STEP 1 — renamed from "Completed"
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      // 📄 BODY
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingJobs(),
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

//////////////// PENDING //////////////////

class _PendingJobs extends StatelessWidget {
  const _PendingJobs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _PendingJobTile(
          customer: "Ramesh Kumar",
          area: "Anna Nagar",
          quote: "₹450",
        ),
      ],
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
        // STEP 3 — added amount + rating
        _JobTile(
          customer: "Meena",
          area: "Vadapalani",
          time: "28 June 2026",
          status: "Completed",
          amount: "₹450",
          rating: "4.8",
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
        // STEP 4 — added cancelledBy + cancelReason
        _JobTile(
          customer: "Suresh",
          area: "Kodambakkam",
          time: "",
          status: "Cancelled",
          cancelledBy: "Customer",
          cancelReason: "Selected another technician",
        ),
      ],
    );
  }
}

//////////////// PENDING JOB TILE //////////////////

class _PendingJobTile extends StatelessWidget {
  final String customer;
  final String area;
  final String quote;

  const _PendingJobTile({
    required this.customer,
    required this.area,
    required this.quote,
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
          Text(
            customer,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            area,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            "Your Quote : $quote",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "Waiting for customer response",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////// ACTIVE JOB TILE (STEP 2 — UPGRADED) //////////////////

class _ActiveJobTile extends StatelessWidget {
  final String customer;
  final String area;

  static const Color neonOrange = Color(0xFFFF6B00);

  const _ActiveJobTile({
    required this.customer,
    required this.area,
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

          const SizedBox(height: 12),

          // 🟢 STATUS CHIP
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

          // 📷 Scan QR — full width
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO:
                // Navigate to QR Scanner Screen
              },
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              ),
              label: const Text(
                "Scan QR",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ❌ CANCEL BUTTON — STEP 2: label shortened to "Cancel"
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
                "Cancel",
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

//////////////// GENERIC JOB TILE (STEPS 5 + 6 + 7) //////////////////

class _JobTile extends StatelessWidget {
  final String customer;
  final String area;
  final String time;
  final String status;
  // STEP 5 — optional fields
  final String? amount;
  final String? rating;
  final String? cancelledBy;
  final String? cancelReason;

  // STEP 5 — updated constructor
  const _JobTile({
    required this.customer,
    required this.area,
    required this.time,
    required this.status,
    this.amount,
    this.rating,
    this.cancelledBy,
    this.cancelReason,
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

          // STEP 6 — History details
          if (status == "Completed") ...[
            const SizedBox(height: 12),
            Text(
              "Earned : ${amount ?? ""}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("⭐ ${rating ?? ""}"),
            const SizedBox(height: 8),
            Text(
              "Completed on $time",
              style: const TextStyle(color: Colors.grey),
            ),
          ],

          // STEP 7 — Cancelled details
          if (status == "Cancelled") ...[
            const SizedBox(height: 12),
            Text(
              "Cancelled By",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              cancelledBy ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Reason",
              style: TextStyle(color: Colors.grey),
            ),
            Text(cancelReason ?? ""),
          ],
        ],
      ),
    );
  }
}