import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double currentSpeed = 0.0;
  String wrongSideStatus = 'Loading...';
  String helmetStatus = 'Loading...';
  String wrongSideTimestamp = '';
  String helmetTimestamp = '';
  late DateTime lastUpdatedSpeed;
  late DateTime lastUpdatedWrongSide;
  late DateTime lastUpdatedHelmet;

  late StreamSubscription<QuerySnapshot> _speedListener;
  late StreamSubscription<QuerySnapshot> _wrongSideListener;
  late StreamSubscription<QuerySnapshot> _helmetListener;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    lastUpdatedSpeed = DateTime.now();
    lastUpdatedWrongSide = DateTime.now();
    lastUpdatedHelmet = DateTime.now();

    // Speed data listener
    _speedListener = FirebaseFirestore.instance
        .collection("sensor_data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          currentSpeed = (data["speed"] ?? 0.0).toDouble();
          lastUpdatedSpeed = data["timestamp"].toDate();
        });
      }
    });

    // Wrongside data listener
    _wrongSideListener = FirebaseFirestore.instance
        .collection("wrongside-data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          wrongSideStatus = data["status"] ?? 'No Data';
          wrongSideTimestamp = _calculateTimeDifference(data["timestamp"]);
          lastUpdatedWrongSide = data["timestamp"].toDate();
        });
      }
    });

    // Helmet data listener
    _helmetListener = FirebaseFirestore.instance
        .collection("helmet-data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          helmetStatus = data["status"] ?? 'No Data';
          helmetTimestamp = _calculateTimeDifference(data["timestamp"]);
          lastUpdatedHelmet = data["timestamp"].toDate();
        });
      }
    });

    // Timer to check for new data every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), _checkForUpdates);
  }

  // Check for updates every 5 minutes
  void _checkForUpdates(Timer timer) {
    final now = DateTime.now();

    if (now.difference(lastUpdatedSpeed).inMinutes >= 5) {
      _fetchLatestSpeed();
    }
    if (now.difference(lastUpdatedWrongSide).inMinutes >= 5) {
      _fetchLatestWrongSideData();
    }
    if (now.difference(lastUpdatedHelmet).inMinutes >= 5) {
      _fetchLatestHelmetData();
    }
  }

  // Fetch the latest speed data
  void _fetchLatestSpeed() {
    FirebaseFirestore.instance
        .collection("sensor_data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          currentSpeed = (data["speed"] ?? 0.0).toDouble();
          lastUpdatedSpeed = data["timestamp"].toDate();
        });
      }
    });
  }

  // Fetch the latest wrongside data
  void _fetchLatestWrongSideData() {
    FirebaseFirestore.instance
        .collection("wrongside-data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          wrongSideStatus = data["status"] ?? 'No Data';
          wrongSideTimestamp = _calculateTimeDifference(data["timestamp"]);
          lastUpdatedWrongSide = data["timestamp"].toDate();
        });
      }
    });
  }

  // Fetch the latest helmet data
  void _fetchLatestHelmetData() {
    FirebaseFirestore.instance
        .collection("helmet-data")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          helmetStatus = data["status"] ?? 'No Data';
          helmetTimestamp = _calculateTimeDifference(data["timestamp"]);
          lastUpdatedHelmet = data["timestamp"].toDate();
        });
      }
    });
  }

  String _calculateTimeDifference(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final dataTime = timestamp.toDate();
    final difference = now.difference(dataTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  void dispose() {
    _speedListener.cancel();
    _wrongSideListener.cancel();
    _helmetListener.cancel();
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Set custom height for AppBar
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Custom AppBar color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), // Round bottom left corner
              topRight: Radius.circular(20), // Round bottom left corner
              bottomLeft: Radius.circular(20), // Round bottom left corner
              bottomRight: Radius.circular(20), // Round bottom right corner
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Add shadow effect
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3), // Shadow direction (downwards)
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min, // Ensures compact spacing
              children: [
                Text(
                  "Safe",
                  style: GoogleFonts.montserrat(
                    color:
                        Color.fromRGBO(162, 154, 209, 1), // Custom text color
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Image.asset(
                    'assets/images/photo_2025-02-10_13-33-20.png', // Replace with your image path
                    height: 26, // Adjust size
                  ),
                ),
                Text(
                  "Sync",
                  style: GoogleFonts.montserrat(
                    color: Color.fromRGBO(162, 154, 209, 1),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent, // Keep AppBar transparent
            elevation: 0, // Remove default shadow
          ),
        ),
      ),
      backgroundColor: Color.fromRGBO(162, 154, 209, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Speed Tile
              Expanded(
                child: DashboardTile(
                  color: currentSpeed < 30
                      ? Colors.blue.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.speed,
                              color: Colors.blueGrey.shade700,
                              size: 35.0,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Current Speed',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currentSpeed.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: currentSpeed > 30
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                ' km/h',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: currentSpeed > 30
                                      ? Colors.red.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: currentSpeed / 100,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            currentSpeed > 30
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                        if (currentSpeed > 30)
                          Text(
                            'Over Speeding Please Slow Down!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Text(
                            'Speed Limit is 30 km/h',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Wrongside Data Tile
              Expanded(
                child: DashboardTile(
                  color: wrongSideStatus == 'Not Wrong Side'
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center horizontally
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                wrongSideStatus == 'Not Wrong Side'
                                    ? "✅On Right Track, \nSafe and Sound!"
                                    : "🛑Wrong Way⚠️ \nGet back on Track Now!",
                                textAlign:
                                    TextAlign.center, // Ensure text is centered
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: wrongSideStatus == 'Not Wrong Side'
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                wrongSideTimestamp,
                                textAlign:
                                    TextAlign.center, // Center the timestamp
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: DashboardTile(
                  color: helmetStatus == 'Loading...'
                      ? Colors.orange.shade50
                      : (helmetStatus == 'with helme'
                          ? Colors.green.shade50
                          : Colors.red.shade50),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center horizontally
                      children: [
                        helmetStatus == 'Loading...'
                            ? const CircularProgressIndicator()
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      helmetStatus == 'with helme'
                                          ? "✅Helmet on, \nYou are Safe Now! 🏍️"
                                          : "⛑️No Helmet? \nSafety at Risk!⚠️",
                                      textAlign: TextAlign
                                          .center, // Ensure text is centered
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: helmetStatus == 'with helme'
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      helmetTimestamp,
                                      textAlign: TextAlign
                                          .center, // Center the timestamp
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final Widget child;
  final Color color;

  const DashboardTile({
    super.key,
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
