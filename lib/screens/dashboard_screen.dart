// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   double currentSpeed = 0.0;
//   String wrongSideStatus = 'Loading...';
//   String helmetStatus = 'Loading...';
//   String wrongSideTimestamp = '';
//   String helmetTimestamp = '';

//   late StreamSubscription<QuerySnapshot> _speedListener;
//   late StreamSubscription<QuerySnapshot> _wrongSideListener;
//   late StreamSubscription<QuerySnapshot> _helmetListener;

//   @override
//   void initState() {
//     super.initState();

//     // Speed data listener
//     _speedListener = FirebaseFirestore.instance
//         .collection("sensor_data")
//         .orderBy("timestamp", descending: true)
//         .limit(1)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         var data = snapshot.docs.first.data() as Map<String, dynamic>;
//         setState(() {
//           currentSpeed = (data["speed"] ?? 0.0).toDouble();
//         });
//       }
//     });

//     // Wrongside data listener
//     _wrongSideListener = FirebaseFirestore.instance
//         .collection("wrongside-data")
//         .orderBy("timestamp", descending: true)
//         .limit(1)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         var data = snapshot.docs.first.data() as Map<String, dynamic>;
//         setState(() {
//           wrongSideStatus = data["status"] ?? 'No Data';
//           wrongSideTimestamp = _calculateTimeDifference(data["timestamp"]);
//         });
//       }
//     });

//     // Helmet data listener
//     _helmetListener = FirebaseFirestore.instance
//         .collection("helmet-data")
//         .orderBy("timestamp", descending: true)
//         .limit(1)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         var data = snapshot.docs.first.data() as Map<String, dynamic>;
//         setState(() {
//           helmetStatus = data["status"] ?? 'No Data';
//           helmetTimestamp = _calculateTimeDifference(data["timestamp"]);
//         });
//       }
//     });
//   }

//   String _calculateTimeDifference(Timestamp? timestamp) {
//     if (timestamp == null) return '';
    
//     final now = DateTime.now();
//     final dataTime = timestamp.toDate();
//     final difference = now.difference(dataTime);

//     if (difference.inSeconds < 60) {
//       return '${difference.inSeconds} sec ago';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} min ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} hr ago';
//     } else {
//       return '${difference.inDays} days ago';
//     }
//   }

//   @override
//   void dispose() {
//     _speedListener.cancel();
//     _wrongSideListener.cancel();
//     _helmetListener.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 24),
//               // Speed Tile 
//               Expanded(
//                 child: DashboardTile(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Current Speed',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             currentSpeed.toStringAsFixed(1),
//                             style: TextStyle(
//                               fontSize: 48,
//                               fontWeight: FontWeight.bold,
//                               color: currentSpeed > 30 ? Colors.red : Colors.black87,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Text(
//                               ' km/h',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: currentSpeed > 30 ? Colors.red : Colors.black54,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       LinearProgressIndicator(
//                         value: currentSpeed / 100, 
//                         backgroundColor: Colors.blue.withOpacity(0.1),
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           currentSpeed > 30 ? Colors.red : Colors.blue,
//                         ),
//                       ),
//                       if (currentSpeed > 30) 
//                         const Padding(
//                           padding: EdgeInsets.only(top: 8.0),
//                           child: Text(
//                             'Over Speed',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Wrongside Data Tile
//               Expanded(
//                 child: DashboardTile(
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Wrongside Status',
//                           style: TextStyle(
//                             color: Colors.black.withOpacity(0.6),
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           wrongSideStatus,
//                           style: const TextStyle(
//                             color: Colors.black87,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           wrongSideTimestamp,
//                           style: TextStyle(
//                             color: Colors.black.withOpacity(0.5),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Helmet Data Tile
//               Expanded(
//                 child: DashboardTile(
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Helmet Status',
//                           style: TextStyle(
//                             color: Colors.black.withOpacity(0.6),
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           helmetStatus,
//                           style: const TextStyle(
//                             color: Colors.black87,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           helmetTimestamp,
//                           style: TextStyle(
//                             color: Colors.black.withOpacity(0.5),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DashboardTile extends StatelessWidget {
//   final Widget child;

//   const DashboardTile({
//     super.key,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }



import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.grey[100],
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Current Speed',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentSpeed.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: currentSpeed > 30 ? Colors.red : Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              ' km/h',
                              style: TextStyle(
                                fontSize: 20,
                                color: currentSpeed > 30 ? Colors.red : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: currentSpeed / 100, 
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentSpeed > 30 ? Colors.red : Colors.blue,
                        ),
                      ),
                      if (currentSpeed > 30) 
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Over Speed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Wrongside Data Tile
              Expanded(
                child: DashboardTile(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wrongside Status',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          wrongSideStatus,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          wrongSideTimestamp,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Helmet Data Tile
              Expanded(
                child: DashboardTile(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Helmet Status',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          helmetStatus,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          helmetTimestamp,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
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

  const DashboardTile({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
