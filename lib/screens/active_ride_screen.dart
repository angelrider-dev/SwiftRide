import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'live_tracking_screen.dart';
import 'rating_screen.dart';

class ActiveRideScreen extends StatelessWidget {
  final String rideId;

  const ActiveRideScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Active Ride', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  'Leave Ride Tracking?',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'Your ride is still active. Are you sure you want to go back?',
                  style: TextStyle(color: greyColor),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Stay',
                      style: TextStyle(color: greyColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Leave',
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Ride not found!'));
          }

          final ride = snapshot.data!.data() as Map<String, dynamic>;
          final status = ride['status'] ?? 'pending';

          // Auto navigate when completed
          // Auto navigate when completed
          if (status == 'completed') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingScreen(
                    rideId: rideId,
                    riderId: ride['riderId'] ?? '',
                  ),
                ),
              );
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryBlue, lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        status == 'pending'
                            ? Icons.search
                            : status == 'accepted'
                            ? Icons.directions_car
                            : Icons.check_circle,
                        color: accentOrange,
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        status == 'pending'
                            ? 'Finding Driver...'
                            : status == 'accepted'
                            ? 'Driver is on the way!'
                            : 'Ride Completed!',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status == 'pending'
                            ? 'Please wait while we find you a driver'
                            : status == 'accepted'
                            ? 'Your driver is coming to pickup location'
                            : 'Thank you for riding with SwiftRide!',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress Steps
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStep(
                        'Ride Booked',
                        'Your ride request has been sent',
                        Icons.check_circle,
                        true,
                      ),
                      _buildStep(
                        'Driver Assigned',
                        status == 'pending'
                            ? 'Looking for driver...'
                            : 'Driver found!',
                        status == 'pending'
                            ? Icons.radio_button_unchecked
                            : Icons.check_circle,
                        status != 'pending',
                      ),
                      _buildStep(
                        'Driver Arriving',
                        status == 'accepted'
                            ? 'Driver is on the way'
                            : 'Waiting...',
                        status == 'accepted'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        status == 'accepted' || status == 'completed',
                      ),
                      _buildStep(
                        'Ride Completed',
                        status == 'completed'
                            ? 'Enjoy your day!'
                            : 'Waiting...',
                        status == 'completed'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        status == 'completed',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ride Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ride Details',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride['pickup'] ?? '',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: accentOrange,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride['dropoff'] ?? '',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ride Type',
                            style: TextStyle(color: greyColor),
                          ),
                          Text(
                            ride['rideType'] ?? 'Car',
                            style: const TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fare',
                            style: TextStyle(color: greyColor),
                          ),
                          Text(
                            'PKR ${ride['fare'] ?? 0}',
                            style: const TextStyle(
                              color: accentOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // OTP Card
                if (status == 'accepted')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentOrange),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Share this OTP with your driver',
                          style: TextStyle(color: greyColor, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ride['otp']?.toString() ?? '----',
                          style: const TextStyle(
                            color: accentOrange,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Show this to your driver to start the ride',
                          style: TextStyle(color: greyColor, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Cancel Button
                if (status == 'pending')
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('rides')
                            .doc(rideId)
                            .update({'status': 'cancelled'});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel Ride',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: isCompleted ? Colors.green : greyColor, size: 24),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? Colors.green : greyColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? primaryBlue : greyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: greyColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
