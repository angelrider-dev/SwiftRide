import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/user_selection_screen.dart';
import '../screens/rider_home_screen.dart';
import '../screens/ride_history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/passenger_home_screen.dart';
import '../screens/help_support_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/help_support_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// Help & Support onTap:
class PassengerDrawer extends StatefulWidget {
  final String currentScreen;
  const PassengerDrawer({super.key, this.currentScreen = 'home'});

  @override
  State<PassengerDrawer> createState() => _PassengerDrawerState();
}

class _PassengerDrawerState extends State<PassengerDrawer> {
  String _name = 'Loading...';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _name = doc.data()?['name'] ?? 'User';
          _phone = doc.data()?['phone'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: whiteColor,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(color: primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  },
  child: const CircleAvatar(
    radius: 35,
    backgroundColor: accentOrange,
    child: Icon(Icons.person, color: whiteColor, size: 40),
  ),
),
                
                const SizedBox(height: 12),
                Text(
                  _name,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _phone,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Passenger',
                  style: TextStyle(
                    color: accentOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildItem(
            context,
            icon: Icons.home,
            title: 'Home',
            isActive: widget.currentScreen == 'home',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const PassengerHomeScreen(),
                ),
                (route) => false,
              );
            },
          ),
          _buildItem(
            context,
            icon: Icons.history,
            title: 'Ride History',
            isActive: widget.currentScreen == 'history',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RideHistoryScreen(),
                ),
              );
            },
          ),
          _buildItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            isActive: widget.currentScreen == 'profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),
          _buildItem(
            context,
            icon: Icons.motorcycle,
            title: 'Switch to Rider',
            isActive: false,
            onTap: () async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final roles = List<String>.from(doc.data()?['roles'] ?? ['passenger']);
    
    if (roles.contains('rider')) {
      // Has rider account — switch!
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RiderHomeScreen()),
        (route) => false,
      );
    } else {
      // No rider account — show option to add
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'No Rider Account',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You don\'t have a Rider account. Would you like to add one?',
            style: TextStyle(color: greyColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: greyColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Add rider role
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'roles': FieldValue.arrayUnion(['rider']),
                });
                // Go to rider profile setup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rider account added! Please update your vehicle info in profile.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RiderHomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text('Add Rider Account', style: TextStyle(color: whiteColor)),
            ),
          ],
        ),
      );
    }
  }
},
          ),
          _buildItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _buildItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            isActive: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: greyColor),
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
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserSelectionScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Quit App',
            isActive: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Quit App',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to quit SwiftRide?',
                    style: TextStyle(color: greyColor),
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
                      onPressed: () {
                        Navigator.pop(context);
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Quit',
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SwiftRide v1.0.0',
              style: TextStyle(color: greyColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? accentOrange : primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? accentOrange : primaryBlue,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? accentOrange.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }
}
