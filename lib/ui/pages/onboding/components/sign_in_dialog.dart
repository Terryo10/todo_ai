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
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return _SignInDialog(onDismiss: onDismiss);
    },
  );
}

class _SignInDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const _SignInDialog({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState) {
          if (context.mounted) {
            onDismiss();
          }
        }
        if (state is AuthErrorState) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Center(
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoadingState) {
                    return SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Unlock Smart Productivity!",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SignInOptions(),
                      _SignInButton(
                        icon: "assets/icons/google.svg",
                        text: "Continue with Google",
                        backgroundColor: theme.colorScheme.surface,
                        textColor: theme.colorScheme.onSurface,
                        borderColor: theme.colorScheme.outline.withOpacity(0.5),
                        authEvent: LoginWithGoogle(),
                      ),
                      if (Platform.isIOS)
                        _SignInButton(
                          icon: "assets/icons/apple.svg",
                          text: "Continue with Apple",
                          backgroundColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.surface
                              : Colors.black,
                          textColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : Colors.white,
                          iconColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.onSurface
                              : Colors.white,
                          authEvent: LoginWithApple(),
                        ),
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
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
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
                    iconColor: theme.colorScheme.primary),
                _FeatureItem(
                    icon: "assets/icons/reminder.svg",
                    text: "Smart Reminders",
                    iconColor: theme.colorScheme.secondary),
                _FeatureItem(
                    icon: "assets/icons/organize.svg",
                    text: "Effortless Organization",
                    iconColor: theme.colorScheme.tertiary),
                _FeatureItem(
                    icon: "assets/icons/sync.svg",
                    text: "Sync Across Devices",
                    iconColor: theme.colorScheme.primary.withBlue(220)),
                _FeatureItem(
                    icon: "assets/icons/share.svg",
                    text: "Share Tasks Easily",
                    iconColor: theme.colorScheme.secondary.withRed(240)),
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
    final theme = Theme.of(context);

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
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);

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
              foregroundColor: textColor,
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
                                iconColor ?? theme.colorScheme.onPrimary,
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
