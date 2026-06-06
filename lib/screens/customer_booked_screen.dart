import 'package:flutter/material.dart';
import '../widgets/customer_bottom_nav.dart';

const Color primaryBlue = Color(0xFF1E88E5);

class CustomerBookedScreen extends StatefulWidget {
  const CustomerBookedScreen({super.key});

  @override
  State<CustomerBookedScreen> createState() => _CustomerBookedScreenState();
}

class _CustomerBookedScreenState extends State<CustomerBookedScreen>
    with SingleTickerProviderStateMixin {
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

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Booked",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryBlue,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingTab(),
          _ActiveTab(),
          _CompletedTab(),
          _CancelledTab(),
        ],
      ),

      bottomNavigationBar: const CustomerBottomNav(currentIndex: 1),
    );
  }
}

//////////////////// PENDING ////////////////////

class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _JobCard(status: "Pending"),
        SizedBox(height: 16),
        Text(
          "Quotes received",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 12),
        _QuoteCard(name: "Ramesh", price: "₹450", rating: "4.5"),
        _QuoteCard(name: "Suresh", price: "₹400", rating: "4.2"),
        _QuoteCard(name: "Arun", price: "₹480", rating: "4.8"),
      ],
    );
  }
}

//////////////////// ACTIVE ////////////////////

class _ActiveTab extends StatelessWidget {
  const _ActiveTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _JobCard(status: "Active"),

        const SizedBox(height: 16),

        const Text(
          "Technician",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: _box(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ramesh Kumar",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("⭐ 4.5  •  Plumber"),
              SizedBox(height: 8),
              Text("Today • 3:00 PM – 5:00 PM"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 📞 CALL + 💬 CHAT
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call),
                label: const Text("Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat),
                label: const Text("Chat"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ❌ CANCEL BOOKING
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
              "Cancel Booking",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////// COMPLETED ////////////////////

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _HistoryCard(
          service: "Plumber",
          name: "Ramesh",
          date: "12 Sep 2025",
          amount: "₹450",
          status: "Completed",
        ),
      ],
    );
  }
}

//////////////////// CANCELLED ////////////////////

class _CancelledTab extends StatelessWidget {
  const _CancelledTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _HistoryCard(
          service: "Electrician",
          name: "Suresh",
          date: "10 Sep 2025",
          amount: "—",
          status: "Cancelled",
        ),
      ],
    );
  }
}

//////////////////// REUSABLE ////////////////////

class _JobCard extends StatelessWidget {
  final String status;
  const _JobCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Plumber • Kitchen tap leakage",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text("Today • 3:00 PM – 5:00 PM"),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String name;
  final String price;
  final String rating;

  const _QuoteCard({
    required this.name,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("⭐ $rating"),
            ],
          ),
          Column(
            children: [
              Text(
                price,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(80, 32),
                ),
                child: const Text("Select"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String service;
  final String name;
  final String date;
  final String amount;
  final String status;

  const _HistoryCard({
    required this.service,
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$service • $name",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(date),
          const SizedBox(height: 4),
          Text(amount),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status == "Completed" ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade200),
  );
}
