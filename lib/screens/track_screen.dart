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
    _locationListener = FirebaseFirestore.instance
        .collection("sensor_data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var latestDoc = snapshot.docs.first;
        var data = latestDoc.data() as Map<String, dynamic>;
        var locationData = {
          "latitude": data["latitude"],
          "longitude": data["longitude"],
          "timestamp": data["timestamp"],
        };
        setState(() {
          latestLocation = locationData;
        });
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Fetching location...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      latestLocation["latitude"] ?? 0.0,
                      latestLocation["longitude"] ?? 0.0,
                    ),
                    initialZoom: 17.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          child: Image.asset(
                            'assets/images/custom_marker.png',
                            width: 40,
                            height: 40,
                          ),
                          // child: const Icon(
                          //   Icons.location_pin,
                          //   color: Colors.red,
                          //   size: 40,
                          // ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (latestLocation["latitude"] != null &&
              latestLocation["longitude"] != null) {
            mapController.move(
              LatLng(
                latestLocation["latitude"],
                latestLocation["longitude"],
              ),
              17.5,
            );
          }
        },
        child: const Icon(Icons.my_location),
        tooltip: 'Center Map',
      ),
    );
  }
}
