// ✅ STEP 5 — Firebase imports added
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TechQuoteScreen extends StatefulWidget {
  const TechQuoteScreen({
    super.key,
    required this.jobId,
    required this.customerId,
    required this.customerName,
    required this.area,
    required this.distance,
    required this.time,
    required this.problem,
    required this.images,
  });

  final String jobId;
  final String customerId;
  final String customerName;
  final String area;
  final String distance;
  final String time;
  final String problem;
  final List<String> images;

  static const Color neonOrange = Color(0xFFFF6B00);

  @override
  State<TechQuoteScreen> createState() => _TechQuoteScreenState();
}

class _TechQuoteScreenState extends State<TechQuoteScreen> {

  final TextEditingController quoteController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    quoteController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // ✅ STEP 6 — submitQuote() function
  Future<void> submitQuote() async {
    if (quoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your quote"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // STEP 1 (NEW) — Block technicians who already cancelled this job
      final jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .get();
      final jobData = jobDoc.data() as Map<String, dynamic>;
      final skippedBy =
          List<String>.from(jobData['skippedBy'] ?? []);
      final currentUid =
          FirebaseAuth.instance.currentUser!.uid;
      if (skippedBy.contains(currentUid)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You have already cancelled this job.",
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final technician = FirebaseAuth.instance.currentUser!;

      final technicianDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(technician.uid)
          .get();

      await FirebaseFirestore.instance
          .collection('quotes')
          .add({
        'jobId': widget.jobId,
        'customerId': widget.customerId,
        'technicianId': technician.uid,
        'technicianName': technicianDoc['username'],
        'amount': double.parse(quoteController.text),
        'message': messageController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Quote Submitted Successfully"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // Debug prints (temporary)
    print("Job ID: ${widget.jobId}");
    print("Customer ID: ${widget.customerId}");

    return Scaffold(
      backgroundColor: Colors.white,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Give Quote",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (widget.images.isNotEmpty)
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return AspectRatio(
                            aspectRatio: 1 / 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.images[index],
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

                  if (widget.images.isNotEmpty) const SizedBox(height: 24),

                  // 👤 CUSTOMER INFO
                  _infoRow("Customer", widget.customerName),
                  _infoRow("Area", widget.area),

                  if (widget.distance.isNotEmpty) _infoRow("Distance", widget.distance),
                  if (widget.time.isNotEmpty) _infoRow("Customer Time", widget.time),

                  const SizedBox(height: 18),

                  // 📝 PROBLEM DESCRIPTION
                  const Text(
                    "Problem Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.problem,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 💰 QUOTE AMOUNT
                  const Text(
                    "Your Quote (₹)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quoteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter amount",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  // 💬 MESSAGE (OPTIONAL)
                  const SizedBox(height: 20),
                  const Text(
                    "Message (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Example: Can arrive within 30 minutes.",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ✅ PINNED BOTTOM BUTTON
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  // ✅ STEP 7 — Connected to submitQuote, disabled while loading
                  onPressed: isLoading ? null : submitQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TechQuoteScreen.neonOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  // ✅ STEP 8 — Shows spinner while loading
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit Quote",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}