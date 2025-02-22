import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:todo_ai/domain/bloc/prompt_generator_bloc/prompt_generator_bloc.dart';
import 'package:todo_ai/ui/shared_widgets/thinking_loader.dart';

import '../../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../../domain/model/todo_model.dart';

class AiTodoScreen extends StatelessWidget {
  const AiTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AiTodoCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _AiTodoCardState extends State<AiTodoCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  List<TodoItem> _tasks = [];
  final TextEditingController _promptController = TextEditingController();
  String _currentTypingText = "";
  int _currentPromptIndex = 0;
  Timer? _typingTimer;
  late AnimationController _borderAnimationController;

  final List<String> _aiPrompts = [
    "Tell me what you want, then I'll create tasks for you...",
    "I can help you with productivity...",
    "Let me organize your thoughts into actionable tasks...",
    "What project shall we break down today?...",
  ];

  @override
  void initState() {
    super.initState();
    _borderAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    String targetText = _aiPrompts[_currentPromptIndex];
    int charIndex = 0;

    _typingTimer?.cancel();
    _currentTypingText = "";

    _typingTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
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
      },
    );
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
    if (prompt.trim().isEmpty) return;

    setState(() {
      _isExpanded = true;
      _typingTimer?.cancel();
    });

    BlocProvider.of<PromptGeneratorBloc>(context)
        .add(GeneratePrompt(prompt: prompt));
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
    return BlocListener<PromptGeneratorBloc, PromptGeneratorState>(
      listener: (context, state) {
        if (state is PromptLoadedState) {
          setState(() {
            _tasks =
                state.taskList.map((task) => TodoItem(title: task)).toList();
          });
        } else if (state is PromptErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate tasks. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          _toggleExpanded();
        }
      },
      child: AnimatedBuilder(
        animation: _borderAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF4776E6),
                  Color(0xFF8E54E9),
                  Color(0xFFFF4081),
                  Color(0xFF4776E6),
                ],
                stops: [
                  0.0,
                  0.3 + _borderAnimationController.value * 0.2,
                  0.6 + _borderAnimationController.value * 0.2,
                  1.0,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(2), // Border width
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.95,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
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
                      if (!_isExpanded)
                        SizedBox(
                          height: 70,
                          child: Lottie.asset('assets/lotties/ai.json'),
                        ),
                      if (_isExpanded)
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _toggleExpanded,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  if (_isExpanded)
                    BlocBuilder<PromptGeneratorBloc, PromptGeneratorState>(
                      builder: (context, state) {
                        if (state is PromptLoadedState) {
                          return Text(
                            "Topic: ${state.topic}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  const SizedBox(height: 5),
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade800),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade800),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<PromptGeneratorBloc, PromptGeneratorState>(
                          builder: (context, state) {
                            if (state is PromptLoadingState) {
                              return ThinkingLoader();
                            }
                            return IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  _generateTodos(_promptController.text),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                  if (_isExpanded) ...[
                    Expanded(
                      child: BlocBuilder<PromptGeneratorBloc,
                          PromptGeneratorState>(
                        builder: (context, state) {
                          if (state is PromptLoadingState) {
                            return ThinkingLoader();
                          }

                          if (_tasks.isEmpty) {
                            return const Center(
                              child: Text(
                                'No tasks generated yet',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thickness: WidgetStateProperty.all(8),
                                          thumbColor: WidgetStateProperty.all(
                                              Colors.deepPurple
                                                  .withValues(alpha: 0.6)),
                                          trackColor: WidgetStateProperty.all(
                                              Colors.grey.shade800
                                                  .withValues(alpha: 0.1)),
                                          radius: const Radius.circular(10),
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                          trackVisibility:
                                              WidgetStateProperty.all(true),
                                        ),
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Column(
                                              children: [
                                                ..._tasks.map((task) =>
                                                    _buildTaskItem(task)),
                                                if (_tasks.length > 3)
                                                  const SizedBox(height: 16),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_tasks.length > 3)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          height: 32,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  widget.color
                                                      .withValues(alpha: 0),
                                                  widget.color,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        if (_tasks.any((task) => task.isAccepted)) ...[
                          const SizedBox(height: 8),
                          _buildCreateTodoButton(),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(TodoItem task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: task.isAccepted
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isAccepted
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _toggleTaskAcceptance(task),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: task.isAccepted
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.shade800.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/task_icon.svg",
                    height: 14,
                    width: 14,
                    colorFilter: ColorFilter.mode(
                      task.isAccepted ? Colors.green : Colors.grey.shade400,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: task.isAccepted
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.check,
                      color:
                          task.isAccepted ? Colors.green : Colors.grey.shade500,
                      onPressed: () => _toggleTaskAcceptance(task),
                    ),
                    _buildActionButton(
                      icon: Icons.close,
                      color: Colors.grey.shade500,
                      onPressed: () => _removeTask(task),
                    ),
                    _buildActionButton(
                      icon: Icons.edit,
                      color: Colors.grey.shade500,
                      onPressed: () {
                        // Implement edit functionality
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTodoButton() {
    final acceptedTasks = _tasks.where((task) => task.isAccepted).toList();

    if (acceptedTasks.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: Material(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Get the current PromptGeneratorState to access the topic
            final promptState = context.read<PromptGeneratorBloc>().state;
            if (promptState is PromptLoadedState) {
              // Add a new todo with the topic as the name
              context.read<TodoBloc>().add(
                    AddTodo(name: promptState.topic),
                  );

              // Wait briefly for the todo to be created
              Future.delayed(const Duration(milliseconds: 500), () {
                // Get the current TodoState to find the newly created todo
                // ignore: use_build_context_synchronously
                final todoState = context.read<TodoBloc>().state;
                if (todoState is TodoLoaded) {
                  // Find the most recently created todo
                  Todo? newTodo = todoState.todos.lastWhere(
                    (todo) => todo.name == promptState.topic,
                  );
                  // Add all accepted tasks to the todo
                  for (final task in acceptedTasks) {
                    // ignore: use_build_context_synchronously
                    context.read<TodoBloc>().add(
                          AddTask(
                            todoId: newTodo.id,
                            taskName: task.title,
                            assignedTo: '', // You can set default values
                            isImportant: false,
                            reminderTime: null,
                          ),
                        );
                  }

                  // Show success message
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todo created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Close the AI todo card
                  _toggleExpanded();
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_task,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Create Todo with (${acceptedTasks.length} tasks)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
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
