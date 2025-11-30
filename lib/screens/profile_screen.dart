import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isUploading = false;

  Future<void> _pickAndSaveImage() async {
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    Uint8List finalBytes;

    // -------------------- WEB (No Cropping) --------------------
    if (kIsWeb) {
      finalBytes = await picked.readAsBytes();
    } else {
      // -------------------- ANDROID / IOS CROPPING (v11 API) --------------------
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: const Color(0xFF0F172A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (cropped == null) return;

      // Read cropped image bytes
      finalBytes = await io.File(cropped.path).readAsBytes();
    }

    setState(() => _isUploading = true);

    try {
      final base64String = base64Encode(finalBytes);

      await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.email)
          .update({'photoBase64': base64String});

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Profile picture updated!")));
      }
    } catch (e) {
      debugPrint("Error saving photo: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("Please log in"));

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(user!.email)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>? ?? {};

          final name = data['name'] ?? 'Student';
          final branch = data['branch'] ?? 'IIITNR';
          final String? base64Image = data['photoBase64'];

          ImageProvider? imgProvider;

          if (base64Image != null && base64Image.isNotEmpty) {
            try {
              imgProvider = MemoryImage(base64Decode(base64Image));
            } catch (_) {
              imgProvider = null;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // -------------------- PROFILE PHOTO --------------------
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: imgProvider,
                        child: imgProvider == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white70)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndSaveImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text(branch,
                    style: const TextStyle(color: Colors.white54, fontSize: 16)),

                const SizedBox(height: 40),

                // -------------------- REGISTERED EVENTS --------------------
                const _SectionHeader(title: "My Registered Events"),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .doc(user!.email)
                      .collection('registrations')
                      .snapshots(),
                  builder: (context, eventSnap) {
                    if (!eventSnap.hasData) {
                      return const LinearProgressIndicator();
                    }

                    if (eventSnap.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "You haven't registered for any events yet.",
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: eventSnap.data!.docs.map((doc) {
                        final event = doc.data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_circle,
                                    color: Colors.greenAccent),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event['eventName'] ?? "Event",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text("Registered on: ${event['date']}",
                                        style: const TextStyle(
                                            color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.history_edu_rounded, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2),
        ),
      ],
    );
  }
}
