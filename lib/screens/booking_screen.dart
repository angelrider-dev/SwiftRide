import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'map_picker_screen.dart';
import 'active_ride_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  String _selectedRideType = 'Car';
  bool _isLoading = false;
  bool _locationsSelected = false;
  String _selectedPayment = 'Cash';
  final Map<String, double> _baseFare = {'Car': 80, 'Bike': 40, 'Rickshaw': 50};

  final Map<String, double> _perKmRate = {
    'Car': 45,
    'Bike': 22,
    'Rickshaw': 28,
  };

  double _estimatedKm = 5.0;

  final List<Map<String, dynamic>> _rideTypes = [
    {
      'type': 'Car',
      'icon': Icons.directions_car,
      'description': 'Comfortable AC car',
    },
    {'type': 'Bike', 'icon': Icons.motorcycle, 'description': 'Fast bike ride'},
    {
      'type': 'Rickshaw',
      'icon': Icons.electric_rickshaw,
      'description': 'Affordable rickshaw',
    },
  ];

  int _calculateFare(String rideType) {
    final base = _baseFare[rideType] ?? 80;
    final perKm = _perKmRate[rideType] ?? 45;
    return (base + (perKm * _estimatedKm)).round();
  }

  void _checkLocations() {
    if (_pickupController.text.isNotEmpty &&
        _dropoffController.text.isNotEmpty) {
      setState(() {
        _locationsSelected = true;
        _estimatedKm = (2 + (DateTime.now().millisecond % 130) / 10);
      });
    } else {
      setState(() {
        _locationsSelected = false;
      });
    }
  }

  Widget _buildPaymentOption(String name, IconData icon, Color color) {
    final isSelected = _selectedPayment == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPayment = name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? whiteColor : color, size: 20),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? whiteColor : primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: greyColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          const Text(
            'Book a Ride',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Fields
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // Pickup
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _pickupController,
                                decoration: InputDecoration(
                                  hintText: 'Pickup location',
                                  hintStyle: const TextStyle(color: greyColor),
                                  border: InputBorder.none,
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Manual type button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: greyColor,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _pickupController.clear();
                                          });
                                        },
                                      ),
                                      // Map button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.map,
                                          color: accentOrange,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MapPickerScreen(
                                                    title:
                                                        'Select Pickup Location',
                                                  ),
                                            ),
                                          );
                                          if (result != null) {
                                            setState(() {
                                              _pickupController.text = result;
                                              _checkLocations();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                onChanged: (value) => _checkLocations(),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Dropoff
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: accentOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _dropoffController,
                                decoration: InputDecoration(
                                  hintText: 'Drop-off location',
                                  hintStyle: const TextStyle(color: greyColor),
                                  border: InputBorder.none,
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Manual type button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: greyColor,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _dropoffController.clear();
                                          });
                                        },
                                      ),
                                      // Map button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.map,
                                          color: accentOrange,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MapPickerScreen(
                                                    title:
                                                        'Select Dropoff Location',
                                                  ),
                                            ),
                                          );
                                          if (result != null) {
                                            setState(() {
                                              _dropoffController.text = result;
                                              _checkLocations();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                onChanged: (value) => _checkLocations(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ride Types
                  if (_locationsSelected) ...[
                    const Text(
                      'Select Ride Type',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.route, color: primaryBlue, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Est. distance: ${_estimatedKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _rideTypes.map((ride) {
                        final isSelected = _selectedRideType == ride['type'];
                        final fare = _calculateFare(ride['type']);
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRideType = ride['type']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryBlue : whiteColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primaryBlue
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  ride['icon'],
                                  color: isSelected ? whiteColor : primaryBlue,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride['type'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? whiteColor
                                              : primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ride['description'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : greyColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'PKR $fare',
                                  style: TextStyle(
                                    color: isSelected
                                        ? accentOrange
                                        : accentOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          _buildPaymentOption(
                            'Cash',
                            Icons.money,
                            Colors.green,
                          ),
                          _buildPaymentOption(
                            'JazzCash',
                            Icons.account_balance_wallet,
                            Colors.red,
                          ),
                          _buildPaymentOption(
                            'EasyPaisa',
                            Icons.account_balance_wallet,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 12),

                    // Fare Breakdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Base Fare',
                                style: TextStyle(color: greyColor),
                              ),
                              Text(
                                'PKR ${_baseFare[_selectedRideType]?.round()}',
                                style: const TextStyle(color: primaryBlue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_estimatedKm.toStringAsFixed(1)} km × PKR ${_perKmRate[_selectedRideType]?.round()}',
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'PKR ${(_perKmRate[_selectedRideType]! * _estimatedKm).round()}',
                                style: const TextStyle(color: primaryBlue),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'PKR ${_calculateFare(_selectedRideType)}',
                                style: const TextStyle(
                                  color: accentOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                try {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  final otp =
                                      (1000 + DateTime.now().millisecond % 9000)
                                          .toString();

                                  final docRef = await FirebaseFirestore
                                      .instance
                                      .collection('rides')
                                      .add({
                                        'passengerId': user!.uid,
                                        'pickup': _pickupController.text.trim(),
                                        'dropoff': _dropoffController.text
                                            .trim(),
                                        'rideType': _selectedRideType,
                                        'status': 'pending',
                                        'fare': _calculateFare(
                                          _selectedRideType,
                                        ),
                                        'distance': _estimatedKm,
                                        'otp': otp,
                                        'paymentMethod':
                                            _selectedPayment, // ← yahan
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });

                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ActiveRideScreen(rideId: docRef.id),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: whiteColor)
                            : const Text(
                                'Book Ride Now',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],

                  if (!_locationsSelected)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_searching,
                            color: greyColor.withOpacity(0.5),
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Select pickup & dropoff to see ride options',
                            style: TextStyle(color: greyColor, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
