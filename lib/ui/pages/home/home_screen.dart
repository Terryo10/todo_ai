import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../domain/model/course.dart';
import 'components/course_card.dart';
import 'components/secondary_course_card.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: AiTodoCard(
                  iconSrc: 'assets/icons/code.svg',
                  // color: const Color(0xFF7553F6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "My Todos",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              ...recentCourses.map((course) => Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: SecondaryCourseCard(
                      title: course.title,
                      iconsSrc: course.iconSrc,
                      colorl: course.color,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
