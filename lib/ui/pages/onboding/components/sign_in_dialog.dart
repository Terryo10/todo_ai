import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showCustomSignInDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Container(
          height: 520,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
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
                _FeatureItem(
                  icon: "assets/icons/ai.svg", 
                  text: "AI-Generated Tasks",
                  iconColor: Color(0xFF6C63FF),
                ),
                _FeatureItem(
                  icon: "assets/icons/reminder.svg", 
                  text: "Smart Reminders",
                  iconColor: Color(0xFF4CAF50),
                ),
                _FeatureItem(
                  icon: "assets/icons/organize.svg", 
                  text: "Effortless Organization",
                  iconColor: Color(0xFF2196F3),
                ),
                _FeatureItem(
                  icon: "assets/icons/sync.svg", 
                  text: "Sync Across Devices",
                  iconColor: Color(0xFF9C27B0),
                ),
                _FeatureItem(
                  icon: "assets/icons/share.svg", 
                  text: "Share Tasks Easily",
                  iconColor: Color(0xFFFF9800),
                ),
                const Spacer(),
                _SignInButton(
                  icon: "assets/icons/google.svg",
                  text: "Continue with Google",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                  // Leave iconColor null for Google to keep its multi-color logo
                ),
                _SignInButton(
                  icon: "assets/icons/facebook.svg",
                  text: "Continue with Facebook",
                  backgroundColor: Color(0xFF1877F2),
                  textColor: Colors.white,
                  iconColor: Colors.white,  // White Facebook icon
                ),
                _SignInButton(
                  icon: "assets/icons/apple.svg",
                  text: "Continue with Apple",
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  iconColor: Colors.white,  // White Apple icon
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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
            color: iconColor,
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

  const _SignInButton({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ElevatedButton(
        onPressed: () {},
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 24,
              width: 24,
              color: iconColor,
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
  }
}