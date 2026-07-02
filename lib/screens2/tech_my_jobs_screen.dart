import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quotes')
          .where('technicianId', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
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
            final quote = snapshot.data!.docs[index];
            return _PendingQuoteCard(
              jobId: quote['jobId'],
              amount: quote['amount'].toString(),
            );
          },
        );
      },
    );
  }
}

//////////////// ACTIVE //////////////////

class _ActiveJobs extends StatelessWidget {
  const _ActiveJobs();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quotes')
          .where('technicianId', isEqualTo: uid)
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
            final quote = snapshot.data!.docs[index];
            return _ActiveQuoteCard(
              jobId: quote['jobId'],
              quoteId: quote.id,
            );
          },
        );
      },
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quotes')
          .where('technicianId', isEqualTo: uid)
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
            final quote = snapshot.data!.docs[index];
            return _CancelledQuoteCard(
              jobId: quote['jobId'],
            );
          },
        );
      },
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

//////////////// PENDING QUOTE CARD (fetches job by jobId) //////////////////

class _PendingQuoteCard extends StatelessWidget {
  final String jobId;
  final String amount;

  const _PendingQuoteCard({
    super.key,
    required this.jobId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
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

        final job = snapshot.data!.data() as Map<String, dynamic>;

        return _PendingJobTile(
          customer: job['customerName'],
          area: job['location'],
          quote: "₹$amount",
        );
      },
    );
  }
}

//////////////// CANCEL DIALOG (STEP 2) //////////////////

Future<bool?> showTechnicianCancelDialog(
  BuildContext context,
  TextEditingController controller,
) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      title: const Text(
        "Cancel Job",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Reason (Optional)",
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter reason...",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Back"),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            "Cancel Job",
            style: TextStyle(color: Colors.white),
          ),
        ),

      ],
    ),
  );
}

//////////////// ACTIVE JOB TILE (STEP 2 — UPGRADED + STEPS 6/7) //////////////////

class _ActiveJobTile extends StatelessWidget {
  final String customer;
  final String area;

  final String quoteId;
  final String jobId;

  static const Color neonOrange = Color(0xFFFF6B00);

  const _ActiveJobTile({
    required this.customer,
    required this.area,
    required this.quoteId,
    required this.jobId,
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
              onPressed: () async {

                final controller = TextEditingController();

                final confirm = await showTechnicianCancelDialog(
                  context,
                  controller,
                );

                if (confirm != true) return;

                // STEP 3 — get technician name
                final techDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get();

                final technicianName = techDoc['username'];

                // STEP 4 — reopen job, store cancel metadata
                await FirebaseFirestore.instance
                    .collection('jobs')
                    .doc(jobId)
                    .update({
                  // reopen job
                  'status': 'open',
                  // remember who cancelled
                  'cancelledBy': 'Technician',
                  'cancelledTechnicianName': technicianName,
                  'cancelReason': controller.text.trim(),
                  // remove assigned technician
                  'selectedTechnicianId': '',
                  'selectedQuoteId': '',
                });

                // STEP 5 (UPDATED) — delete all quotes tied to this job so
                // every technician (including the one cancelling) starts
                // fresh and can submit a new quote if the job reopens.
                final currentUid = FirebaseAuth.instance.currentUser!.uid;

                final quotes = await FirebaseFirestore.instance
                    .collection('quotes')
                    .where('jobId', isEqualTo: jobId)
                    .get();

                for (final doc in quotes.docs) {
                  await doc.reference.delete();
                }

                // STEP 6 — skip technician who cancelled
                await FirebaseFirestore.instance
                    .collection('jobs')
                    .doc(jobId)
                    .update({
                  'skippedBy': FieldValue.arrayUnion([
                    FirebaseAuth.instance.currentUser!.uid
                  ])
                });

                // STEP 7 — snackbar
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Job cancelled successfully",
                    ),
                  ),
                );

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

//////////////// ACTIVE QUOTE CARD (fetches job by jobId) //////////////////

class _ActiveQuoteCard extends StatelessWidget {
  final String jobId;
  final String quoteId;

  const _ActiveQuoteCard({
    super.key,
    required this.jobId,
    required this.quoteId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
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

        final job = snapshot.data!.data() as Map<String, dynamic>;



        return _ActiveJobTile(
          customer: job['customerName'],
          area: job['location'],
          quoteId: quoteId,
          jobId: jobId,
        );
      },
    );
  }
}

//////////////// CANCELLED QUOTE CARD (fetches job by jobId) //////////////////

class _CancelledQuoteCard extends StatelessWidget {
  final String jobId;

  const _CancelledQuoteCard({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
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

        final job =
            snapshot.data!.data() as Map<String, dynamic>;

        // STEP 5 — null-safe fallbacks to avoid crashes
        return _JobTile(
          customer: job['customerName'] ?? "Unknown",
          area: job['location'] ?? "",
          time: "",
          status: "Cancelled",
          cancelledBy: job['cancelledBy'] ?? "",
          cancelReason: job['cancelReason'] ?? "",
        );
      },
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
            const Text(
              "Cancelled By",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              cancelledBy ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (cancelReason != null &&
                cancelReason!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                "Reason",
                style: TextStyle(color: Colors.grey),
              ),
              Text(cancelReason!),
            ],
          ],
        ],
      ),
    );
  }
}