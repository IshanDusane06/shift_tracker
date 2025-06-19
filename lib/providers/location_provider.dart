import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../models/location_point.dart';
import 'dart:math';

class LocationState {
  final bool isTracking;
  final List<LocationPoint> locations;
  final double totalDistance;
  final Duration totalDuration;
  final bool isLoading;

  LocationState({
    required this.isTracking,
    required this.locations,
    required this.totalDistance,
    required this.totalDuration,
    this.isLoading = false,
  });

  LocationState copyWith({
    bool? isTracking,
    List<LocationPoint>? locations,
    double? totalDistance,
    Duration? totalDuration,
    bool? isLoading,
  }) {
    return LocationState(
      isTracking: isTracking ?? this.isTracking,
      locations: locations ?? this.locations,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationProvider extends StateNotifier<LocationState> {
  final LocationService _locationService;
  LocationProvider(this._locationService)
      : super(LocationState(
          isTracking: false,
          locations: [],
          totalDistance: 0,
          totalDuration: Duration.zero,
        ));

  Future<void> startTracking() async {
    await _locationService.startBackgroundTracking();
    await _locationService.startTracking();
    await _locationService.startNewShift();
    state = state.copyWith(isTracking: true);
  }

  Future<void> stopTracking() async {
    await _locationService.stopTracking();
    await _locationService.stopBackgroundTracking();
    await _loadLocations();
    await _locationService.endShift();
    state = state.copyWith(isTracking: false);
  }

  Future<void> _loadLocations() async {
    // final locations = await _locationService.getLocations();
    final locations = await _locationService
        .getLocationsForShift(await LocationService().getShiftId() ?? 1);
    final newState = calculateDistanceAndDuration(locations);
    state = state.copyWith(
      locations: locations,
      totalDistance: newState.totalDistance,
      totalDuration: newState.totalDuration,
    );
  }

  Future<void> loadLocationFromShift(int shiftId) async {
    List<LocationPoint> locations =
        await _locationService.getLocationsForShift(shiftId);
    final newState = calculateDistanceAndDuration(locations);
    state = state.copyWith(
      locations: locations,
      totalDistance: newState.totalDistance,
      totalDuration: newState.totalDuration,
    );
  }

  Future<void> syncLocation({bool stopTrackingManually = true}) async {
    // await clearAllLocation();
    List<LocationPoint> list = await _locationService.syncLocation();
    list.forEach((element) async {
      await _locationService.saveLocation(element);
    });
    if (stopTrackingManually) {
      await stopTracking();
    }
  }

  Future<void> clearAllLocation() async {
    await _locationService.clearLocations();
    state = state.copyWith(
      totalDistance: 0,
      totalDuration: Duration.zero,
    );
  }

  Future<void> clearNativeStoredLocation() async {
    await _locationService.clearNativeStoredLocationList();
  }

  LocationState calculateDistanceAndDuration(List<LocationPoint> locations) {
    if (locations.length < 2) {
      return LocationState(
        isTracking: state.isTracking,
        locations: locations,
        totalDistance: 0,
        totalDuration: Duration.zero,
      );
    }

    double totalDistance = 0;
    DateTime startTime = locations.first.timestamp;
    DateTime endTime = locations.last.timestamp;

    for (int i = 0; i < locations.length - 1; i++) {
      final start = locations[i];
      final end = locations[i + 1];
      totalDistance += _calculateDistance(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }

    return LocationState(
      isTracking: state.isTracking,
      locations: locations,
      totalDistance: totalDistance,
      totalDuration: endTime.difference(startTime),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters

    double dLat = (lat2 - lat1) * (3.141592653589793 / 180);
    double dLon = (lon2 - lon1) * (3.141592653589793 / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (3.141592653589793 / 180)) *
            cos(lat2 * (3.141592653589793 / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  void updateIsTracking(bool value) {
    state = state.copyWith(isTracking: value);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}

final locationProvider = StateNotifierProvider<LocationProvider, LocationState>(
  (ref) => LocationProvider(LocationService()),
);
