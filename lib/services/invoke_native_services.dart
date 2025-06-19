import 'dart:convert';

import 'package:flutter/services.dart';
import '../models/location_point.dart';
import 'location_service.dart';

class NativeChannelService {
  static const MethodChannel _channel =
      MethodChannel('background_location_channel');

  static void initialize() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'sendLocation') {
        final shiftId = await LocationService().getShiftId() ?? 0;
        final double latitude = call.arguments['latitude'];
        final double longitude = call.arguments['longitude'];
        final DateTime timestamp =
            DateTime.fromMillisecondsSinceEpoch(call.arguments['timestamp']);

        final point = LocationPoint(
          latitude: latitude,
          longitude: longitude,
          timestamp: timestamp,
          shiftId: shiftId,
        );

        await LocationService().saveLocation(point);
      }
    });
  }

  // static Future<void> _handleNativeCall(MethodCall call) async {
  //   if (call.method == 'sendLocation') {
  //     final double latitude = call.arguments['latitude'];
  //     final double longitude = call.arguments['longitude'];
  //     final DateTime timestamp =
  //         DateTime.fromMillisecondsSinceEpoch(call.arguments['timestamp']);

  //     final point = LocationPoint(
  //       latitude: latitude,
  //       longitude: longitude,
  //       timestamp: timestamp,
  //     );

  //     await LocationService().saveLocation(point);
  //   }
  // }

  static Future<void> startNativeLocationService() async {
    await _channel.invokeMethod('startService');
  }

  static Future<void> stopNativeLocationService() async {
    await _channel.invokeMethod('stopService');
  }

  static Future<List<LocationPoint>> getStoredLocations() async {
    try {
      final jsonList = await _channel.invokeMethod('getStoredLocations');
      final parsed = jsonDecode(jsonList) as List;
      final shiftId = await LocationService().getShiftId() ?? 0;
      return parsed
          .map(
            (e) => LocationPoint(
              latitude: e['latitude'] as double,
              longitude: e['longitude'] as double,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                int.parse(e['timestamp'].toString()),
              ),
              shiftId: shiftId,
            ),
          )
          .toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> clearNativeStroredLocationList() async {
    await _channel.invokeMethod('clearStoredLocations');
  }
}
