// lib/screens/timetable_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  final String branch;

  const TimetableScreen({super.key, required this.branch});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  String _selectedDay = 'Monday';
  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  late Map<String, Map<String, List<ClassSession>>> _timetable;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _loadTimetable();
  }

  void _loadTimetable() {
    _timetable = {
      'CSE': _generateCSE(),
      'DSAI': _generateDSAI(),
      'ECE': _generateECE(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final branch =
        _timetable.containsKey(widget.branch) ? widget.branch : 'CSE';

    return Stack(
      children: [
        const _BlueBackground(),
        FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(branch),
                const SizedBox(height: 30),
                _daySelector(),
                const SizedBox(height: 30),
                _sessionList(_timetable[branch]![_selectedDay]!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(String branch) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Timetable — $branch",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your day-wise schedule at a glance.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _daySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _days.map((day) {
          final active = day == _selectedDay;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
                _controller.forward(from: 0);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: active
                    ? Colors.blueAccent
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: active
                      ? Colors.blueAccent
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.white70,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sessionList(List<ClassSession> sessions) {
    return Column(
      children: sessions.map((s) => _classCard(s)).toList(),
    );
  }

  Widget _classCard(ClassSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.25),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _infoBadge(Icons.access_time_rounded,
                              "${session.start} - ${session.end}"),
                          const SizedBox(width: 12),
                          _infoBadge(Icons.location_on_rounded, session.room),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueAccent),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  //  DATA GENERATION (Unchanged Logic)
  // ----------------------------------------------------------------------

  // 9AM -> 6PM periods (55 mins each + recess)
  List<ClassSession> _buildDay(List<String> order) {
    return [
      ClassSession(order[0], "9:00 AM", "9:55 AM", "Room 301"),
      ClassSession(order[1], "10:00 AM", "10:55 AM", "Room 301"),
      ClassSession(order[2], "11:00 AM", "11:55 AM", "Room 301"),
      ClassSession(order[3], "12:00 PM", "12:55 PM", "Room 301"),
      ClassSession("Recess", "1:00 PM", "1:55 PM", "Cafeteria"),
      ClassSession(order[4], "2:00 PM", "2:55 PM", "Room 301"),
      ClassSession(order[5], "3:00 PM", "3:55 PM", "Room 301"),
      ClassSession(order[6], "4:00 PM", "4:55 PM", "Room 301"),
      ClassSession(order[7], "5:00 PM", "5:55 PM", "Room 301"),
    ];
  }

  Map<String, List<ClassSession>> _generateCSE() {
    return {
      'Monday': _buildDay([
        "Calculus",
        "Linear Algebra & Matrix Analysis",
        "Digital Electronics using Verilog",
        "Environmental Studies",
        "Entrepreneurship & Design Thinking",
        "IT Workshop: Full Stack Prototyping",
        "Problem Solving with C Programming",
        "Internet of Things",
      ]),
      'Tuesday': _buildDay([
        "Problem Solving with C Programming",
        "Environmental Studies",
        "Calculus",
        "Int. Language Competency (Adv-1)",
        "IT Workshop: Full Stack Prototyping",
        "Digital Electronics using Verilog",
        "Entrepreneurship & Design Thinking",
        "Int. Language Competency (Adv-2)",
      ]),
      'Wednesday': _buildDay([
        "Internet of Things",
        "Calculus",
        "Linear Algebra & Matrix Analysis",
        "Digital Electronics using Verilog",
        "Environmental Studies",
        "Int. Language Competency (Adv-2)",
        "IT Workshop: Full Stack Prototyping",
        "Int. Language Competency (Adv-1)",
      ]),
      'Thursday': _buildDay([
        "Environmental Studies",
        "Entrepreneurship & Design Thinking",
        "Calculus",
        "Problem Solving with C Programming",
        "Digital Electronics using Verilog",
        "Internet of Things",
        "Linear Algebra & Matrix Analysis",
        "Int. Language Competency (Adv-1)",
      ]),
      'Friday': _buildDay([
        "Digital Electronics using Verilog",
        "Int. Language Competency (Adv-1)",
        "Internet of Things",
        "Calculus",
        "Problem Solving with C Programming",
        "Entrepreneurship & Design Thinking",
        "Environmental Studies",
        "Int. Language Competency (Adv-2)",
      ]),
    };
  }

  Map<String, List<ClassSession>> _generateDSAI() {
    return {
      'Monday': _buildDay([
        "Environmental Studies",
        "Problem Solving with C Programming",
        "Calculus",
        "Int. Language Competency (Adv-2)",
        "Linear Algebra & Matrix Analysis",
        "Digital Electronics using Verilog",
        "Internet of Things",
        "Entrepreneurship & Design Thinking",
      ]),
      'Tuesday': _buildDay([
        "Digital Electronics using Verilog",
        "Environmental Studies",
        "Linear Algebra & Matrix Analysis",
        "Int. Language Competency (Adv-1)",
        "Calculus",
        "Internet of Things",
        "Problem Solving with C Programming",
        "Entrepreneurship & Design Thinking",
      ]),
      'Wednesday': _buildDay([
        "Internet of Things",
        "Entrepreneurship & Design Thinking",
        "Environmental Studies",
        "Calculus",
        "Problem Solving with C Programming",
        "Digital Electronics using Verilog",
        "Int. Language Competency (Adv-2)",
        "Int. Language Competency (Adv-1)",
      ]),
      'Thursday': _buildDay([
        "Calculus",
        "Environmental Studies",
        "Problem Solving with C Programming",
        "Linear Algebra & Matrix Analysis",
        "Digital Electronics using Verilog",
        "Internet of Things",
        "Int. Language Competency (Adv-1)",
        "Entrepreneurship & Design Thinking",
      ]),
      'Friday': _buildDay([
        "Linear Algebra & Matrix Analysis",
        "Internet of Things",
        "Environmental Studies",
        "Problem Solving with C Programming",
        "Calculus",
        "Digital Electronics using Verilog",
        "Int. Language Competency (Adv-2)",
        "Entrepreneurship & Design Thinking",
      ]),
    };
  }

  Map<String, List<ClassSession>> _generateECE() {
    return {
      'Monday': _buildDay([
        "Environmental Studies",
        "Digital Electronics using Verilog",
        "Calculus",
        "Int. Language Competency (Adv-1)",
        "Internet of Things",
        "Linear Algebra & Matrix Analysis",
        "Entrepreneurship & Design Thinking",
        "Problem Solving with C Programming",
      ]),
      'Tuesday': _buildDay([
        "Calculus",
        "Environmental Studies",
        "Internet of Things",
        "Int. Language Competency (Adv-2)",
        "Problem Solving with C Programming",
        "Digital Electronics using Verilog",
        "Linear Algebra & Matrix Analysis",
        "Entrepreneurship & Design Thinking",
      ]),
      'Wednesday': _buildDay([
        "Internet of Things",
        "Calculus",
        "Problem Solving with C Programming",
        "Environmental Studies",
        "Int. Language Competency (Adv-1)",
        "Digital Electronics using Verilog",
        "Linear Algebra & Matrix Analysis",
        "Entrepreneurship & Design Thinking",
      ]),
      'Thursday': _buildDay([
        "Linear Algebra & Matrix Analysis",
        "Environmental Studies",
        "Calculus",
        "Digital Electronics using Verilog",
        "Problem Solving with C Programming",
        "Int. Language Competency (Adv-2)",
        "Internet of Things",
        "Entrepreneurship & Design Thinking",
      ]),
      'Friday': _buildDay([
        "Entrepreneurship & Design Thinking",
        "Internet of Things",
        "Environmental Studies",
        "Calculus",
        "Problem Solving with C Programming",
        "Digital Electronics using Verilog",
        "Linear Algebra & Matrix Analysis",
        "Int. Language Competency (Adv-1)",
      ]),
    };
  }
}

class ClassSession {
  final String subject;
  final String start;
  final String end;
  final String room;

  ClassSession(this.subject, this.start, this.end, this.room);
}

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