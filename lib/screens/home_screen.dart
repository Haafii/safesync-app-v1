import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'track_screen.dart';
import 'camera_screen.dart';
import 'report_screen.dart';  // Import the new report screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TrackScreen(),
    const CameraScreen(),
    const RideReportsScreen(),  // New screen added here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,  // Set the type to fixed
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(  // New bottom navigation item
            icon: Icon(Icons.report),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}
