import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../widgets/rider_drawer.dart';
import 'earnings_screen.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  String _name = 'Loading...';
  String _phone = '';
  String _email = '';
  String _vehicle = '';
  String _plateNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
int _totalRides = 0;
double _rating = 5.0;
int _totalEarned = 0;
  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _name = doc.data()?['name'] ?? 'Rider';
        _phone = doc.data()?['phone'] ?? '';
        _email = doc.data()?['email'] ?? '';
        _vehicle = doc.data()?['vehicle'] ?? '';
        _plateNumber = doc.data()?['plateNumber'] ?? '';
      });
    }

    // Load rides data
    final ridesSnapshot = await FirebaseFirestore.instance
        .collection('rides')
        .where('riderId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
        .get();

    // Load ratings
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('riderId', isEqualTo: user.uid)
        .get();

    double totalRating = 0;
    if (ratingsSnapshot.docs.isNotEmpty) {
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 5).toDouble();
      }
      totalRating = totalRating / ratingsSnapshot.docs.length;
    } else {
      totalRating = 5.0;
    }

    int totalEarned = ridesSnapshot.docs.fold(
      0,
      (sum, doc) => sum + (doc.data()['fare'] as int? ?? 0),
    );

    setState(() {
      _totalRides = ridesSnapshot.docs.length;
      _rating = totalRating;
      _totalEarned = totalEarned;
      _isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const RiderDrawer(currentScreen: 'profile'),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Rider Profile', style: TextStyle(color: whiteColor)),
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
                        Text(
                          _name,
                          style: const TextStyle(
                            color: whiteColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _phone,
                          style: const TextStyle(color: whiteColor, fontSize: 14),
                        ),
                        Text(
                          _email,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                        _buildStatCard('$_totalRides', 'Total Rides'),
_buildStatCard('${_rating.toStringAsFixed(1)} ⭐', 'Rating'),
_buildStatCard('PKR $_totalEarned', 'Earned'),
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
                          _buildVehicleInfo(Icons.motorcycle, 'Vehicle', _vehicle.isEmpty ? 'Not set' : _vehicle),
                          _buildVehicleInfo(Icons.confirmation_number, 'Plate Number', _plateNumber.isEmpty ? 'Not set' : _plateNumber),
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
                        _buildMenuItem(Icons.edit, 'Edit Profile', () => _showEditDialog()),
                        _buildMenuItem(Icons.attach_money, 'Earnings', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EarningsScreen()),
                          );
                        }),
                        _buildMenuItem(Icons.star, 'My Reviews', () {}),
                        _buildMenuItem(Icons.help, 'Help & Support', () {}),
                        _buildMenuItem(Icons.logout, 'Logout', () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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

  void _showEditDialog() {
    final nameController = TextEditingController(text: _name);
    final phoneController = TextEditingController(text: _phone);
    final vehicleController = TextEditingController(text: _vehicle);
    final plateController = TextEditingController(text: _plateNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile', style: TextStyle(color: primaryBlue)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person, color: primaryBlue),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone, color: primaryBlue),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle',
                  prefixIcon: Icon(Icons.motorcycle, color: primaryBlue),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  prefixIcon: Icon(Icons.confirmation_number, color: primaryBlue),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: greyColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'vehicle': vehicleController.text.trim(),
                'plateNumber': plateController.text.trim(),
              });
              setState(() {
                _name = nameController.text.trim();
                _phone = phoneController.text.trim();
                _vehicle = vehicleController.text.trim();
                _plateNumber = plateController.text.trim();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Save', style: TextStyle(color: whiteColor)),
          ),
        ],
      ),
    );
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
          Text(label, style: const TextStyle(color: greyColor, fontSize: 12)),
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
}