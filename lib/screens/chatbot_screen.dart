import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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

  // History now supports an optional 'action' key for buttons
  final List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  // ---------------- INTELLIGENT SYSTEM PROMPT ----------------
  // This prompt teaches the AI to answer verbally first, then offer links.
  final String systemPrompt = '''
You are the intelligent assistant for "IIITNR Hub," the official student companion app.
Your Persona: You are helpful, concise, and knowledgeable about campus logistics.

APP CAPABILITIES (Explain these if asked):
1. Timetable: View daily class schedules (CSE, DSAI, ECE).
2. Events: Information on college fests and workshops.
3. Assignments: Track pending tasks and deadlines.
4. Announcements: Official news from the administration.
5. Contact/Support: Feedback form and developer contact info.
6. Home: The main dashboard.

INSTRUCTIONS:
- Answer the user's question fully and conversationally in the text.
- Do NOT automatically force navigation.
- If the user explicitly asks to open a page, or if a link would be helpful context, append a tag at the VERY END of your response.
- Tag Format: [LINK:section_name]
- Valid Tags: [LINK:timetable], [LINK:events], [LINK:assignments], [LINK:announcements], [LINK:contact], [LINK:home].

EXAMPLE INTERACTIONS:
User: "What classes do I have Monday?"
You: "On Monday, you have Calculus at 9:00 AM, Linear Algebra at 10:00 AM, and Digital Electronics at 11:00 AM. [LINK:timetable]"

User: "Where can I see the news?"
You: "You can check the latest circulars in the Announcements section. [LINK:announcements]"

User: "Open the events page."
You: "Sure, opening the Events section for you. [LINK:events]"

---------------------------------------------------
OFFICIAL CLASS TIMETABLES (CSE)
---------------------------------------------------
MONDAY: 09:00 Calculus, 10:00 Linear Algebra, 11:00 Digital Elec, 12:00 EVS, 14:00 Entrepreneurship, 15:00 IT Workshop, 16:00 C-Prog, 17:00 IoT.
TUESDAY: 09:00 C-Prog, 10:00 EVS, 11:00 Calculus, 12:00 Lang(Adv-1), 14:00 IT Workshop, 15:00 Digital Elec, 16:00 Entrepreneurship, 17:00 Lang(Adv-2).
WEDNESDAY: 09:00 IoT, 10:00 Calculus, 11:00 Linear Algebra, 12:00 Digital Elec, 14:00 EVS, 15:00 Lang(Adv-2), 16:00 IT Workshop, 17:00 Lang(Adv-1).
THURSDAY: 09:00 EVS, 10:00 Entrepreneurship, 11:00 Calculus, 12:00 C-Prog, 14:00 Digital Elec, 15:00 IoT, 16:00 Linear Algebra, 17:00 Lang(Adv-1).
FRIDAY: 09:00 Digital Elec, 10:00 Lang(Adv-1), 11:00 IoT, 12:00 Calculus, 14:00 C-Prog, 15:00 Entrepreneurship, 16:00 EVS, 17:00 Lang(Adv-2).

[Other Branches Summary]
DSAI: Similar to CSE but prioritize Data Science subjects.
ECE: Prioritize Electronics subjects.

CURRENT CONTEXT:
Today is ${DateFormat('EEEE, d MMMM').format(DateTime.now())}.
  ''';

  void _scrollDown() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
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
      final response = await http.post(
        Uri.parse("https://gemini-proxy-evw9.onrender.com/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "system": systemPrompt,
          "message": message,
        }),
      );

      final data = jsonDecode(response.body);
      String fullReply = data["reply"] ?? "I couldn't get a response.";

      // ---------------- PARSING LOGIC ----------------
      // We strip the [LINK:...] tag out of the text and store it separately
      String displayText = fullReply;
      String? actionLink;

      final regex = RegExp(r'\[LINK:(.*?)\]');
      final match = regex.firstMatch(fullReply);

      if (match != null) {
        actionLink = match.group(1); // e.g., "timetable"
        displayText = fullReply.replaceAll(regex, '').trim(); // Remove tag from visible text
      }

      setState(() {
        _history.add({
          'role': 'model',
          'text': displayText,
          'action': actionLink, // Save action for the button
        });
      });
    } catch (e) {
      debugPrint("Error: $e");
      _showError("Connection failed. Please check your internet.");
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
                        Icon(Icons.auto_awesome_rounded,
                            size: 48, color: Colors.white12),
                        const SizedBox(height: 16),
                        const Text(
                          'Try "What is my schedule for Monday?"',
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
                      final item = _history[index];
                      final isUser = item['role'] == 'user';
                      return _MessageBubble(
                        text: item['text'] ?? "",
                        isUser: isUser,
                        actionLink: item['action'],
                        onActionPressed: (destination) {
                          // Return the navigation command to the main screen
                          Navigator.pop(context, destination);
                        },
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
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: _sendChatMessage,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => _sendChatMessage(_textController.text),
            icon: Icon(Icons.send_rounded,
                color: _isLoading ? Colors.grey : Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}

// ---------------- CUSTOM MESSAGE BUBBLE WIDGET ----------------
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? actionLink; // The navigation command (e.g., 'timetable')
  final Function(String)? onActionPressed;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    this.actionLink,
    this.onActionPressed,
  });

// Inside _MessageBubble class
@override
Widget build(BuildContext context) {
  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isUser ? Colors.blueAccent : const Color(0xFF334155),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          // --- CHANGE STARTS HERE ---
          child: MarkdownBody(
            data: text,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white, fontSize: 15), // Normal text
              strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // **Bold** text
            ),
          ),
          // --- CHANGE ENDS HERE ---
        ),

        if (actionLink != null && !isUser)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 2),
            child: ActionChip(
              elevation: 2,
              backgroundColor: Colors.teal.shade700,
              avatar: const Icon(Icons.arrow_forward_rounded,
                  size: 16, color: Colors.white),
              label: Text(
                "Open ${_capitalize(actionLink!)}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (onActionPressed != null) {
                  onActionPressed!(actionLink!);
                }
              },
            ),
          ),
      ],
    ),
  );
}

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}