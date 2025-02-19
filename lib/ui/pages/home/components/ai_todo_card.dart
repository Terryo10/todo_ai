import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';

class AiTodoCard extends StatefulWidget {
  const AiTodoCard({
    super.key,
    this.color = const Color(0xFF2D2D2D),
    this.iconSrc = "assets/icons/ai_assistant.svg",
  });

  final Color color;
  final String iconSrc;

  @override
  State<AiTodoCard> createState() => _AiTodoCardState();
}

class _AiTodoCardState extends State<AiTodoCard> {
  bool _isExpanded = false;
  List<TodoItem> _tasks = [];
  final TextEditingController _promptController = TextEditingController();
  String _currentTypingText = "";
  int _currentPromptIndex = 0;
  Timer? _typingTimer;

  final List<String> _aiPrompts = [
    "Tell me what you want, then I'll create tasks for you...",
    "I can help you with productivity...",
    "Let me organize your thoughts into actionable tasks...",
    "What project shall we break down today?...",
  ];

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    String targetText = _aiPrompts[_currentPromptIndex];
    int charIndex = 0;

    _typingTimer?.cancel();
    _currentTypingText = "";

    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (charIndex < targetText.length) {
        setState(() {
          _currentTypingText = targetText.substring(0, charIndex + 1);
        });
        charIndex++;
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _currentPromptIndex =
                  (_currentPromptIndex + 1) % _aiPrompts.length;
              _startTypingAnimation();
            });
          }
        });
      }
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _tasks.clear();
        _promptController.clear();
        _startTypingAnimation();
      } else {
        _typingTimer?.cancel();
      }
    });
  }

  void _generateTodos(String prompt) {
    // Simulated AI response - Connect to your AI service
    setState(() {
      _isExpanded = true;
      _tasks = [
        TodoItem(
            title: "Implement Mukuru Card Visibility for All Customer States"),
        TodoItem(title: "Integrate Mukuru Card Flow Based on Customer State"),
        TodoItem(title: "Design UI for Suggested Products Section"),
        TodoItem(title: "Develop Backend Support for Suggested Products"),
        TodoItem(
            title:
                "Conduct User Acceptance Testing for Mukuru Card Integration"),
      ];
    });
  }

  void _toggleTaskAcceptance(TodoItem task) {
    setState(() {
      task.isAccepted = !task.isAccepted;
    });
  }

  void _removeTask(TodoItem task) {
    setState(() {
      _tasks.remove(task);
      if (_tasks.isEmpty) {
        _toggleExpanded();
      }
    });
  }

  void _acceptAll() {
    setState(() {
      for (var task in _tasks) {
        task.isAccepted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Task Whiz",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: 70, child: Lottie.asset('assets/lotties/ai.json'))
            ],
          ),
          const SizedBox(height: 16),
          if (!_isExpanded) ...[
            Text(
              _currentTypingText,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your request here...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _generateTodos(_promptController.text),
                ),
              ],
            ),
          ],
          if (_isExpanded && _tasks.isNotEmpty) ...[
            ..._tasks.map((task) => _buildTaskItem(task)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined,
                        color: Colors.grey.shade500, size: 20),
                    const SizedBox(width: 8),
                    Icon(Icons.thumb_down_outlined,
                        color: Colors.grey.shade500, size: 20),
                  ],
                ),
                TextButton(
                  onPressed: _acceptAll,
                  child: const Text(
                    "Accept all",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem(TodoItem task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/icons/task_icon.svg",
            height: 16,
            width: 16,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade500,
              BlendMode.src,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.check,
              color: task.isAccepted ? Colors.green : Colors.grey.shade500,
            ),
            onPressed: () => _toggleTaskAcceptance(task),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade500),
            onPressed: () => _removeTask(task),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey.shade500),
            onPressed: () {
              // Implement edit functionality
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _promptController.dispose();
    super.dispose();
  }
}

class TodoItem {
  String title;
  bool isAccepted;

  TodoItem({
    required this.title,
    this.isAccepted = false,
  });
}
