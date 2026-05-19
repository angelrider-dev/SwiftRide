import 'package:flutter/material.dart';
import 'package:swift_ride/screens/gemini_chat_screen.dart';
import '../constants/colors.dart';
import 'booking_screen.dart';
import 'ride_history_screen.dart';
import 'profile_screen.dart';
// import 'rider_home_screen.dart';
// import 'user_selection_screen.dart';
import '../widgets/passenger_drawer.dart';
import 'gemini_chat_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GeminiChatScreen()),
          );
        },
        child: const Icon(Icons.smart_toy, color: whiteColor),
      ),
      drawer: const PassengerDrawer(currentScreen: 'home'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const RideHistoryScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Full Map Background
        // Full Map Background
        // Full Map Background
SizedBox.expand(
  child: kIsWeb
      ? Image.asset(
          'assets/images/map.jpg',
          fit: BoxFit.cover,
        )
      : GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(31.5204, 74.3587),
            zoom: 13,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {},
        ),
),

        // Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hamburger Menu
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

                    // Title
                    Column(
                      children: [
                        const Text(
                          'SwiftRide',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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

                    // Profile Icon
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
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

              const Spacer(),

              // Bottom Search Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      GestureDetector(
                        onTap: () {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return const BookingScreen();
      },
    ),
  );
},
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: greyColor.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: accentOrange),
                              SizedBox(width: 12),
                              Text(
                                'Where do you want to go?',
                                style: TextStyle(
                                  color: greyColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
