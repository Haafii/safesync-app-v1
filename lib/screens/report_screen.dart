import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class RideReportsScreen extends StatefulWidget {
  const RideReportsScreen({Key? key}) : super(key: key);

  @override
  _RideReportsScreenState createState() => _RideReportsScreenState();
}

class _RideReportsScreenState extends State<RideReportsScreen> {
  List<Map<String, dynamic>> rides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRideReports();
  }

  Future<void> _fetchRideReports() async {
    try {
      // Get unique ride IDs from sensor_data
      QuerySnapshot sensorDataSnapshot = await FirebaseFirestore.instance
          .collection('sensor_data')
          .get();

      // Group data by ride_id
      Map<String, List<QueryDocumentSnapshot>> rideGroups = {};
      for (var doc in sensorDataSnapshot.docs) {
        String rideId = doc['ride_id'];
        rideGroups.putIfAbsent(rideId, () => []).add(doc);
      }

      // Fetch corresponding helmet and wrongside data for each ride
      List<Map<String, dynamic>> fetchedRides = [];
      
      for (var rideId in rideGroups.keys) {
        // Fetch sensor data for this ride
        List<Map<String, dynamic>> rideData = rideGroups[rideId]!
            .map((doc) => {
                  'latitude': doc['latitude'],
                  'longitude': doc['longitude'],
                  'speed': doc['speed'],
                  'timestamp': doc['timestamp'].toDate().toString(),
                })
            .toList();

        // Fetch helmet data for this ride
        QuerySnapshot helmetSnapshot = await FirebaseFirestore.instance
            .collection('helmet-data')
            .where('ride_id', isEqualTo: rideId)
            .get();
        
        List<Map<String, dynamic>> helmetData = helmetSnapshot.docs
            .map((doc) => {
                  'ride_id': doc['ride_id'],
                  'status': doc['status'],
                  'timestamp': doc['timestamp'].toDate().toString(),
                })
            .toList();

        // Fetch wrongside data for this ride
        QuerySnapshot wrongsideSnapshot = await FirebaseFirestore.instance
            .collection('wrongside-data')
            .where('ride_id', isEqualTo: rideId)
            .get();
        
        List<Map<String, dynamic>> wrongSideData = wrongsideSnapshot.docs
            .map((doc) => {
                  'ride_id': doc['ride_id'],
                  'status': doc['status'],
                  'timestamp': doc['timestamp'].toDate().toString(),
                })
            .toList();

        // Add to rides list
        fetchedRides.add({
          'rideId': rideId,
          'rideData': rideData,
          'wrongSideData': wrongSideData,
          'helmetData': helmetData,
        });
      }

      setState(() {
        rides = fetchedRides;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching ride reports: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Reports')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : rides.isEmpty
              ? const Center(child: Text('No ride reports found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    return RideReportItem(
                      rideData: rides[index]['rideData'],
                      wrongSideData: rides[index]['wrongSideData'],
                      helmetData: rides[index]['helmetData'],
                    );
                  },
                ),
    );
  }
}

// The rest of the code (RideReportItem class) remains the same as in the original implementation

class RideReportItem extends StatefulWidget {
  final List<Map<String, dynamic>> rideData;
  final List<Map<String, dynamic>> wrongSideData;
  final List<Map<String, dynamic>> helmetData;

  const RideReportItem({
    Key? key,
    required this.rideData,
    required this.wrongSideData,
    required this.helmetData,
  }) : super(key: key);

  @override
  _RideReportItemState createState() => _RideReportItemState();
}

class _RideReportItemState extends State<RideReportItem> {
  String endAddress = "Loading...";
  String startAddress = "Loading...";
  bool isExpanded = false;

  String initialHelmetStatus = "Loading...";
  List<Map<String, dynamic>> statusChanges = [];
  List<Map<String, dynamic>> wrongSideSummary = [];

  @override
  void initState() {
    super.initState();
    _getEndLocationName();
    _getStartLocationName();
    _processHelmetData();
    _processWrongSideData();
  }

  Future<void> _getEndLocationName() async {
    try {
      final lastPoint = widget.rideData.last;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        lastPoint["latitude"],
        lastPoint["longitude"],
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          endAddress = placemarks.first.locality ?? "Unknown Location";
        });
      }
    } catch (e) {
      print("Error getting location name: $e");
      setState(() {
        endAddress = "Location not found";
      });
    }
  }

  Future<void> _getStartLocationName() async {
    try {
      final firstPoint = widget.rideData.first;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        firstPoint["latitude"],
        firstPoint["longitude"],
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          startAddress = placemarks.first.locality ?? "Unknown Location";
        });
      }
    } catch (e) {
      print("Error getting start location name: $e");
      setState(() {
        startAddress = "Location not found";
      });
    }
  }

  void _processHelmetData() {
    if (widget.helmetData.isNotEmpty) {
      initialHelmetStatus = widget.helmetData.first['status'];

      for (int i = 1; i < widget.helmetData.length; i++) {
        if (widget.helmetData[i]['status'] !=
            widget.helmetData[i - 1]['status']) {
          statusChanges.add({
            'status': widget.helmetData[i]['status'],
            'timestamp': widget.helmetData[i]['timestamp'],
          });
        }
      }
    }
  }

  void _processWrongSideData() {
    for (int i = 1; i < widget.wrongSideData.length; i++) {
      if (widget.wrongSideData[i]['status'] == "Wrong Side") {
        wrongSideSummary.add({
          'status': widget.wrongSideData[i]['status'],
          'timestamp': widget.wrongSideData[i]['timestamp'],
        });
      }
    }
  }

String formatTimestamp(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp).toUtc();
  DateTime localTime = dateTime.toLocal(); // Convert to local time
  return DateFormat('dd MMMM yyyy, hh:mm a').format(localTime);
}


  double calculateAverageSpeed() {
    double totalSpeed =
        widget.rideData.fold(0, (sum, item) => sum + item['speed']);
    return totalSpeed / widget.rideData.length;
  }

  @override
  Widget build(BuildContext context) {
    final startTime = formatTimestamp(widget.rideData.first['timestamp']);
    final tileWidth = MediaQuery.of(context).size.width - 32;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "Ride from $startAddress to $endAddress",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(startTime),
              trailing: IconButton(
                icon: Icon(isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ),
            if (isExpanded) ...[
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapTile(tileWidth),
                    const SizedBox(height: 10),
                    _buildAverageSpeedTile(tileWidth),
                    const SizedBox(height: 10),
                    _buildWrongSideSummaryTile(tileWidth),
                    const SizedBox(height: 10),
                    _buildHelmetStatusTile(tileWidth),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

Widget _buildMapTile(double tileWidth) {
    // Sort the ride data by timestamp
    List<Map<String, dynamic>> sortedRideData = List.from(widget.rideData)
      ..sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

    // Create route points from sorted data
    List<LatLng> routePoints = sortedRideData
        .map((data) => LatLng(data['latitude'], data['longitude']))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 300,
          width: tileWidth,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: routePoints.first,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              // Add PolylineLayer to connect points
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 3,
                    color: Colors.blue.withOpacity(0.7),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Only start marker
                  Marker(
                    point: routePoints.first,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                  ),
                  // Only end marker
                  Marker(
                    point: routePoints.last,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAverageSpeedTile(double tileWidth) {
    double avgSpeed = calculateAverageSpeed();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: tileWidth,
        child: Card(
          color: Colors.blue[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.speed, color: Colors.blue, size: 30),
            title: const Text("Average Speed"),
            subtitle: Text("${avgSpeed.toStringAsFixed(2)} km/h"),
          ),
        ),
      ),
    );
  }

  Widget _buildWrongSideSummaryTile(double tileWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: tileWidth,
        child: Card(
          color: Colors.red[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red, size: 30),
            title: const Text("Wrong Side Summary"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wrongSideSummary.isNotEmpty
                  ? wrongSideSummary.map((summary) {
                      return Text(
                          "Wrong side at ${formatTimestamp(summary['timestamp'])}");
                    }).toList()
                  : [Text("No wrong side instances")],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelmetStatusTile(double tileWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: tileWidth,
        child: Card(
          color: Colors.green[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.security, color: Colors.green, size: 30),
            title: const Text("Helmet Status"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Initial Status: $initialHelmetStatus"),
                if (statusChanges.isNotEmpty)
                  ...statusChanges.map((change) {
                    return Text(
                        "Status changed to: ${change['status']} at ${formatTimestamp(change['timestamp'])}");
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


