import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/technician_bottom_nav.dart';
import 'tech_quote_screen.dart';

class TechHomeScreen extends StatefulWidget {
  const TechHomeScreen({super.key});

  @override
  State<TechHomeScreen> createState() => _TechHomeScreenState();
}

class _TechHomeScreenState extends State<TechHomeScreen> {
  static const Color neonOrange = Color(0xFFFF6B00);

  String? specialization;

  @override
  void initState() {
    super.initState();
    loadTechnician();
  }

  Future<void> loadTechnician() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    specialization = doc['specialization'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "UZHAI",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: neonOrange,
            onPressed: () {},
          ),
        ],
      ),

      body: specialization == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('category', isEqualTo: specialization)
                  .where('status', isEqualTo: 'open')
                  // .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                print("Specialization: $specialization");
                print("Docs found: ${snapshot.data?.docs.length}");

                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("No Jobs"),
                  );
                }

                final uid = FirebaseAuth.instance.currentUser!.uid;

                final jobs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final skipped =
                      List<String>.from(data['skippedBy'] ?? []);
                  return !skipped.contains(uid);
                }).toList();

                print("Firestore Docs : ${snapshot.data!.docs.length}");
                print("Visible Jobs : ${jobs.length}");

                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      "No $specialization Jobs Available",
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];

                    print(job.data());

                    // ✅ STEP 2 — Safe extraction of the job's Map + images
                    final Map<String, dynamic> jobData =
                        job.data() as Map<String, dynamic>;
                    final List<dynamic> images = jobData['images'] ?? [];
                    final String audio = jobData['audio'] ?? "";

                    if (jobData['selectedTechnicianId'] == uid) {
                      return const SizedBox();
                    }

                    return JobCard(
                      jobId: job.id,
                      customerId: jobData['customerId'],
                      customerName: jobData['customerName'],
                      area: jobData['location'],
                      distance: "",
                      time: "",
                      problem: jobData['description'],
                      // ✅ STEP 3 — use the safe `images` list, cast to String
                      images: images.map((e) => e.toString()).toList(),
                      audio: audio,
                      category: jobData['category'],
                    );
                  },
                );
              },
            ),

      // ⬇️ TECHNICIAN NAV BAR
      bottomNavigationBar: const TechnicianBottomNav(currentIndex: 0),
    );
  }
}

//////////////////// JOB CARD ////////////////////

class JobCard extends StatefulWidget {
  final String jobId;
  final String customerId;
  final String customerName;
  final String area;
  final String distance;
  final String time;
  final String problem;
  final List<String> images;
  final String audio;
  final String category;

  const JobCard({
    super.key,
    required this.jobId,
    required this.customerId,
    required this.customerName,
    required this.area,
    required this.distance,
    required this.time,
    required this.problem,
    required this.images,
    required this.audio,
    required this.category,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final AudioPlayer player = AudioPlayer();
  bool playing = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  static const Color neonOrange = Color(0xFFFF6B00);

  Future<void> skipJob() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .update({
      'skippedBy': FieldValue.arrayUnion([uid]),
    });
  }

  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Skip Job"),
          content: const Text(
            "Are you sure you want to skip this job?\n\nThis job won't appear in your feed again.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await skipJob();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ✅ STEP 4 — Carousel only if images exist
          if (widget.images.isNotEmpty) _ImageCarousel(images: widget.images),

          // ✅ STEP 5 — Placeholder when there are no images
          if (widget.images.isEmpty)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),

          const SizedBox(height: 16),

          /// 👤 CUSTOMER + 📏 DISTANCE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.distance.isNotEmpty)
                Text(
                  widget.distance,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),

          const SizedBox(height: 4),

          /// 📍 AREA
          Text(widget.area, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 10),

          /// 🏷️ SERVICE TAG
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: neonOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              widget.category,
              style: const TextStyle(
                color: neonOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// 🕒 TIME — only show if non-empty
          if (widget.time.isNotEmpty)
            Text(widget.time, style: const TextStyle(color: Colors.grey)),

          if (widget.time.isNotEmpty) const SizedBox(height: 8),

          /// 📝 PROBLEM
          Text(
            widget.problem,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          /// 🔊 VOICE NOTE
          if (widget.audio.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: Text(
                  playing
                      ? "Pause Voice Note"
                      : "Play Voice Note",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () async {
                  if (playing) {
                    await player.pause();
                    setState(() {
                      playing = false;
                    });
                  } else {
                    await player.setUrl(widget.audio);
                    await player.play();
                    setState(() {
                      playing = true;
                    });
                    player.playerStateStream.listen((state) {
                      if (state.processingState ==
                          ProcessingState.completed) {
                        if (mounted) {
                          setState(() {
                            playing = false;
                          });
                        }
                      }
                    });
                  }
                },
              ),
            ),

          const SizedBox(height: 18),

          /// ⏭️ SKIP | ✅ ACCEPT
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showSkipDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text("Skip"),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechQuoteScreen(
                          jobId: widget.jobId,
                          customerId: widget.customerId,
                          customerName: widget.customerName,
                          area: widget.area,
                          distance: widget.distance,
                          time: widget.time,
                          problem: widget.problem,
                          images: widget.images,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//////////////////// IMAGE CAROUSEL ////////////////////

class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  const _ImageCarousel({
    required this.images,
  });
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int current = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (_, index, __) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImage(
                      imageUrl: widget.images[index],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.images[index],
                  width: double.infinity,
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
          options: CarouselOptions(
            height: 220,
            viewportFraction: 1,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: current == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: current == index
                    ? Colors.orange
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////// FULL SCREEN IMAGE ////////////////////

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({
    super.key,
    required this.imageUrl,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
      ),
    );
  }
}