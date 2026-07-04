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
        children: [
          const _PendingTab(),
          _ActiveTab(
            onCompleted: () {
              setState(() {
                _tabController.index = 2;
              });
            },
          ),
          const _HistoryTab(),
          const _CancelledTab(),
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
  final VoidCallback onCompleted;
  const _ActiveTab({
    super.key,
    required this.onCompleted,
  });

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
                onCompleted: onCompleted,
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      // ✅ STEP 1 — orderBy() removed (it requires a composite index
      // and was silently causing the stream to error out/hang).
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('customerId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ✅ STEP 2 — Show Firestore errors instead of a blank screen.
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              textAlign: TextAlign.center,
            ),
          );
        }

        // ✅ STEP 3 — Handle empty history.
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Completed Jobs"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final job =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            // ✅ STEP 8 — Print every history job for debugging.
            print(job);

            return _HistoryCard(
              name: job['title'] ?? "",
              amount: job['amount'] != null ? "₹${job['amount']}" : "",
              status: "Completed",
              date: job['completedAt'] != null
                  ? (job['completedAt'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 10)
                  : "",
            );
          },
        );
      },
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
  final VoidCallback onCompleted;

  const _ActiveJobCard({
    super.key,
    required this.jobId,
    required this.title,
    required this.location,
    required this.technicianId,
    required this.onCompleted,
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
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showCompleteJobDialog(context);
                    if (confirm != true) return;

                    final jobRef = FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(jobId);

                    final jobSnapshot = await jobRef.get();
                    final selectedQuoteId = jobSnapshot['selectedQuoteId'];

                    // Fetch the quote (if any) so we can store its
                    // amount on the job when marking it completed.
                    final quote = selectedQuoteId != null
                        ? await FirebaseFirestore.instance
                            .collection('quotes')
                            .doc(selectedQuoteId)
                            .get()
                        : null;

                    await jobRef.update({
                      'status': 'completed',
                      'completedAt': Timestamp.now(),
                      if (quote != null && quote.exists)
                        'amount': quote['amount'],
                    });

                    // ✅ STEP 4 — Verify the Firestore update actually
                    // applied by re-fetching and printing the job.
                    final updatedJob = await jobRef.get();
                    print(updatedJob.data());

                    // ✅ STEP 5 — Update the quote safely, only if a
                    // selectedQuoteId actually exists.
                    if (selectedQuoteId != null) {
                      await FirebaseFirestore.instance
                          .collection('quotes')
                          .doc(selectedQuoteId)
                          .update({
                        'status': 'completed',
                        'completedAt': Timestamp.now(),
                      });
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Job Completed Successfully",
                        ),
                      ),
                    );

                    await Future.delayed(
                      const Duration(milliseconds: 300),
                    );

                    onCompleted();
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: primaryBlue,
                  ),
                  label: const Text(
                    "Complete Job",
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: primaryBlue,
                      width: 1.5,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

                    final jobRef = FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(jobId);

                    final batch = FirebaseFirestore.instance.batch();

                    final quotes = await FirebaseFirestore.instance
                        .collection('quotes')
                        .where('jobId', isEqualTo: jobId)
                        .get();

                    for (final doc in quotes.docs) {
                      batch.delete(doc.reference);
                    }

                    batch.delete(jobRef);

                    await batch.commit();

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

//////////////////// CUSTOMER CANCEL DIALOG ////////////////////

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

//////////////////// COMPLETE JOB DIALOG ////////////////////

Future<bool?> showCompleteJobDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Complete Job"),
      content: const Text(
        "Are you sure the technician has completed the work?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("No"),
        ),
        // ✅ STEP 6 — Complete button color changed to primaryBlue.
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
          ),
          child: const Text(
            "Complete",
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
              // ✅ STEP 7 — Completed status now shown in primaryBlue.
              color: status == "Completed" ? primaryBlue : Colors.red,
            ),
          ),
          if (status == "Cancelled" && cancelledBy != null) ...[
            const SizedBox(height: 8),

            const Text(
              "Cancelled By",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(cancelledBy!),

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