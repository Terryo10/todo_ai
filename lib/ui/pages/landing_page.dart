import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/ui/screens/entryPoint/entry_point.dart';
import 'package:todo_ai/ui/screens/onboding/onboding_screen.dart';

import '../../state/bloc/cache_bloc/cache_bloc.dart';

@RoutePage()
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CacheBloc, CacheState>(
      builder: (context, state) {
        if (state is CacheInitialState) {
          return OnbodingScreen();
        } else if (state is CacheLoadingState) {
          return SizedBox();
        } else if (state is CacheFoundState) {
          return EntryPoint();
        } else if (state is CacheNotFoundState) {
          return SizedBox();
        } else if (state is CacheErrorState) {
          return SizedBox();
        }

        return SizedBox();
      },
    );
  }
}
