import 'package:flutter/material.dart';

class TechQuoteScreen extends StatelessWidget {
  const TechQuoteScreen({
    super.key,
    required this.customerName,
    required this.area,
    required this.distance,
    required this.time,
    required this.problem,
    required this.images,
  });

  final String customerName;
  final String area;
  final String distance;
  final String time;
  final String problem;
  final List<String> images;

  static const Color neonOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
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

      // ✅ CHANGE 5: Fixed bottom button — body is now Column with Expanded scroll + pinned button
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ✅ CHANGE 4: Only show image row if images list is non-empty
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return AspectRatio(
                            aspectRatio: 1 / 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
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

                  if (images.isNotEmpty) const SizedBox(height: 24),

                  // 👤 CUSTOMER INFO
                  _infoRow("Customer", customerName),
                  _infoRow("Area", area),

                  // ✅ CHANGE 6: Only show distance/time if non-empty
                  if (distance.isNotEmpty) _infoRow("Distance", distance),
                  if (time.isNotEmpty) _infoRow("Customer Time", time),

                  const SizedBox(height: 18),

                  // ✅ CHANGE 3: Problem description inside a styled card container
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
                      problem,
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

                  // ✅ CHANGE 2: Message field replaces alternate date/time
                  const SizedBox(height: 20),
                  const Text(
                    "Message (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
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

                  // ✅ CHANGE 1: Alternate date/time section removed entirely
                ],
              ),
            ),
          ),

          // ✅ CHANGE 5: Pinned bottom button (Swiggy/Zomato/Uber style)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // UI only — wire up Firestore later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    "Send Quote",
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

// ✅ CHANGE 1: _DatePickerField and _TimePickerField classes removed entirely