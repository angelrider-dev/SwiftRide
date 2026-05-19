import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String rideId;
  const LiveTrackingScreen({super.key, required this.rideId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Default Lahore location
  LatLng _riderLocation = const LatLng(31.5204, 74.3587);
  LatLng _passengerLocation = const LatLng(31.5304, 74.3687);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Live Tracking', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(widget.rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final ride = snapshot.data!.data() as Map<String, dynamic>;
            final status = ride['status'] ?? 'pending';

            // Update rider location if available
            if (ride['riderLat'] != null && ride['riderLng'] != null) {
              _riderLocation = LatLng(
                ride['riderLat'].toDouble(),
                ride['riderLng'].toDouble(),
              );
            }

            _updateMarkers(ride);

            return Stack(
              children: [
                // Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _riderLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

                // Bottom Info Card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'accepted'
                                ? Colors.green.withOpacity(0.1)
                                : primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                status == 'accepted'
                                    ? Icons.directions_car
                                    : Icons.search,
                                color: status == 'accepted'
                                    ? Colors.green
                                    : primaryBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status == 'accepted'
                                    ? 'Driver is on the way!'
                                    : 'Finding driver...',
                                style: TextStyle(
                                  color: status == 'accepted'
                                      ? Colors.green
                                      : primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Route Info
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                color: Colors.green, size: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ride['pickup'] ?? '',
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: accentOrange, size: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ride['dropoff'] ?? '',
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fare
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated Fare:',
                              style: TextStyle(color: greyColor),
                            ),
                            Text(
                              'PKR ${ride['fare'] ?? 0}',
                              style: const TextStyle(
                                color: accentOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Cancel Button
                        if (status == 'pending')
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('rides')
                                    .doc(widget.rideId)
                                    .update({'status': 'cancelled'});
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel Ride',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // My Location Button
                Positioned(
                  right: 16,
                  bottom: 250,
                  child: GestureDetector(
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(_riderLocation),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.my_location, color: primaryBlue),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: primaryBlue),
          );
        },
      ),
    );
  }

  void _updateMarkers(Map<String, dynamic> ride) {
    _markers.clear();

    // Rider marker
    _markers.add(
      Marker(
        markerId: const MarkerId('rider'),
        position: _riderLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Driver'),
      ),
    );

    // Passenger marker
    _markers.add(
      Marker(
        markerId: const MarkerId('passenger'),
        position: _passengerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );
  }
}