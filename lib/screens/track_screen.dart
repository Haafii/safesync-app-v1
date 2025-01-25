import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  Map<String, dynamic> latestLocation = {};
  late StreamSubscription<QuerySnapshot> _locationListener;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    // Listen to Firestore for location updates
    _locationListener = FirebaseFirestore.instance
        .collection("sensor_data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var latestDoc = snapshot.docs.first;
        var data = latestDoc.data() as Map<String, dynamic>;

        // Only store location data
        var locationData = {
          "latitude": data["latitude"],
          "longitude": data["longitude"],
        };

        setState(() {
          latestLocation = locationData;
        });

        // Update map position when new coordinates arrive
        if (data["latitude"] != null && data["longitude"] != null) {
          mapController.move(
            LatLng(data["latitude"], data["longitude"]),
            15.0,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _locationListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: latestLocation.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  latestLocation["latitude"] ?? 0.0,
                  latestLocation["longitude"] ?? 0.0,
                ),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        latestLocation["latitude"] ?? 0.0,
                        latestLocation["longitude"] ?? 0.0,
                      ),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}