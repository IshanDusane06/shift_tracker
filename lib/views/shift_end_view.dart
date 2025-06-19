import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/providers/location_provider.dart';

class ShiftEndView extends ConsumerStatefulWidget {
  final int? shiftId;
  const ShiftEndView({
    this.shiftId,
    super.key,
  });

  @override
  ConsumerState<ShiftEndView> createState() => _ShiftEndViewState();
}

class _ShiftEndViewState extends ConsumerState<ShiftEndView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (widget.shiftId != null) {
        await ref
            .read(locationProvider.notifier)
            .loadLocationFromShift(widget.shiftId!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final isTracking = locationState.isTracking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(locationProvider.notifier).state =
                  locationState.copyWith();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: locationState.locations.isNotEmpty
                    ? LatLng(
                        locationState.locations.first.latitude,
                        locationState.locations.first.longitude,
                      )
                    : const LatLng(28.6139, 77.2090),
                zoom: 15,
              ),
              polylines: {
                if (locationState.locations.length >= 2)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: locationState.locations
                        .map((point) => LatLng(point.latitude, point.longitude))
                        .toList(),
                    color: Colors.blue,
                    width: 5,
                  ),
              },
              markers: {
                if (locationState.locations.isNotEmpty)
                  Marker(
                    markerId: const MarkerId('start'),
                    position: LatLng(
                      locationState.locations.first.latitude,
                      locationState.locations.first.longitude,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                if (locationState.locations.isNotEmpty)
                  Marker(
                    markerId: const MarkerId('end'),
                    position: LatLng(
                      locationState.locations.last.latitude,
                      locationState.locations.last.longitude,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              onMapCreated: (controller) {
                print("Map initialized!");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Distance: ${(locationState.totalDistance / 1000).toStringAsFixed(2)} km',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: ${locationState.totalDuration.inHours}h ${locationState.totalDuration.inMinutes.remainder(60)}m ${locationState.totalDuration.inSeconds}s',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isTracking
                      ? null
                      : () async {
                          // ref.read(locationProvider.notifier).stopTracking();
                          // await ref
                          //     .read(locationProvider.notifier)
                          //     .clearAllLocation();
                          context.go('/');
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Home Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
