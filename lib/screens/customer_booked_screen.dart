import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/customer_bottom_nav.dart';
// ✅ STEP 1 — CustomerQuotesScreen import added
import 'customer_quotes_screen.dart';

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
            Tab(text: "History"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingTab(),
          _ActiveTab(),
          _HistoryTab(),
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('customerId', isEqualTo: uid)
          .where('status', isEqualTo: 'open')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Pending Jobs"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final job = snapshot.data!.docs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PendingJobCard(
                jobId: job.id,
                title: job['title'],
                location: job['location'],
              ),
            );
          },
        );
      },
    );
  }
}

//////////////////// ACTIVE ////////////////////

class _ActiveTab extends StatelessWidget {
  const _ActiveTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('customerId', isEqualTo: uid)
          .where('status', isEqualTo: 'assigned')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Active Jobs"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final job = snapshot.data!.docs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ActiveJobCard(
                jobId: job.id,
                title: job['title'],
                location: job['location'],
                technicianId: job['selectedTechnicianId'],
              ),
            );
          },
        );
      },
    );
  }
}

//////////////////// HISTORY ////////////////////

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _HistoryCard(
          name: "Ramesh Kumar",
          date: "28 June 2025",
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

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('customerId', isEqualTo: uid)
          .where('status', isEqualTo: 'cancelled')
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Cancelled Jobs"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {

            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return _HistoryCard(
              name: data['title'] ?? "",
              date: "",
              amount: "",
              status: "Cancelled",
              cancelledBy: data['cancelledBy'] ?? "",
              cancelledTechnicianName:
                  data['cancelledTechnicianName'] ?? "",
              cancelReason: data['cancelReason'] ?? "",
            );

          },
        );
      },
    );
  }
}

//////////////////// REUSABLE ////////////////////

class _PendingJobCard extends StatelessWidget {
  final String jobId;
  final String title;
  final String location;

  const _PendingJobCard({
    super.key,
    required this.jobId,
    required this.title,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(location),
          const SizedBox(height: 6),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('quotes')
                .where('jobId', isEqualTo: jobId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("Loading...");
              }
              return Text(
                "${snapshot.data!.docs.length} Quotes Received",
                style: const TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              // ✅ STEP 2 — Navigator.push() to CustomerQuotesScreen
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerQuotesScreen(
                      jobId: jobId,
                      title: title,
                      location: location,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
              ),
              child: const Text(
                "View Quotes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final String jobId;
  final String title;
  final String location;
  final String technicianId;

  const _ActiveJobCard({
    super.key,
    required this.jobId,
    required this.title,
    required this.location,
    required this.technicianId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(technicianId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final tech = snapshot.data!.data() as Map<String, dynamic>;
        final username = tech['username'] ?? "Unknown Technician";
        final specialization = tech['specialization'] ?? "Technician";

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _box(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(location),

              const SizedBox(height: 20),

              const Text(
                "Assigned Technician",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(specialization),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO : Call Technician
                  },
                  icon: const Icon(
                    Icons.call,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Call",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {

                    final controller = TextEditingController();

                    final confirm = await showCustomerCancelDialog(
                      context,
                      controller,
                    );

                    if (confirm != true) return;

                    // ✅ STEP 4 — Customer cancellation now fully
                    // deletes the job and its quotes instead of
                    // marking them as "cancelled".
                    final jobRef = FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(jobId);

                    final quotes = await FirebaseFirestore.instance
                        .collection('quotes')
                        .where('jobId', isEqualTo: jobId)
                        .get();

                    for (final doc in quotes.docs) {
                      await doc.reference.delete();
                    }

                    await jobRef.delete();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking Cancelled"),
                      ),
                    );

                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  child: const Text(
                    "Cancel Booking",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

//////////////////// CUSTOMER CANCEL DIALOG (STEP 4) ////////////////////

Future<bool?> showCustomerCancelDialog(
  BuildContext context,
  TextEditingController controller,
) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Cancel Booking"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text("Reason (Optional)"),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

        ],
      ),

      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Back"),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Cancel Booking",
            style: TextStyle(color: Colors.white),
          ),
        ),

      ],
    ),
  );
}

class _HistoryCard extends StatelessWidget {
  final String name;
  final String date;
  final String amount;
  final String status;
  final String? cancelledBy;
  final String? cancelledTechnicianName;
  final String? cancelReason;

  const _HistoryCard({
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
    this.cancelledBy,
    this.cancelledTechnicianName,
    this.cancelReason,
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
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (amount.isNotEmpty) Text(amount),
          if (status == "Completed") ...[
            const SizedBox(height: 8),
            const Text("⭐⭐⭐⭐⭐ 4.8"),
          ],
          const SizedBox(height: 4),
          if (date.isNotEmpty)
            Text(
              status == "Completed" ? "Completed on $date" : date,
            ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status == "Completed" ? Colors.green : Colors.red,
            ),
          ),
          if (status == "Cancelled" && cancelledBy != null) ...[
            const SizedBox(height: 8),

            const Text(
              "Cancelled By",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(cancelledBy!),

            // ✅ STEP 2 — Show technician name only when the
            // technician was the one who cancelled the job.
            if (cancelledBy == "Technician" &&
                cancelledTechnicianName != null &&
                cancelledTechnicianName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                "Technician",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cancelledTechnicianName ?? "",
              ),
            ],

            if ((cancelReason ?? "").trim().isNotEmpty) ...[

              const SizedBox(height: 8),

              const Text(
                "Reason",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(cancelReason!),

            ],
          ],
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