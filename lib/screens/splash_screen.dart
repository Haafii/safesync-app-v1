// import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Import your existing HomeScreen

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotationAnimation;

//   final String appName = "SafeSync";

//   @override
//   void initState() {
//     super.initState();

//     // Initialize AnimationController
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );

//     // Define animations
//     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
//     );

//     _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );

//     // Start the animation
//     _controller.forward();

//     // Delay for 4 seconds and navigate to HomeScreen
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Transform(
//               transform: Matrix4.identity()
//                 ..setEntry(3, 2, 0.001) // Add perspective
//                 ..rotateX(_rotationAnimation.value * 3.14) // Rotate on X-axis
//                 ..scale(_scaleAnimation.value), // Scale up
//               alignment: Alignment.center,
//               child: Text(
//                 appName,
//                 style: TextStyle(
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                   shadows: [
//                     Shadow(
//                       offset: Offset(4 * (1 - _scaleAnimation.value),
//                           4 * (1 - _scaleAnimation.value)),
//                       blurRadius: 8,
//                       color: Colors.black.withOpacity(0.3),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



//final
// import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Import your existing HomeScreen

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Delay for 2 seconds and navigate to HomeScreen
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset(
//           "assets/images/photo_2025-02-10_13-33-20.png", // Ensure the correct path
//           width: 200, // Adjust size as needed
//           height: 200,
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Navigate to LoginScreen instead of HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()), // Go to LoginScreen first
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/photo_2025-02-10_13-33-20.png", 
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
