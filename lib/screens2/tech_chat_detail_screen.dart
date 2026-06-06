import 'package:flutter/material.dart';

const Color neonOrange = Color(0xFFFF6B00);

class TechChatDetailScreen extends StatelessWidget {
  final String customerName;
  final String service;

  const TechChatDetailScreen({
    super.key,
    required this.customerName,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$service · Active job",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: neonOrange),
            onPressed: () {
              // VOIP later
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 💬 BODY
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _TechChatBubble(
                  text: "Hi, I am available for the job.",
                  isMe: true,
                ),
                _TechChatBubble(
                  text: "Okay, please come by 3 PM.",
                  isMe: false,
                ),
                _TechChatBubble(
                  text: "Sure, please share location.",
                  isMe: true,
                ),
              ],
            ),
          ),

          const _TechChatInputBar(),
        ],
      ),
    );
  }
}

//////////////// CHAT BUBBLE //////////////////

class _TechChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _TechChatBubble({
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? neonOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

//////////////// INPUT BAR //////////////////

class _TechChatInputBar extends StatelessWidget {
  const _TechChatInputBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.grey),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type a message",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: neonOrange,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
