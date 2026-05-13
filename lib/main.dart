import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/user_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          secondary: accentOrange,
        ),
        fontFamily: 'Roboto',
      ),
      home: const UserSelectionScreen(),
    );
  }
}