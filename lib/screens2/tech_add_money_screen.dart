import 'package:flutter/material.dart';

class TechAddMoneyScreen extends StatefulWidget {
  const TechAddMoneyScreen({super.key});

  @override
  State<TechAddMoneyScreen> createState() => _TechAddMoneyScreenState();
}

class _TechAddMoneyScreenState extends State<TechAddMoneyScreen> {

  static const Color neonOrange = Color(0xFFFF6B00);

  final TextEditingController amountController =
      TextEditingController();

  int selectedAmount = 0;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Add Money",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.orange,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // STEP 2 — Amount TextField
              const Text(
                "Enter Amount",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,

                decoration: InputDecoration(

                  prefixText: "₹ ",

                  hintText: "500",

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // STEP 3 — Quick Recharge Chips
              const SizedBox(height: 26),

              const Text(
                "Quick Recharge",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 12,
                runSpacing: 12,

                children: [

                  quickChip(100),

                  quickChip(250),

                  quickChip(500),

                  quickChip(1000),

                ],
              ),

              // STEP 5 — Payment Methods
              const SizedBox(height: 30),

              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              paymentTile(
                Icons.account_balance,
                "UPI",
              ),

              paymentTile(
                Icons.credit_card,
                "Debit / Credit Card",
              ),

              paymentTile(
                Icons.account_balance_wallet,
                "Net Banking",
              ),

              // STEP 7 — Proceed Button
              const SizedBox(height: 40),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: neonOrange,

                    shape: RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(18),

                    ),

                  ),

                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Payment Gateway Coming Soon 🚀",
                        ),

                      ),

                    );

                  },

                  child: const Text(

                    "Proceed to Pay",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 18,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                ),

              ),

            ],
          ),
        ),
      ),
    );
  }

  // STEP 4 — Helper Widget: Quick Chip
  Widget quickChip(int amount) {

    final selected = selectedAmount == amount;

    return GestureDetector(

      onTap: () {

        setState(() {

          selectedAmount = amount;

          amountController.text = amount.toString();

        });

      },

      child: Container(

        width: 90,

        height: 50,

        decoration: BoxDecoration(

          color: selected
              ? neonOrange
              : Colors.white,

          borderRadius: BorderRadius.circular(14),

        ),

        child: Center(

          child: Text(

            "₹$amount",

            style: TextStyle(

              color: selected
                  ? Colors.white
                  : Colors.black,

              fontWeight: FontWeight.bold,

              fontSize: 17,

            ),

          ),

        ),

      ),

    );

  }

  // STEP 6 — Helper Widget: Payment Tile
  Widget paymentTile(
    IconData icon,
    String title,
  ) {

    return Container(

      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

      ),

      child: ListTile(

        leading: Icon(
          icon,
          color: neonOrange,
        ),

        title: Text(title),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: () {},

      ),

    );

  }
}