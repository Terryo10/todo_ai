import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart' hide Image;

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../routes/router.gr.dart';
import 'components/animated_btn.dart';
import 'components/sign_in_dialog.dart';

@RoutePage()
class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({super.key});

  @override
  State<OnbodingScreen> createState() => _OnbodingScreenState();
}

class _OnbodingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState) {
          context.navigateTo(EntryPointRoute());
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width * 1.7,
              left: 100,
              bottom: 100,
              child: Image.asset(
                "assets/Backgrounds/Spline.png",
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox(),
              ),
            ),
            const RiveAnimation.asset(
              "assets/RiveAssets/shapes.riv",
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: const SizedBox(),
              ),
            ),
            AnimatedPositioned(
              top: isShowSignInDialog ? -50 : 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              duration: const Duration(milliseconds: 260),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 260,
                        child: Column(
                          children: [
                            Image.asset('assets/icons/vibes.png'),
                            SizedBox(height: 16),
                            Text(
                                'Your smart AI task assistant. Just describe what you need, and TaskWhiz suggests the perfect tasks\n— keeping you organized and on track effortlessly.')
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      AnimatedBtn(
                        btnAnimationController: _btnAnimationController,
                        press: () {
                          if (isShowSignInDialog) return;

                          _btnAnimationController.isActive = true;

                          Future.delayed(
                            const Duration(milliseconds: 800),
                            () {
                              if (!mounted || isShowSignInDialog) return;

                              setState(() {
                                isShowSignInDialog = true;
                              });

                              showCustomSignInDialog(
                                context,
                                onDismiss: () {
                                  setState(() {
                                    isShowSignInDialog = false;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                              '🔹 Smart Suggestions – AI auto-generates tasks.\n📅 Stay Organized – Prioritize with ease.\n⏳ Boost Productivity – Streamline your workflow.'))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
