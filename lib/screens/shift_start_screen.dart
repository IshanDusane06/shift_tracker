// import 'package:flutter/material.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import '../services/location_service.dart';
// import 'shift_end_screen.dart';

// class ShiftStartScreen extends StatefulWidget {
//   const ShiftStartScreen({super.key});

//   @override
//   State<ShiftStartScreen> createState() => _ShiftStartScreenState();
// }

// class _ShiftStartScreenState extends State<ShiftStartScreen> {
//   final LocationService _locationService = LocationService();
//   bool _isTracking = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkTrackingStatus();
//   }

//   Future<void> _checkTrackingStatus() async {
//     final isTracking = await _locationService.isTracking();
//     setState(() {
//       _isTracking = isTracking;
//     });
//   }

//   Future<void> _startShift() async {
//     await _locationService.startBackgroundTracking();
//     setState(() {
//       _isTracking = true;
//     });
//   }

//   Future<void> _endShift() async {
//     if (_isTracking) {
//       await _locationService.stopTracking();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const ShiftEndScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SlidingUpPanel(
//         panel: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _isTracking ? 'End Shift' : 'Start Shift',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Container(
//                   width: 200,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isTracking ? _endShift : _startShift,
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       padding: EdgeInsets.all(15),
//                     ),
//                     child: Text(
//                       _isTracking ? 'End Shift' : 'Start Shift',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _isTracking ? 'Shift is Active' : 'Ready to Start Shift',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Icon(
//                 _isTracking ? Icons.pause_circle_filled : Icons.play_circle_filled,
//                 size: 100,
//                 color: _isTracking ? Colors.red : Colors.green,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
