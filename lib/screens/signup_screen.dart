import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'login_screen.dart';
import 'passenger_home_screen.dart';
import 'rider_home_screen.dart';

class SignupScreen extends StatefulWidget {
  final bool isRider;
  const SignupScreen({super.key, this.isRider = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isRider = false;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isRider = widget.isRider;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _vehicleController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name!');
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showError('Please enter a username!');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email!');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number!');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showError('Please enter your password!');
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _showError('Password must be at least 6 characters!');
      return;
    }
    if (_isRider && _vehicleController.text.trim().isEmpty) {
      _showError('Please enter your vehicle name!');
      return;
    }
    if (_isRider && _plateController.text.trim().isEmpty) {
      _showError('Please enter your plate number!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if username already exists
      final usernameCheck = await _firestore
          .collection('users')
          .where(
            'username',
            isEqualTo: _usernameController.text.trim().toLowerCase(),
          )
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        _showError('Username already taken! Try another one.');
        setState(() => _isLoading = false);
        return;
      }

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data in Firestore
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim().toLowerCase(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _isRider ? 'rider' : 'passenger',
        'roles': _isRider ? ['rider'] : ['passenger'], // ← yeh add karo
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_isRider) {
        userData['vehicle'] = _vehicleController.text.trim();
        userData['plateNumber'] = _plateController.text.trim();
      }

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      if (!mounted) return;

      _showSuccess('Account created successfully!');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      if (_isRider) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RiderHomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password must be at least 6 characters!';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered!';
          break;
        case 'invalid-email':
          message = 'Invalid email format!';
          break;
        case 'network-request-failed':
          message = 'No internet connection!';
          break;
        default:
          message = 'Signup failed: ${e.message}';
      }
      _showError(message);
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/User_selection.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: whiteColor,
                  size: 24,
                ),
              ),
            ),
          ),

          // Signup Card
          Positioned(
            top: screenHeight * 0.20,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primaryBlue, lightBlue],
                              ),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: whiteColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'SwiftRide',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const Text(
                            'Create your account',
                            style: TextStyle(color: greyColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Toggle Passenger/Rider
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isRider = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: !_isRider
                                      ? const LinearGradient(
                                          colors: [primaryBlue, lightBlue],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Passenger',
                                    style: TextStyle(
                                      color: !_isRider ? whiteColor : greyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isRider = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: _isRider
                                      ? const LinearGradient(
                                          colors: [primaryBlue, lightBlue],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Rider',
                                    style: TextStyle(
                                      color: _isRider ? whiteColor : greyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    _buildLabel('Full Name'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Username Field
                    _buildLabel('Username'),
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'Choose a username e.g. john123',
                      icon: Icons.alternate_email,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildLabel('Email'),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    _buildLabel('Phone Number'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+92 300 1234567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildLabel('Password'),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Enter your password (min 6 chars)',
                        hintStyle: const TextStyle(color: greyColor),
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: primaryBlue,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primaryBlue,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rider Extra Fields
                    if (_isRider) ...[
                      _buildLabel('Vehicle Name'),
                      _buildTextField(
                        controller: _vehicleController,
                        hint: 'e.g. Honda 125',
                        icon: Icons.motorcycle_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Plate Number'),
                      _buildTextField(
                        controller: _plateController,
                        hint: 'e.g. ABC-123',
                        icon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: whiteColor)
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: TextStyle(color: greyColor)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: greyColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LoginScreen(isRider: _isRider),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: accentOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: greyColor),
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}
