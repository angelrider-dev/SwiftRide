import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../widgets/rider_drawer.dart';

class RideRequestScreen extends StatelessWidget {
  final String rideId;
  final Map<String, dynamic> rideData;

  const RideRequestScreen({
    super.key,
    required this.rideId,
    required this.rideData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const RiderDrawer(currentScreen: 'home'),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Ride Request', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: whiteColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Passenger Info
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
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: whiteColor,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passenger',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: accentOrange, size: 16),
                          Text(' 5.0', style: TextStyle(color: greyColor)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'PKR ${rideData['fare'] ?? 0}',
                      style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Info
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
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 14),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pickup',
                            style: TextStyle(color: greyColor, fontSize: 12),
                          ),
                          Text(
                            rideData['pickup'] ?? '',
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    height: 30,
                    width: 2,
                    color: greyColor,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: accentOrange,
                        size: 14,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dropoff',
                            style: TextStyle(color: greyColor, fontSize: 12),
                          ),
                          Text(
                            rideData['dropoff'] ?? '',
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ride Type & Fare
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          color: primaryBlue,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rideData['rideType'] ?? 'Car',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Ride Type',
                          style: TextStyle(color: greyColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: primaryBlue,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PKR ${rideData['fare'] ?? 0}',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Fare',
                          style: TextStyle(color: greyColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Accept & Reject Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('rides')
                            .doc(rideId)
                            .update({'status': 'cancelled'});
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .add({
                              'userId': rideData['passengerId'],
                              'title': 'Ride Cancelled ❌',
                              'message':
                                  'Your ride request was cancelled. Please try again.',
                              'type': 'ride',
                              'isRead': false,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ride Rejected!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      icon: const Icon(Icons.close, color: whiteColor),
                      label: const Text(
                        'Reject',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final otpController = TextEditingController();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Enter OTP',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Ask passenger for OTP to start ride',
                                  style: TextStyle(
                                    color: greyColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                    color: primaryBlue,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '----',
                                    hintStyle: const TextStyle(
                                      color: greyColor,
                                    ),
                                    filled: true,
                                    fillColor: bgColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    counterText: '',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: greyColor),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (otpController.text ==
                                      rideData['otp'].toString()) {
                                    Navigator.pop(context);
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    // After status update
                                    await FirebaseFirestore.instance
                                        .collection('notifications')
                                        .add({
                                          'userId': rideData['passengerId'],
                                          'title': 'Ride Accepted! 🚗',
                                          'message':
                                              'Your driver is on the way to pickup location.',
                                          'type': 'ride',
                                          'isRead': false,
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Ride Accepted! OTP Verified ✅',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Wrong OTP! Try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                ),
                                child: const Text(
                                  'Verify',
                                  style: TextStyle(color: whiteColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, color: whiteColor),
                      label: const Text(
                        'Accept',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
