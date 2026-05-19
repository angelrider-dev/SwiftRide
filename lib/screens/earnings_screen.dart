import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../widgets/rider_drawer.dart';
import 'rider_profile_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _totalRides = 0;
  double _totalEarnings = 0;
  double _todayEarnings = 0;
  int _todayRides = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentRides = [];

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('riderId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .get();

      double total = 0;
      double today = 0;
      int todayCount = 0;
      List<Map<String, dynamic>> rides = [];

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final fare = (data['fare'] ?? 0).toDouble();
        total += fare;

        final createdAt = data['createdAt']?.toDate();
        if (createdAt != null &&
            createdAt.day == now.day &&
            createdAt.month == now.month &&
            createdAt.year == now.year) {
          today += fare;
          todayCount++;
        }

        rides.add(data);
      }

      setState(() {
        _totalEarnings = total;
        _totalRides = snapshot.docs.length;
        _todayEarnings = today;
        _todayRides = todayCount;
        _recentRides = rides.take(10).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const RiderDrawer(currentScreen: 'earnings'),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('My Earnings', style: TextStyle(color: whiteColor)),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Earnings Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryBlue, lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Earnings',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PKR ${_totalEarnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: whiteColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalRides total rides completed',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today',
                          'PKR ${_todayEarnings.toStringAsFixed(0)}',
                          '$_todayRides rides',
                          Icons.today,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Rides',
                          '$_totalRides',
                          'completed',
                          Icons.directions_car,
                          accentOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _recentRides.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.history, color: greyColor, size: 60),
                                SizedBox(height: 12),
                                Text(
                                  'No completed rides yet!',
                                  style: TextStyle(color: greyColor, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: _recentRides.map((ride) {
                            return _buildTransaction(
                              '${ride['pickup']} → ${ride['dropoff']}',
                              ride['rideType'] ?? 'Car',
                              'PKR ${ride['fare'] ?? 0}',
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String amount,
    String subtitle,
    IconData icon,
    Color color,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: greyColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: greyColor, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTransaction(String route, String type, String amount) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.motorcycle, color: primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  type,
                  style: const TextStyle(color: greyColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}