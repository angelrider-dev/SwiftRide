import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/colors.dart';
import 'screens/user_selection_screen.dart';
import 'screens/splash_screen.dart';

// home: const UserSelectionScreen() ko replace karo:

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const SplashScreen(),
      
    );
  }
}