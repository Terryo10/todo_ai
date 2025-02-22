import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThinkingLoader extends StatefulWidget {
  const ThinkingLoader({super.key});

  @override
  State<ThinkingLoader> createState() => _ThinkingLoaderState();
}

class _ThinkingLoaderState extends State<ThinkingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _dots = ['', '.', '..', '...'];
  int _currentDotIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        if (_controller.status == AnimationStatus.completed) {
          setState(() {
            _currentDotIndex = (_currentDotIndex + 1) % _dots.length;
          });
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            child: Lottie.asset('assets/lotties/ai.json'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Thinking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 24,
                child: Text(
                  _dots[_currentDotIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
