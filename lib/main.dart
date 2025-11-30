import 'dart:convert'; // Required for Base64 decoding
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // 👈 Needed for kIsWeb

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/events_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // 🌐 WEB: Needs the options manually
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // 📱 MOBILE (Android/iOS): Finds the config file automatically
    await Firebase.initializeApp();
  }

  runApp(const IIITNRHubApp());
}


class IIITNRHubApp extends StatelessWidget {
  const IIITNRHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIITNR Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        canvasColor: const Color(0xFF020617),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFF020617),
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0xFFE5E7EB)),
        ),
        dividerColor: const Color(0xFF1F2933),
      ),
      home: const AuthGate(),
    );
  }
}

/// ───────────────── AUTH GATE ─────────────────

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  String _formatName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Student';
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts
        .map((p) => p.isEmpty
            ? p
            : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || userSnap.data == null) {
          return const LoginScreen();
        }

        final user = userSnap.data!;
        final email = user.email ?? '';

        // CHANGE: Using StreamBuilder for the profile doc so updates are instant
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .doc(email)
              .snapshots(),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = profileSnap.data?.data() ?? {};
            final rawName = (data['name'] ?? 'Student') as String;
            final formattedName = _formatName(rawName);
            final branch = (data['branch'] ?? 'CSE') as String;
             
            // Get both URL (legacy) and Base64 (new)
            final photoUrl = data['photoUrl'] as String?;
            final photoBase64 = data['photoBase64'] as String?;

            return DashboardShell(
              fullName: formattedName,
              email: email,
              branch: branch,
              photoUrl: photoUrl,
              photoBase64: photoBase64, // Pass the base64 string
            );
          },
        );
      },
    );
  }
}

/// ───────────────── DASHBOARD SHELL ─────────────────

class DashboardShell extends StatefulWidget {
  final String fullName;
  final String email;
  final String branch;
  final String? photoUrl;
  final String? photoBase64; // Add this field

  const DashboardShell({
    super.key,
    required this.fullName,
    required this.email,
    required this.branch,
    this.photoUrl,
    this.photoBase64,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  String _currentView = 'home';

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text("Recent Updates", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NEW EVENTS",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 10),
                _NotificationSection(
                    collection: 'events', icon: Icons.event_rounded),
                const SizedBox(height: 20),
                const Text("NEW ASSIGNMENTS",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 10),
                _NotificationSection(
                    collection: 'assignments', icon: Icons.assignment_rounded),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final branchLabel = widget.branch;
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 720;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
              ),
            ),
          ),
        ),
        // FIX 1: Wrap title in Flexible so it doesn't push off the screen
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8), // Reduced spacing
            Flexible(
              child: Text(
                'IIITNR Hub',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis, // Prevents overflow
              ),
            ),
            const SizedBox(width: 8), // Reduced spacing
            if (!isMobile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                  color: const Color(0xFF1D4ED8).withOpacity(0.15),
                ),
                child: Text(
                  branchLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBFDBFE),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Notifications",
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            onPressed: () => _showNotifications(context),
          ),
          // FIX 2: Reduced padding here to save space
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), 
            child: Row(
              children: [
                if (!isMobile)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.fullName,
                        style: const TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                if (!isMobile) const SizedBox(width: 12),
                 
                _UserAvatar(
                  name: widget.fullName,
                  photoUrl: widget.photoUrl,
                  photoBase64: widget.photoBase64,
                  size: 32, // Slightly smaller avatar for mobile
                ),
                 
                IconButton(
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) setState(() => _currentView = 'home');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isMobile ? _buildDrawer(branchLabel) : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        tooltip: 'AI Assistant',
        child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
          if (result != null && result is String) {
            setState(() => _currentView = result);
          }
        },
      ),
      body: isMobile
          ? _buildMainContent()
          : Row(
              children: [
                Container(
                  width: 240,
                  decoration: const BoxDecoration(
                    color: Color(0xFF020617),
                    border: Border(right: BorderSide(color: Color(0xFF1F2933))),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _buildSidebarHeader(branchLabel),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: _buildMainLinks(),
                        ),
                      ),
                      const Divider(color: Color(0xFF1F2933), height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildNavItem(Icons.person_rounded, 'My Profile', 'profile'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Expanded(child: _buildMainContent()),
              ],
            ),
    );
  }

  Drawer _buildDrawer(String branchLabel) {
    return Drawer(
      backgroundColor: const Color(0xFF020617),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSidebarHeader(branchLabel),
            ),
            const Divider(color: Color(0xFF1F2933), height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _buildMainLinks(isDrawer: true),
              ),
            ),
            const Divider(color: Color(0xFF1F2933)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildNavItem(Icons.person_rounded, 'My Profile', 'profile', isDrawer: true),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMainLinks({bool isDrawer = false}) {
    return [
      _buildNavItem(Icons.dashboard_rounded, 'Overview', 'home', isDrawer: isDrawer),
      _buildNavItem(Icons.calendar_month_rounded, 'Timetable', 'timetable', isDrawer: isDrawer),
      _buildNavItem(Icons.event_rounded, 'Events', 'events', isDrawer: isDrawer),
      _buildNavItem(Icons.assignment_rounded, 'Assignments', 'assignments', isDrawer: isDrawer),
      _buildNavItem(Icons.campaign_rounded, 'Announcements', 'announcements', isDrawer: isDrawer),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: Color(0xFF1F2933)),
      ),
      _buildNavItem(Icons.mail_outline_rounded, 'Contact', 'contact', isDrawer: isDrawer),
    ];
  }

  Widget _buildNavItem(IconData icon, String label, String value, {bool isDrawer = false}) {
    final bool isActive = _currentView == value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() => _currentView = value);
            if (isDrawer) Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive ? const Color(0xFF1D4ED8).withOpacity(0.18) : Colors.transparent,
              border: Border.all(
                color: isActive ? const Color(0xFF3B82F6).withOpacity(0.7) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: isActive ? const Color(0xFF60A5FA) : const Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? const Color(0xFFE5E7EB) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(String branchLabel) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF1F2933)),
      ),
      child: Row(
        children: [
          _UserAvatar(
            name: widget.fullName,
            photoUrl: widget.photoUrl,
            photoBase64: widget.photoBase64, // Pass Base64 here too
            size: 32,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.fullName,
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentView) {
      case 'home':
        return const HomeScreenContent();
      case 'timetable':
        return TimetableScreen(branch: widget.branch);
      case 'profile':
        return const ProfileScreen();
      case 'events':
        return const EventsScreen();
      case 'assignments':
        return AssignmentsScreen(branch: widget.branch);
      case 'announcements':
        return const AnnouncementsScreen();
      case 'contact':
        return const ContactUsView();
      default:
        return const HomeScreenContent();
    }
  }
}

// ───────────────── HELPER WIDGETS ─────────────────

class _NotificationSection extends StatelessWidget {
  final String collection;
  final IconData icon;

  const _NotificationSection({required this.collection, required this.icon});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("No new updates.",
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? data['subject'] ?? "New Item";

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width < 600 ? 16.0 : 40.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + t, -1),
                    end: Alignment(1, 1 - t),
                    colors: const [
                      Color(0xFF020617),
                      Color(0xFF0B1120),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -120 + 40 * t,
              left: -100,
              child: _glowBlob(
                size: size.width * 0.45,
                color: const Color(0xFF60A5FA).withOpacity(0.35),
              ),
            ),
            Positioned(
              bottom: -160 + 40 * (1 - t),
              right: -80,
              child: _glowBlob(
                size: size.width * 0.40,
                color: const Color(0xFF22D3EE).withOpacity(0.33),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 50,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildHeroSection(),
                    const SizedBox(height: 80),
                    _buildSectionTitle('What We Offer'),
                    const SizedBox(height: 30),
                    _buildWhatWeOffer(size),
                    const SizedBox(height: 80),
                    _buildStatsRow(),
                    const SizedBox(height: 40),
                    _buildFooter(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glowBlob({required double size, required Color color}) {
    return SizedBox(
      width: size,
      height: size,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF38BDF8)),
              SizedBox(width: 8),
              Text(
                'Organise your academic life in one place',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFCBD5F5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'IIITNR Hub',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.7,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Timetables, events, assignments and student tools\ncrafted specifically for IIIT Naya Raipur.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: Color(0xFFE5E7EB),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatWeOffer(Size size) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureCard(
          icon: Icons.calendar_today_rounded,
          title: 'Smart Timetable',
          desc: 'Dynamic scheduling that updates automatically.',
        ),
        _buildFeatureCard(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Assignments',
          desc: 'Track deadlines and submissions seamlessly.',
        ),
        _buildFeatureCard(
          icon: Icons.event_available_rounded,
          title: 'Campus Events',
          desc: 'Never miss a fest, workshop or club meet.',
        ),
        _buildFeatureCard(
          icon: Icons.school_rounded,
          title: 'Faculty Connect',
          desc: 'Easy access to contact info and office hours.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon, required String title, required String desc}) {
    return HoverCard(
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF60A5FA), size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 28,
      runSpacing: 20,
      children: const [
        StatCard(value: '1.2K+', label: 'IIITNR Students'),
        StatCard(value: '70+', label: 'Clubs & Events'),
        StatCard(value: '40+', label: 'Faculty Members'),
        StatCard(value: '100%', label: 'Free to use'),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1F2933)),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: const [
          FooterLink(text: 'Terms'),
          FooterLink(text: 'Privacy'),
          FooterLink(text: 'Student Handbook'),
          FooterLink(text: 'Support'),
        ],
      ),
    );
  }
}

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    final msg = _messageCtrl.text.trim();

    if (email.isEmpty || msg.isEmpty) {
      setState(() {
        _error = 'Please fill both email and message.';
      });
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'email': email,
        'message': msg,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! Your feedback has been sent.'),
        ),
      );

      _emailCtrl.clear();
      _messageCtrl.clear();
    } catch (_) {
      setState(() {
        _error = 'Could not send feedback. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF283593)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              "Contact & Feedback",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: isMobile
                ? Column(
                    children: [
                      _buildLeftInfo(),
                      const SizedBox(height: 24),
                      _buildFeedbackForm(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildLeftInfo()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildFeedbackForm()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ContactRowNew(
          icon: Icons.mail_rounded,
          label: "Academic Office",
          value: "academics@iiitnr.edu.in",
        ),
        SizedBox(height: 18),
        _ContactRowNew(
          icon: Icons.support_agent_rounded,
          label: "Tech Support",
          value: "support@iiitnr.edu.in",
        ),
        SizedBox(height: 18),
        _ContactRowNew(
          icon: Icons.location_on_rounded,
          label: "Campus",
          value: "IIIT Naya Raipur, Chhattisgarh",
        ),
      ],
    );
  }

  Widget _buildFeedbackForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Send feedback",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailCtrl,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: "Your email",
              labelStyle: TextStyle(color: Colors.black54),
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _messageCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              labelText: "Message",
              labelStyle: TextStyle(color: Colors.black54),
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    "Send",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContactRowNew extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRowNew({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.blueAccent),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────── UPDATED AVATAR WIDGET (Final Fix) ─────────────────
// This now handles Base64 data correctly in the top bar and sidebar

class _UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? photoBase64;
  final double size;

  const _UserAvatar({
    required this.name,
    this.photoUrl,
    this.photoBase64,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    // 1. Check for Base64 (New Priority)
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: MemoryImage(base64Decode(photoBase64!)),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
          ),
        );
      } catch (e) {
        // Fallback silently if corrupt
      }
    }

    // 2. Check for Legacy URL (Old Fallback)
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(
             "https://corsproxy.io/?${Uri.encodeComponent(photoUrl!)}"),
      );
    }

    // 3. Fallback Initials
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF0EA5E9)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;

  const HoverCard({super.key, required this.child});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFF020617)
              : const Color(0xFF020617).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? const Color(0xFF38BDF8) : const Color(0xFF1F2933),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FooterLink extends StatelessWidget {
  final String text;

  const FooterLink({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}