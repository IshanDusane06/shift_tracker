import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';

class ShiftStartViewModel {
  final WidgetRef ref;

  ShiftStartViewModel(this.ref);

  bool get isTracking => ref.watch(locationProvider).isTracking;

  Future<void> startShift() async {
    await ref.read(locationProvider.notifier).startTracking();
  }

  Future<void> endShift() async {
    await ref.read(locationProvider.notifier).stopTracking();
  }

  Future<void> syncLocationList({bool stopTrackingManually = true}) async {
    await ref
        .read(locationProvider.notifier)
        .syncLocation(stopTrackingManually: stopTrackingManually);
  }

  Future<void> clearNativeLocationList() async {
    await ref.read(locationProvider.notifier).clearNativeStoredLocation();
  }
}
