import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../widgets/rider_drawer.dart';
import 'ride_request_screen.dart';
import 'rider_profile_screen.dart';
import 'gemini_chat_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  bool _isOnline = false;
  String _selectedArea = 'Gulberg, Lahore';
  String _riderName = 'Rider';

  final List<String> _areas = [
    'Gulberg, Lahore',
    'DHA Phase 5',
    'Johar Town',
    'Model Town',
    'Bahria Town',
    'Cantt',
    'Wapda Town',
    'Liberty Market',
    'Allama Iqbal Airport',
    'Anarkali Bazaar',
  ];

  @override
  void initState() {
    super.initState();
    _loadRiderName();
  }

  Future<void> _loadRiderName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _riderName = doc.data()?['name'] ?? 'Rider';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
  backgroundColor: accentOrange,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeminiChatScreen(),
      ),
    );
  },
  child: const Icon(Icons.smart_toy, color: whiteColor),
),
      backgroundColor: bgColor,
      drawer: const RiderDrawer(currentScreen: 'home'),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.menu, color: primaryBlue),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'SwiftRide',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: 60,
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiderProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person, color: whiteColor),
                    ),
                  ),
                ],
              ),
            ),

            // Welcome
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Welcome, $_riderName! 👋',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Online/Offline Toggle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isOnline ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? 'You are Online' : 'You are Offline',
                          style: TextStyle(
                            color: _isOnline ? Colors.green : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isOnline
                              ? 'Looking for rides...'
                              : 'Go online to get rides',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: (value) => setState(() => _isOnline = value),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            // Area Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedArea,
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                    style: const TextStyle(color: primaryBlue, fontSize: 15),
                    onChanged: (value) => setState(() => _selectedArea = value!),
                    items: _areas.map((area) {
                      return DropdownMenuItem(
                        value: area,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: accentOrange, size: 18),
                            const SizedBox(width: 8),
                            Text(area),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ride Requests — Real time from Firebase
            if (_isOnline)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rides')
                      .where('status', isEqualTo: 'pending')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: greyColor, size: 60),
                            SizedBox(height: 12),
                            Text(
                              'No ride requests yet!',
                              style: TextStyle(color: greyColor, fontSize: 16),
                            ),
                            Text(
                              'Waiting for passengers...',
                              style: TextStyle(color: greyColor, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    final rides = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rides.length,
                      itemBuilder: (context, index) {
                        final ride = rides[index].data() as Map<String, dynamic>;
                        final rideId = rides[index].id;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RideRequestScreen(
                                  rideId: rideId,
                                  rideData: ride,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.notifications_active,
                                        color: accentOrange, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'New Ride Request!',
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.circle,
                                        color: Colors.green, size: 12),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ride['pickup'] ?? '',
                                        style: const TextStyle(
                                            color: whiteColor, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: accentOrange, size: 12),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ride['dropoff'] ?? '',
                                        style: const TextStyle(
                                            color: whiteColor, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PKR ${ride['fare'] ?? 0}',
                                      style: const TextStyle(
                                        color: accentOrange,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: accentOrange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'View Request',
                                        style: TextStyle(
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

            if (!_isOnline)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.motorcycle,
                          color: greyColor.withOpacity(0.5), size: 100),
                      const SizedBox(height: 16),
                      const Text(
                        'Go Online to Start',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toggle the switch above to receive ride requests',
                        style: TextStyle(color: greyColor, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}