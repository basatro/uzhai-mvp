import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart'; // STEP 2: Import just_audio
import '../services/cloudinary_service.dart';

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

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String location = "";

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];
  List<String> uploadedImageUrls = [];

  bool isUploading = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer(); // STEP 3: Create player
  String? recordedAudioPath;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    selectedService = widget.preSelectedService;
    fetchUserLocation();
  }

  // STEP 6: Dispose controllers and audio players to prevent memory leaks
  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        location = doc['location'] ?? "";
      });
    }
  }

  Future<void> pickImages() async {
    if (selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 3 images allowed"),
        ),
      );
      return;
    }
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      selectedImages.add(File(image.path));
    });
  }

  // STEP 4: Fixed recordVoice logic with WAV configurations and debug lines
  Future<void> recordVoice() async {
    if (isRecording) {
      final path = await _audioRecorder.stop();

      print("Recorded Path: $path");

      final file = File(path!);

      print("Exists: ${file.existsSync()}");
      print("Size: ${file.lengthSync()} bytes");

      setState(() {
        isRecording = false;
        recordedAudioPath = path;
      });

      return;
    }

    final permission = await _audioRecorder.hasPermission();

    print("Permission: $permission");

    if (!permission) {
      print("MIC Permission Denied");
      return;
    }

    final dir = await getTemporaryDirectory();

    final path = "${dir.path}/voice_test.wav";

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
      ),
      path: path,
    );

    print("Recording Started");

    setState(() {
      isRecording = true;
    });
  }

  // STEP 5: Playback utility execution logic
  Future<void> playRecordedAudio() async {
    if (recordedAudioPath == null) return;

    try {
      await _audioPlayer.setFilePath(recordedAudioPath!);
      await _audioPlayer.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error playing audio: $e")),
      );
    }
  }

  Future<void> postJob() async {
    // Service validation
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a service"),
        ),
      );
      return;
    }

    // Title validation
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job title is required"),
        ),
      );
      return;
    }

    // Location validation
    if (location.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location is required"),
        ),
      );
      return;
    }

    bool imageAdded = selectedImages.isNotEmpty;
    bool audioAdded = recordedAudioPath != null;

    if (descriptionController.text.trim().isEmpty &&
        !imageAdded &&
        !audioAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Add Description, Images or Voice Note",
          ),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isUploading = false;
      });
      return;
    }

    // Upload selected images to Cloudinary
    List<String> imageUrls = [];
    for (final image in selectedImages) {
      final url = await CloudinaryService.uploadImage(image);
      if (url != null) {
        imageUrls.add(url);
      }
    }

    // Upload recorded audio to Cloudinary
    String audioUrl = "";
    if (recordedAudioPath != null) {
      print("Uploading audio...");
      final uploadedAudio = await CloudinaryService.uploadAudio(
        File(recordedAudioPath!),
      );
      if (uploadedAudio != null) {
        audioUrl = uploadedAudio;
      }
      print(audioUrl);
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance
        .collection('jobs')
        .add({
      'customerId': user.uid,
      'customerName': userDoc['username'],
      'category': selectedService,
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'images': imageUrls,
      'audio': audioUrl,
      'location': location,
      'status': 'open',
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Job Posted Successfully"),
      ),
    );

    selectedImages.clear();
    uploadedImageUrls.clear();
    recordedAudioPath = null;

    setState(() {
      isUploading = false;
      recordedAudioPath = null;
      isRecording = false;
    });

    Navigator.pop(context);
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

            // JOB TITLE
            const Text("Job Title", style: _labelStyle),
            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              decoration: _inputDecoration.copyWith(
                hintText: "Eg: Fan Not Working",
              ),
            ),

            const SizedBox(height: 24),

            // DESCRIPTION
            const Text("Describe your problem", style: _labelStyle),
            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration.copyWith(
                hintText: "Describe the issue in detail...",
              ),
            ),

            const SizedBox(height: 24),

            // IMAGES
            const Text("Attach Images", style: _labelStyle),
            const SizedBox(height: 12),

            Row(
              children: List.generate(
                3,
                (i) => GestureDetector(
                  onTap: pickImages,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: i < selectedImages.length
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImages[i],
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
            ),

            // VOICE NOTE
            const SizedBox(height: 24),

            const Text("Voice Note", style: _labelStyle),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: recordVoice,
                    icon: Icon(
                      isRecording ? Icons.stop_circle : Icons.mic,
                      color: isRecording ? Colors.red : primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isRecording
                          ? "Recording..."
                          : recordedAudioPath == null
                              ? "No Voice Note"
                              : "Voice Note Ready (Tap ▶ to Listen)", // STEP 8: Show update message
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // STEP 7: Modernized audio playback actions row configuration
                  if (recordedAudioPath != null) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                      ),
                      onPressed: playRecordedAudio,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          recordedAudioPath = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SERVICE LOCATION
            const Text("Service Location", style: _labelStyle),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location.isEmpty ? "Loading..." : location,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final controller = TextEditingController(text: location);
                      final newLocation = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Change Location"),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Enter location",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context, controller.text),
                              child: const Text("Save"),
                            ),
                          ],
                        ),
                      );
                      if (newLocation != null && newLocation.isNotEmpty) {
                        setState(() {
                          location = newLocation;
                        });
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // POST JOB BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isUploading ? null : postJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Post Job",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 80),
          ],
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
    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
  ),
);