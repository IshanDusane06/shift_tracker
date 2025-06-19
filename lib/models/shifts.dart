class Shift {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;

  Shift({
    required this.id,
    required this.startTime,
    this.endTime,
  });

  factory Shift.fromMap(Map<String, dynamic> map) => Shift(
        id: map['id'],
        startTime: DateTime.parse(map['start_time']),
        endTime:
            map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      );
}
