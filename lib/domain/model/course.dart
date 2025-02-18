import 'package:flutter/material.dart' show Color;

class Course {
  final String title, description, iconSrc;
  final Color color;

  Course({
    required this.title,
    this.description = 'Build and animate an iOS app from scratch',
    this.iconSrc = "assets/icons/ios.svg",
    this.color = const Color(0xFF7553F6),
  });
}

final List<Course> courses = [
  Course(
    title: "Animations in SwiftUI",
  ),
  Course(
    title: "Animations in Flutter",
    iconSrc: "assets/icons/code.svg",
    color: const Color(0xFF80A4FF),
  ),
];

final List<Course> recentCourses = [
  Course(title: "My Day"),
  Course(
    title: "Work Tasks",
    color: const Color(0xFF9CC5FF),
    iconSrc: "assets/icons/code.svg",
  ),
  Course(title: "My Daily Routine"),
  Course(
    title: "Groceries",
    color: const Color(0xFF9CC5FF),
    iconSrc: "assets/icons/code.svg",
  ),
];
