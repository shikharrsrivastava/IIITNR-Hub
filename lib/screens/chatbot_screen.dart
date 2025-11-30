import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Useful for getting current day if needed

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // ---------------- CONFIGURATION ----------------
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();

  final List<Map<String, String>> _history = [];
  bool _isLoading = false;

  // ---------------- SYSTEM PROMPT WITH TIMETABLE DATA ----------------
  // This string teaches the AI your specific college schedule.
  final String systemPrompt = '''
You are the intelligent assistant for the "IIITNR Hub" college app.
Your goal is to help students with knowledge, check their timetable, OR navigate them to app sections.

CURRENT CONTEXT:
Today is ${DateFormat('EEEE').format(DateTime.now())}.

RULES FOR NAVIGATION:
If the user asks to see, open, or go to a specific section, reply with a command code ONLY.
- Timetable -> Reply: "NAVIGATE:timetable"
- Events / Fests -> Reply: "NAVIGATE:events"
- Assignments / Tasks -> Reply: "NAVIGATE:assignments"
- Announcements / News -> Reply: "NAVIGATE:announcements"
- Contact / Support -> Reply: "NAVIGATE:contact"
- Home / Dashboard -> Reply: "NAVIGATE:home"

---------------------------------------------------
OFFICIAL CLASS TIMETABLES (IIITNR)
---------------------------------------------------

[CSE - Computer Science Engineering]
MONDAY:
09:00-10:00: Calculus (Room 301)
10:00-11:00: Linear Algebra & Matrix Analysis (Room 301)
11:00-12:00: Digital Electronics (Room 301)
12:00-01:00: Environmental Studies (Room 301)
02:00-03:00: Entrepreneurship (Room 301)
03:00-04:00: IT Workshop (Room 301)
04:00-05:00: Problem Solving with C (Room 301)
05:00-06:00: IoT (Room 301)

TUESDAY:
09:00-10:00: Problem Solving with C
10:00-11:00: Environmental Studies
11:00-12:00: Calculus
12:00-01:00: Language Competency (Adv-1)
02:00-03:00: IT Workshop
03:00-04:00: Digital Electronics
04:00-05:00: Entrepreneurship
05:00-06:00: Language Competency (Adv-2)

WEDNESDAY:
09:00-10:00: IoT
10:00-11:00: Calculus
11:00-12:00: Linear Algebra
12:00-01:00: Digital Electronics
02:00-03:00: Environmental Studies
03:00-04:00: Language Competency (Adv-2)
04:00-05:00: IT Workshop
05:00-06:00: Language Competency (Adv-1)

THURSDAY:
09:00-10:00: Environmental Studies
10:00-11:00: Entrepreneurship
11:00-12:00: Calculus
12:00-01:00: Problem Solving with C
02:00-03:00: Digital Electronics
03:00-04:00: IoT
04:00-05:00: Linear Algebra
05:00-06:00: Language Competency (Adv-1)

FRIDAY:
09:00-10:00: Digital Electronics
10:00-11:00: Language Competency (Adv-1)
11:00-12:00: IoT
12:00-01:00: Calculus
02:00-03:00: Problem Solving with C
03:00-04:00: Entrepreneurship
04:00-05:00: Environmental Studies
05:00-06:00: Language Competency (Adv-2)

[DSAI - Data Science & AI]
MONDAY: EVS, C Prog, Calculus, Lang(Adv-2), LinAlg, Digital Elec, IoT, Entrepreneurship.
TUESDAY: Digital Elec, EVS, LinAlg, Lang(Adv-1), Calculus, IoT, C Prog, Entrepreneurship.
WEDNESDAY: IoT, Entrepreneurship, EVS, Calculus, C Prog, Digital Elec, Lang(Adv-2), Lang(Adv-1).
THURSDAY: Calculus, EVS, C Prog, LinAlg, Digital Elec, IoT, Lang(Adv-1), Entrepreneurship.
FRIDAY: LinAlg, IoT, EVS, C Prog, Calculus, Digital Elec, Lang(Adv-2), Entrepreneurship.

[ECE - Electronics & Comm]
MONDAY: EVS, Digital Elec, Calculus, Lang(Adv-1), IoT, LinAlg, Entrepreneurship, C Prog.
TUESDAY: Calculus, EVS, IoT, Lang(Adv-2), C Prog, Digital Elec, LinAlg, Entrepreneurship.
WEDNESDAY: IoT, Calculus, C Prog, EVS, Lang(Adv-1), Digital Elec, LinAlg, Entrepreneurship.
THURSDAY: LinAlg, EVS, Calculus, Digital Elec, C Prog, Lang(Adv-2), IoT, Entrepreneurship.
FRIDAY: Entrepreneurship, IoT, EVS, Calculus, C Prog, Digital Elec, LinAlg, Lang(Adv-1).

INSTRUCTIONS:
1. Assume the user is CSE unless they specify otherwise.
2. If the user asks "What do I have now?", compare the current time provided in context to the schedule.
3. Be concise.
  ''';

  void _scrollDown() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutCirc,
        ),
      );
    }
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _history.add({'role': 'user', 'text': message});
    });

    try {
      // ---------------- CALL BACKEND PROXY ----------------
      // Using your Render URL
      final response = await http.post(
        Uri.parse("https://gemini-proxy-evw9.onrender.com/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "system": systemPrompt, 
          "message": message,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["reply"] == null) {
        _showError("No response from backend.");
        return;
      }

      String text = data["reply"];

      // ---------------- NAVIGATION CHECK ----------------
      if (text.trim().startsWith("NAVIGATE:")) {
        final destination = text.trim().split(":")[1];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Opening $destination..."),
              backgroundColor: Colors.blueAccent,
              duration: const Duration(milliseconds: 800),
            ),
          );
          Navigator.pop(context, destination);
        }
        return;
      }

      // ---------------- UPDATE CHAT ----------------
      setState(() {
        _history.add({'role': 'model', 'text': text});
      });

    } catch (e) {
      debugPrint("Proxy Error: $e");
      _showError("Technical Error:\n$e");
    } finally {
      if (mounted) {
        _textController.clear();
        setState(() => _isLoading = false);
        _textFieldFocus.requestFocus();
        _scrollDown();
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Issue Detected', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text("AI Assistant", style: TextStyle(color: Colors.white)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 48, color: Colors.white12),
                        const SizedBox(height: 16),
                        const Text(
                          'Try asking: "What classes do I have today?"',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _history.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final content = _history[index];
                      final isUser = content['role'] == 'user';
                      return _MessageBubble(
                        text: content['text'] ?? "",
                        isUser: isUser,
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                color: Colors.blueAccent,
                backgroundColor: Colors.transparent,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFieldFocus,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _sendChatMessage(_textController.text),
                  icon: Icon(Icons.send_rounded, color: _isLoading ? Colors.grey : Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : const Color(0xFF334155),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}