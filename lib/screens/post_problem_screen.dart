import 'package:flutter/material.dart';

class PostProblemScreen extends StatefulWidget {
  final String? preSelectedService;

  const PostProblemScreen({super.key, this.preSelectedService});

  @override
  State<PostProblemScreen> createState() => _PostProblemScreenState();
}

class _PostProblemScreenState extends State<PostProblemScreen> {
  static const Color primaryBlue = Color(0xFF1E88E5);

  final List<String> services = [
    "Plumber",
    "Electrician",
    "Catering",
    "Event / DJ",
    "AC / Fridge",
    "Painter",
    "Pest Control",
    "House Cleaning",
    "Photographer / Videographer",
    "Dummy Work 1",
    "Dummy Work 2",
    "Dummy Work 3",
    "Dummy Work 4",
    "Dummy Work 5",
  ];

  String? selectedService;
  bool asap = true;

  DateTime? selectedDate;
  String selectedSlot = "Morning";
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    selectedService = widget.preSelectedService;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Post a Problem",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SERVICE DROPDOWN
            const Text("Select Service", style: _labelStyle),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedService,
              hint: const Text("Choose service"),
              items: services
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedService = v),
              decoration: _inputDecoration,
            ),

            const SizedBox(height: 24),

            // DESCRIPTION
            const Text("Describe your problem", style: _labelStyle),
            const SizedBox(height: 8),

            TextField(
              maxLines: 4,
              decoration: _inputDecoration.copyWith(
                hintText:
                    "Eg: Kitchen tap is leaking continuously since morning...",
              ),
            ),

            const SizedBox(height: 24),

            // IMAGES
            const Text("Attach images (optional)", style: _labelStyle),
            const SizedBox(height: 12),

            Row(
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // TIME MODE
            const Text("Preferred Time", style: _labelStyle),
            const SizedBox(height: 12),

            Row(
              children: [
                _choiceChip("As soon as possible", asap, () {
                  setState(() => asap = true);
                }),
                const SizedBox(width: 12),
                _choiceChip("Schedule", !asap, () {
                  setState(() => asap = false);
                }),
              ],
            ),

            if (!asap) ...[
              const SizedBox(height: 24),

              // DATE
              const Text("Select Date", style: _labelStyle),
              const SizedBox(height: 10),

              Row(
                children: [
                  _dateChip("Today", DateTime.now()),
                  const SizedBox(width: 8),
                  _dateChip(
                    "Tomorrow",
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                  const SizedBox(width: 8),
                  _pickDateChip(),
                ],
              ),

              const SizedBox(height: 24),

              // TIME SLOT
              const Text("Select Time", style: _labelStyle),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: [
                  _slotChip("Morning (8–12)"),
                  _slotChip("Afternoon (12–4)"),
                  _slotChip("Evening (4–8)"),
                  _exactTimeChip(),
                ],
              ),
            ],

            const SizedBox(height: 36),

            // CONFIRM
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _choiceChip(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primaryBlue),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateChip(String text, DateTime date) {
    final bool active =
        selectedDate != null &&
        selectedDate!.day == date.day &&
        selectedDate!.month == date.month;

    return GestureDetector(
      onTap: () => setState(() => selectedDate = date),
      child: _chipBox(text, active),
    );
  }

  Widget _pickDateChip() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: _chipBox("Pick date", false),
    );
  }

  Widget _slotChip(String text) {
    final active = selectedSlot == text && selectedTime == null;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSlot = text;
          selectedTime = null;
        });
      },
      child: _chipBox(text, active),
    );
  }

  Widget _exactTimeChip() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => selectedTime = picked);
        }
      },
      child: _chipBox(
        selectedTime == null
            ? "Pick exact time"
            : selectedTime!.format(context),
        selectedTime != null,
      ),
    );
  }

  Widget _chipBox(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? primaryBlue : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ---------------- STYLES ----------------

const TextStyle _labelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: Color(0xFF263238),
);

final InputDecoration _inputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
  ),
);
