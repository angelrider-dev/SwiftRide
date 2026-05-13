import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'earnings_screen.dart';
import '../widgets/rider_drawer.dart';


class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const RiderDrawer(currentScreen: 'profile'),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          'Rider Profile',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: const Icon(Icons.person, color: whiteColor, size: 55),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ali Rider',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '+92 300 1234567',
                    style: TextStyle(color: whiteColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Verified Rider',
                      style: TextStyle(color: whiteColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('142', 'Total Rides'),
                  _buildStatCard('4.8 ⭐', 'Rating'),
                  _buildStatCard('PKR 24k', 'Earned'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vehicle Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
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
                      'Vehicle Information',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildVehicleInfo(Icons.motorcycle, 'Vehicle', 'Honda 125'),
                    _buildVehicleInfo(Icons.confirmation_number, 'Plate Number', 'ABC-123'),
                    _buildVehicleInfo(Icons.color_lens, 'Color', 'Black'),
                    _buildVehicleInfo(Icons.calendar_today, 'Year', '2022'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(Icons.edit, 'Edit Profile', () {}),
                  _buildMenuItem(Icons.attach_money, 'Earnings', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EarningsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.star, 'My Reviews', () {}),
                  _buildMenuItem(Icons.help, 'Help & Support', () {}),
                  _buildMenuItem(Icons.logout, 'Logout', () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

    
  }
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            value,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: greyColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentOrange, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: greyColor, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, color: primaryBlue, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: greyColor, size: 16),
          ],
        ),
      ),
    );
  }
