import 'package:flutter/material.dart';

class AppFullLogo extends StatelessWidget {
  const AppFullLogo({super.key, this.height = 140});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/logo1.png',
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class AppTextLogo extends StatelessWidget {
  const AppTextLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo2.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key, required this.child, this.logoHeight = 36});

  final Widget child;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppTextLogo(height: logoHeight),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
