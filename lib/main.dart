import 'package:flutter/material.dart';
import 'package:smartlocker/screens/auth/landing_screen.dart';
import 'package:smartlocker/services/auth_service.dart';
import 'package:smartlocker/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialise();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      home: const LandingScreen(),
    );
  }
}
