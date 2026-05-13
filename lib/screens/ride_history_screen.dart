import 'package:flutter/material.dart';
import '../constants/colors.dart';
// import 'profile_screen.dart';
import '../widgets/passenger_drawer.dart';
class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const PassengerDrawer(currentScreen: 'history'),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          'Ride History',
          style: TextStyle(color: whiteColor),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: whiteColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: greyColor, size: 80),
            SizedBox(height: 16),
            Text(
              'No rides yet!',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your ride history will appear here',
              style: TextStyle(color: greyColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

}
