import 'package:flutter/material.dart';
import '../constants/colors.dart';
// import 'passenger_home_screen.dart';
// import 'rider_home_screen.dart';
import 'login_screen.dart';
class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
           child: Image.asset(
                  'assets/images/User_selection.jpg',
  fit: BoxFit.cover,
),
          ),

          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: accentOrange,
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: accentOrange.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: whiteColor,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App Name
                    const Text(
                      'SwiftRide',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your ride, your way',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Passenger Button
                    SizedBox(
                      width: 260,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(isRider: false),
    ),
  );
},
                        icon: const Icon(Icons.person, color: whiteColor),
                        label: const Text(
                          'Continue as Passenger',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Driver Button
                    SizedBox(
                      width: 260,
                      height: 55,
                      child: ElevatedButton.icon(
                       onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(isRider: true),
    ),
  );
},
                        icon: const Icon(Icons.motorcycle, color: primaryBlue),
                        label: const Text(
                          'Continue as Driver',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Bottom text
                    const Text(
                      'Fast • Safe • Reliable',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}