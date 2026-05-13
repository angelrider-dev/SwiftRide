import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/user_selection_screen.dart';
import '../screens/passenger_home_screen.dart';
import '../screens/earnings_screen.dart';
import '../screens/rider_profile_screen.dart';
import '../screens/rider_home_screen.dart';
import '../screens/help_support_screen.dart';

class RiderDrawer extends StatelessWidget {
  final String currentScreen;
  const RiderDrawer({super.key, this.currentScreen = 'home'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: whiteColor,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(color: primaryBlue),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: accentOrange,
                  child: Icon(Icons.person, color: whiteColor, size: 40),
                ),
                SizedBox(height: 12),
                Text(
                  'Ali Rider',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Honda 125 • ABC-123',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  'Rider',
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

          // Home
          _buildItem(
            context,
            icon: Icons.home,
            title: 'Home',
            isActive: currentScreen == 'home',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RiderHomeScreen()),
                (route) => false,
              );
            },
          ),

          // Earnings
          _buildItem(
            context,
            icon: Icons.attach_money,
            title: 'Earnings',
            isActive: currentScreen == 'earnings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EarningsScreen()));
            },
          ),

          // Profile
          _buildItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            isActive: currentScreen == 'profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RiderProfileScreen()));
            },
          ),

          const Divider(),

          // Switch to Passenger
          _buildItem(
            context,
            icon: Icons.person_outline,
            title: 'Switch to Passenger',
            isActive: false,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
                (route) => false,
              );
            },
          ),

          // Help
          _buildItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            isActive: false,
            onTap: () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
  );
},

          ),

          // Logout
          _buildItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            isActive: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to logout?', style: TextStyle(color: greyColor)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: greyColor)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout', style: TextStyle(color: whiteColor)),
                    ),
                  ],
                ),
              );
            },
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('SwiftRide v1.0.0', style: TextStyle(color: greyColor, fontSize: 12)),
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