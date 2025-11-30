import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _BlueBackground(),

        // --- EVENTS LIST STREAM ---
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            // 1. Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            // 2. Error
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            // 3. Empty
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No upcoming events.', style: TextStyle(color: Colors.white)));
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 26),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final eventId = docs[index].id;

                      return _eventCard(
                        context: context,
                        eventId: eventId,
                        data: data,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------- HEADER ----------------

  Widget _header() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events & Activities',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Stay updated with all upcoming college events.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EVENT CARD ----------------

  Widget _eventCard({
    required BuildContext context,
    required String eventId,
    required Map<String, dynamic> data,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    final title = data['title'] ?? "Untitled Event";
    final date = data['date'] ?? "TBA";
    final location = data['location'] ?? "IIITNR Campus";
    final description = data['description'] ?? "";
    final category = data['icon'] ?? "event";

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.15),
                      ),
                      child: Icon(
                        _getIcon(category),
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                    const SizedBox(width: 20),
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                // ========== REGISTER BUTTON ==========
                if (user != null)
                  StreamBuilder<QuerySnapshot>(
                    // CHECK: Is the user registered in THEIR OWN subcollection?
                    stream: FirebaseFirestore.instance
                        .collection('students')
                        .doc(user.email)
                        .collection('registrations')
                        .where('eventId', isEqualTo: eventId)
                        .snapshots(),
                    builder: (context, regSnap) {
                      // Check if data exists
                      final alreadyRegistered =
                          regSnap.hasData && regSnap.data!.docs.isNotEmpty;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: alreadyRegistered
                              ? null
                              : () => _confirmRegister(
                                    context: context,
                                    eventId: eventId,
                                    title: title,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: alreadyRegistered
                                ? Colors.white10
                                : Colors.blueAccent,
                            disabledBackgroundColor: Colors.white10,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            alreadyRegistered
                                ? "Already Registered"
                                : "Register Now",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: alreadyRegistered
                                    ? Colors.white38
                                    : Colors.white),
                          ),
                        ),
                      );
                    },
                  )
                else
                   const Center(child: Text("Login to register", style: TextStyle(color: Colors.grey))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- CONFIRMATION POPUP ----------------

  Future<void> _confirmRegister({
    required BuildContext context,
    required String eventId,
    required String title,
  }) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Registration",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "Do you want to register for \"$title\"?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel",
                style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Yes, Register",
                style: TextStyle(color: Colors.blueAccent)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        _register(context: context, eventId: eventId, title: title);
      }
    }
  }

  // ---------------- REGISTER FUNCTION (UPDATED) ----------------

  Future<void> _register({
    required BuildContext context,
    required String eventId,
    required String title,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final email = user.email!;

    try {
      // 1. Save to Student's Profile (For the Profile Screen)
      await FirebaseFirestore.instance
          .collection('students')
          .doc(email)
          .collection('registrations')
          .add({
        'eventId': eventId,
        'eventName': title, // Saved so Profile screen can display it easily
        'date': DateTime.now().toString().split(' ')[0], // Registration Date
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. (Optional) Save to Global Registrations for Admin Analytics
      // await FirebaseFirestore.instance.collection('registrations').add({...});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully registered for $title"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------- ICON MAPPER ----------------

  IconData _getIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'music':
      case 'cultural':
        return Icons.music_note_rounded;
      case 'tech':
      case 'coding':
        return Icons.computer_rounded;
      case 'business':
      case 'industry':
        return Icons.business_center_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'fest':
        return Icons.festival_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}

// ---------------- BACKGROUND ----------------

class _BlueBackground extends StatelessWidget {
  const _BlueBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A0F24),
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}