// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../services/location_service.dart';
// import '../models/location_point.dart';

// class ShiftEndScreen extends StatefulWidget {
//   const ShiftEndScreen({super.key});

//   @override
//   State<ShiftEndScreen> createState() => _ShiftEndScreenState();
// }

// class _ShiftEndScreenState extends State<ShiftEndScreen> {
//   final LocationService _locationService = LocationService();
//   GoogleMapController? _mapController;
//   List<LocationPoint> _locations = [];
//   double _totalDistance = 0;
//   Duration _totalDuration = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _loadLocations();
//   }

//   Future<void> _loadLocations() async {
//     final locations = await _locationService.getLocations();
//     setState(() {
//       _locations = locations;
//       _calculateDistanceAndDuration();
//     });
//   }

//   void _calculateDistanceAndDuration() {
//     if (_locations.length < 2) return;

//     double totalDistance = 0;
//     DateTime startTime = _locations.first.timestamp;
//     DateTime endTime = _locations.last.timestamp;

//     for (int i = 0; i < _locations.length - 1; i++) {
//       final start = _locations[i];
//       final end = _locations[i + 1];
//       totalDistance += _calculateDistance(
//         start.latitude,
//         start.longitude,
//         end.latitude,
//         end.longitude,
//       );
//     }

//     setState(() {
//       _totalDistance = totalDistance;
//       _totalDuration = endTime.difference(startTime);
//     });
//   }

//   double _calculateDistance(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const double earthRadius = 6371000; // meters

//     double dLat = (lat2 - lat1) * (3.141592653589793 / 180);
//     double dLon = (lon2 - lon1) * (3.141592653589793 / 180);

//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(lat1 * (3.141592653589793 / 180)) *
//             cos(lat2 * (3.141592653589793 / 180)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);

//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));

//     return earthRadius * c;
//   }

//   Future<void> _endShift() async {
//     await _locationService.clearLocations();
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shift Summary'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadLocations,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _locations.isNotEmpty
//                     ? LatLng(
//                         _locations.first.latitude, _locations.first.longitude)
//                     : const LatLng(0, 0),
//                 zoom: 15,
//               ),
//               polylines: {
//                 if (_locations.length >= 2)
//                   Polyline(
//                     polylineId: const PolylineId('route'),
//                     points: _locations
//                         .map((point) => LatLng(point.latitude, point.longitude))
//                         .toList(),
//                     color: Colors.blue,
//                     width: 5,
//                   ),
//               },
//               markers: {
//                 if (_locations.isNotEmpty)
//                   Marker(
//                     markerId: const MarkerId('start'),
//                     position: LatLng(
//                         _locations.first.latitude, _locations.first.longitude),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueGreen),
//                   ),
//                 if (_locations.isNotEmpty)
//                   Marker(
//                     markerId: const MarkerId('end'),
//                     position: LatLng(
//                         _locations.last.latitude, _locations.last.longitude),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueRed),
//                   ),
//               },
//               onMapCreated: (controller) =>
//                   setState(() => _mapController = controller),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Total Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km',
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Duration: ${_totalDuration.inHours}h ${_totalDuration.inMinutes.remainder(60)}m',
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _endShift,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32, vertical: 16),
//                   ),
//                   child: const Text('End Shift'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
