import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';

class RatingScreen extends StatefulWidget {
  final String rideId;
  final String riderId;

  const RatingScreen({
    super.key,
    required this.rideId,
    required this.riderId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Save rating to Firestore
      await FirebaseFirestore.instance.collection('ratings').add({
        'rideId': widget.rideId,
        'riderId': widget.riderId,
        'passengerId': user!.uid,
        'rating': _selectedRating,
        'review': _reviewController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update ride with rating
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .update({'rating': _selectedRating, 'isRated': true});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Rate Your Ride', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, lightBlue],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: accentOrange,
                    child: Icon(Icons.person, color: whiteColor, size: 45),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'How was your ride?',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rate your driver',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Star Rating
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
                  const Text(
                    'Tap to rate',
                    style: TextStyle(color: greyColor, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            index < _selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: accentOrange,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getRatingText(),
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Review Text Field
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
                    'Write a Review (Optional)',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: const TextStyle(color: greyColor),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('Great Driver! 👍'),
                _buildTag('Very Punctual ⏰'),
                _buildTag('Clean Vehicle 🚗'),
                _buildTag('Safe Driving 🛡️'),
                _buildTag('Friendly 😊'),
                _buildTag('Good Music 🎵'),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: whiteColor)
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Skip Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: greyColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_selectedRating) {
      case 1:
        return 'Very Poor 😞';
      case 2:
        return 'Poor 😕';
      case 3:
        return 'Average 😐';
      case 4:
        return 'Good 😊';
      case 5:
        return 'Excellent! 🌟';
      default:
        return '';
    }
  }

  Widget _buildTag(String tag) {
    return GestureDetector(
      onTap: () {
        final current = _reviewController.text;
        _reviewController.text = current.isEmpty ? tag : '$current, $tag';
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBlue.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: const TextStyle(color: primaryBlue, fontSize: 12),
        ),
      ),
    );
  }
}