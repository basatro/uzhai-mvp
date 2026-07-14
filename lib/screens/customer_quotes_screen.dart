import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerQuotesScreen extends StatelessWidget {
  final String jobId;
  final String title;
  final String location;

  const CustomerQuotesScreen({
    super.key,
    required this.jobId,
    required this.title,
    required this.location,
  });

  static const Color primaryBlue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Quotes",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quotes')
            .where('jobId', isEqualTo: jobId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No quotes received yet"),
            );
          }
          final quotes = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// Job Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(14),
                ),
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

                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Quotes Received",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ...quotes.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: QuoteCard(
                    quoteId: doc.id,
                    jobId: jobId,
                    technicianId: data['technicianId'],
                    technicianName: data['technicianName'],
                    rating: "4.8",
                    completedJobs: "235",
                    reliability: "9.6",
                    distance: "1.4 km",
                    amount: "₹${data['amount']}",
                    // ✅ STEP 3 — raw numeric amount (no ₹ symbol),
                    // passed through so it can be stored on the job
                    // as 'selectedAmount' when this quote is assigned.
                    rawAmount: data['amount'],
                  ),
                );
              }).toList(),

            ],
          );
        },
      ),
    );
  }
}

//////////////////// SELECT DIALOG ////////////////////

Future<bool?> showSelectDialog(
  BuildContext context, {
  required String technicianName,
  required String amount,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "Select Technician",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Technician",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            technicianName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Quote",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Other quotations will be automatically rejected.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
          ),
          child: const Text(
            "Confirm",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

//////////////////// ASSIGN TECHNICIAN ////////////////////

Future<void> assignTechnician({
  required BuildContext context,
  required String jobId,
  required String quoteId,
  required String technicianId,
  // ✅ STEP 3 — new parameter carrying the raw quote amount.
  required dynamic amount,
}) async {
  final firestore = FirebaseFirestore.instance;

  // 1. Assign selected quote
  await firestore.collection('quotes').doc(quoteId).update({
    'status': 'assigned',
  });

  // 2. Update job
  await firestore.collection('jobs').doc(jobId).update({
    'status': 'assigned',
    'selectedQuoteId': quoteId,
    'selectedTechnicianId': technicianId,
    // ✅ STEP 3 — store the accepted quote's amount on the job so
    // the technician's Completed/History tab can display it later.
    'selectedAmount': amount,
  });

  // 3. Cancel remaining quotes
  final otherQuotes = await firestore
      .collection('quotes')
      .where('jobId', isEqualTo: jobId)
      .get();

  for (final doc in otherQuotes.docs) {
    if (doc.id != quoteId) {
      await doc.reference.update({
        'status': 'cancelled',
        'cancelledBy': 'Customer',
        'cancelReason': 'Another technician was selected',
      });
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Technician Assigned Successfully"),
    ),
  );
}

//////////////////// QUOTE CARD ////////////////////

class QuoteCard extends StatelessWidget {

  final String quoteId;
  final String jobId;
  final String technicianId;
  final String technicianName;
  final String rating;
  final String completedJobs;
  final String reliability;
  final String distance;
  final String amount;
  // ✅ STEP 3 — raw numeric amount used for Firestore writes.
  final dynamic rawAmount;

  const QuoteCard({
    super.key,
    required this.quoteId,
    required this.jobId,
    required this.technicianId,
    required this.technicianName,
    required this.rating,
    required this.completedJobs,
    required this.amount,
    required this.distance,
    required this.reliability,
    required this.rawAmount,
  });

  static const Color primaryBlue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            technicianName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("⭐ $rating"),
              const SizedBox(height: 6),
              Text("🛡️ $reliability /10 Reliable"),
              const SizedBox(height: 6),
              Text("📍 $distance"),
              const SizedBox(height: 6),
              Text("🔧 $completedJobs Jobs"),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            amount,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              onPressed: () async {
                final confirmed = await showSelectDialog(
                  context,
                  technicianName: technicianName,
                  amount: amount,
                );
                if (confirmed != true) return;
                await assignTechnician(
                  context: context,
                  jobId: jobId,
                  quoteId: quoteId,
                  technicianId: technicianId,
                  // ✅ STEP 3 — pass the raw amount through.
                  amount: rawAmount,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),

              child: const Text(
                "Select",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),

          ),

        ],

      ),

    );

  }

}