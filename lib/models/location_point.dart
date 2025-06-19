// class LocationPoint {
//   final double latitude;
//   final double longitude;
//   final DateTime timestamp;

//   LocationPoint({
//     required this.latitude,
//     required this.longitude,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'latitude': latitude,
//       'longitude': longitude,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }

//   factory LocationPoint.fromMap(Map<String, dynamic> map) {
//     return LocationPoint(
//       latitude: map['latitude'] as double,
//       longitude: map['longitude'] as double,
//       timestamp: DateTime.parse(map['timestamp'] as String),
//     );
//   }
// }

class LocationPoint {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int shiftId;

  LocationPoint({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.shiftId,
  });

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'shift_id': shiftId,
      };

  factory LocationPoint.fromMap(Map<String, dynamic> map) => LocationPoint(
        id: map['id'],
        latitude: map['latitude'],
        longitude: map['longitude'],
        timestamp: DateTime.parse(map['timestamp']),
        shiftId: map['shift_id'],
      );
}
