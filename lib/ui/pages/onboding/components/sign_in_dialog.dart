import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../domain/bloc/auth_bloc/auth_bloc.dart';

void showCustomSignInDialog(BuildContext context,
    {required VoidCallback onDismiss}) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5), // Fixed incorrect method
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return _SignInDialog(onDismiss: onDismiss); // Extracted widget
    },
  );
}

class _SignInDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const _SignInDialog({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        if (state is AuthErrorState) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Center(
        // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () async {
            onDismiss();
            return true;
          },
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoadingState) {
                    return SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Unlock Smart Productivity!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SignInOptions(),
                      _SignInButton(
                        icon: "assets/icons/google.svg",
                        text: "Continue with Google",
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        borderColor: Colors.grey.shade300,
                        authEvent: LoginWithGoogle(),
                      ),
                      if (Platform.isIOS)
                        _SignInButton(
                          icon: "assets/icons/apple.svg",
                          text: "Continue with Apple",
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          authEvent: LoginWithApple(),
                        ), // Extracted BlocBuilder
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          );
        }
        return Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FeatureItem(
                    icon: "assets/icons/ai.svg",
                    text: "AI-Generated Tasks",
                    iconColor: Color(0xFF6C63FF)),
                _FeatureItem(
                    icon: "assets/icons/reminder.svg",
                    text: "Smart Reminders",
                    iconColor: Color(0xFF4CAF50)),
                _FeatureItem(
                    icon: "assets/icons/organize.svg",
                    text: "Effortless Organization",
                    iconColor: Color(0xFF2196F3)),
                _FeatureItem(
                    icon: "assets/icons/sync.svg",
                    text: "Sync Across Devices",
                    iconColor: Color(0xFF9C27B0)),
                _FeatureItem(
                    icon: "assets/icons/share.svg",
                    text: "Share Tasks Easily",
                    iconColor: Color(0xFFFF9800)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String text;
  final Color iconColor;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Color? iconColor;
  final AuthEvent? authEvent;

  const _SignInButton({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.iconColor,
    this.authEvent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isLoading = state is AuthLoadingState &&
            ((authEvent is LoginWithGoogle && icon.contains('google')) ||
                (authEvent is LoginWithApple && icon.contains('apple')));

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (authEvent != null) {
                      BlocProvider.of<AuthBloc>(context).add(authEvent!);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: borderColor != null
                    ? BorderSide(color: borderColor!)
                    : BorderSide.none,
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        icon,
                        height: 24,
                        width: 24,
                        colorFilter: icon.contains('google')
                            ? null
                            : ColorFilter.mode(
                                iconColor ?? Colors.white,
                                BlendMode.srcIn,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
