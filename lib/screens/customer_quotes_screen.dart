import 'package:flutter/material.dart';

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

      body: ListView(
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

          const QuoteCard(
            technicianName: "Muthupandi",
            rating: "4.8",
            completedJobs: "235",
            amount: "₹260",
            message: "I'll be there in 30 mins.",
          ),

          const SizedBox(height: 14),

          const QuoteCard(
            technicianName: "Rahul",
            rating: "4.6",
            completedJobs: "190",
            amount: "₹300",
            message: "Available this evening.",
          ),

        ],
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

//////////////////// QUOTE CARD ////////////////////

class QuoteCard extends StatelessWidget {

  final String technicianName;
  final String rating;
  final String completedJobs;
  final String amount;
  final String message;

  const QuoteCard({
    super.key,
    required this.technicianName,
    required this.rating,
    required this.completedJobs,
    required this.amount,
    required this.message,
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

          Text(
            "⭐ $rating • $completedJobs Jobs",
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

          const SizedBox(height: 12),

          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              // ✅ Updated — Shows confirm dialog before selecting technician
              onPressed: () async {
                final confirmed = await showSelectDialog(
                  context,
                  technicianName: technicianName,
                  amount: amount,
                );
                if (confirmed != true) return;
                // Next:
                // Update Firestore
                // Move Job → Active
                // Reject remaining quotes
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