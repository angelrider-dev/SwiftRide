import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'passenger_home_screen.dart';
import 'rider_home_screen.dart';
import 'signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  final bool isRider;
  const LoginScreen({super.key, this.isRider = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isRider = false;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isRider = widget.isRider;
  }

Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if new user
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!doc.exists) {
      // Save new user data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user!.displayName ?? 'User',
        'username': userCredential.user!.email!.split('@')[0].toLowerCase(),
        'email': userCredential.user!.email,
        'phone': '',
        'role': _isRider ? 'rider' : 'passenger',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;

   String role;
if (doc.exists) {
  role = doc.data()?['role'] ?? 'passenger';
} else {
  role = _isRider ? 'rider' : 'passenger';
}

    if (role == 'rider') {
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
  } catch (e) {
    _showError('Google Sign-in failed: ${e.toString()}');
  } finally {
    setState(() => _isLoading = false);
  }
}
Future<void> _forgotPassword() async {
  final emailController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Forgot Password',
        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter your email to reset password',
            style: TextStyle(color: greyColor, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email, color: primaryBlue),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: greyColor)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (emailController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your email!'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: emailController.text.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset email sent! Check your inbox.'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
          child: const Text('Send', style: TextStyle(color: whiteColor)),
        ),
      ],
    ),
  );
}
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

          // Login Card
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
                            'Welcome back!',
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
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: !_isRider
                                      ? const LinearGradient(
                                          colors: [primaryBlue, lightBlue])
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
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: _isRider
                                      ? const LinearGradient(
                                          colors: [primaryBlue, lightBlue])
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

                    // Username Field
                    _buildLabel('Username'),
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'Enter your username',
                      icon: Icons.alternate_email,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildLabel('Password'),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(color: greyColor),
                        prefixIcon: const Icon(Icons.lock_outlined, color: primaryBlue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primaryBlue,
                          ),
                          onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
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
                          borderSide:
                              const BorderSide(color: primaryBlue, width: 2),
                        ),
                      ),
                    ),

                    // Forgot Password
                    Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: _forgotPassword,
    child: const Text(
      'Forgot Password?',
      style: TextStyle(color: accentOrange, fontWeight: FontWeight.w600),
    ),
  ),
),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_usernameController.text.isEmpty ||
                                    _passwordController.text.isEmpty) {
                                  _showError('Please fill all fields!');
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  // Find user by username
                                  final usernameQuery = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .where('username',
                                          isEqualTo: _usernameController.text
                                              .trim()
                                              .toLowerCase())
                                      .get();

                                  if (usernameQuery.docs.isEmpty) {
                                    _showError('Username not found!');
                                    setState(() => _isLoading = false);
                                    return;
                                  }

                                  final userDoc = usernameQuery.docs.first;
                                  final email = userDoc.data()['email'];
                                  final role =
                                      userDoc.data()['role'] ?? 'passenger';

                                  // Login with email
                                  await _auth.signInWithEmailAndPassword(
                                    email: email,
                                    password:
                                        _passwordController.text.trim(),
                                  );

                                  if (!mounted) return;

                                  // Check role matches
                                  if (_isRider && role != 'rider') {
                                    await _auth.signOut();
                                    _showError(
                                        'This is not a rider account! Please login as Passenger.');
                                    setState(() => _isLoading = false);
                                    return;
                                  }

                                  if (!_isRider && role != 'passenger') {
                                    await _auth.signOut();
                                    _showError(
                                        'This is not a passenger account! Please login as Rider.');
                                    setState(() => _isLoading = false);
                                    return;
                                  }

                                  if (role == 'rider') {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RiderHomeScreen()),
                                      (route) => false,
                                    );
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PassengerHomeScreen()),
                                      (route) => false,
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  String message = 'Login failed!';
                                  if (e.code == 'wrong-password') {
                                    message = 'Wrong password!';
                                  } else if (e.code == 'too-many-requests') {
                                    message =
                                        'Too many attempts! Try again later.';
                                  }
                                  _showError(message);
                                } catch (e) {
                                  _showError('Error: ${e.toString()}');
                                } finally {
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                }
                              },
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
                                'Login',
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
                    // Google Sign In Button
SizedBox(
  width: double.infinity,
  height: 52,
  child: OutlinedButton.icon(
    onPressed: _isLoading ? null : _signInWithGoogle,
    icon: Image.asset(
      'assets/images/icon-image.png',
      height: 24,
      width: 24,
    ),
    label: const Text(
      'Continue with Google',
      style: TextStyle(
        color: primaryBlue,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: primaryBlue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),
const SizedBox(height: 16),
                    const SizedBox(height: 16),

                    // Signup Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(color: greyColor)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SignupScreen(isRider: _isRider),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
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
        style: const TextStyle(
            color: primaryBlue, fontWeight: FontWeight.w500),
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