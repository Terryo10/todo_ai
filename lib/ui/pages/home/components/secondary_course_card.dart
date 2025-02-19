import 'package:flutter/material.dart';
import 'package:todo_ai/domain/model/todo_model.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;

  const TodoCard({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF7553F6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7553F6).withValues(alpha:0.3),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10 Tasks, 10 done, 10 pending',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Hexagonal background
                      Center(
                        child: CustomPaint(
                          size: const Size(36, 36),
                          painter: HexagonPainter(
                            color: Colors.white.withValues(alpha:0.3),
                          ),
                        ),
                      ),
                      // Icon
                      Center(child: Icon(Icons.menu)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final Path path = Path();

    // Start at top
    path.moveTo(width / 2, 0);
    // Draw to top right
    path.lineTo(width * 0.75, height * 0.25);
    // Draw to bottom right
    path.lineTo(width * 0.75, height * 0.75);
    // Draw to bottom
    path.lineTo(width / 2, height);
    // Draw to bottom left
    path.lineTo(width * 0.25, height * 0.75);
    // Draw to top left
    path.lineTo(width * 0.25, height * 0.25);
    // Close path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Progress Indicator Component
class ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(48, 48),
      painter: ProgressRingPainter(
        progress: progress,
        color: color,
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha:0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final double center = size.width / 2;
    final double radius = (size.width - paint.strokeWidth) / 2;

    // Draw background circle
    canvas.drawCircle(Offset(center, center), radius, paint);

    // Draw progress arc
    final double sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      -1.57079633, // Start from top (90 degrees)
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
