import 'package:location_tracker/models/shifts.dart';
import 'package:location_tracker/services/invoke_native_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/location_point.dart';

class LocationService {
  static const String _isTrackingKey = 'is_tracking';
  static const String _databaseName = 'location_tracker.db';
  static const String _locationsTable = 'locations';
  static const String _shiftId = 'shift_id';
  static Database? _database;
  int? _currentShiftId; // Keep track of active shift

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  // Future<Database> initDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   return await openDatabase(
  //     join(dbPath, _databaseName),
  //     version: 1,
  //     onCreate: (db, version) async {
  //       await db.execute('''
  //         CREATE TABLE $_locationsTable (
  //           id INTEGER PRIMARY KEY AUTOINCREMENT,
  //           latitude REAL NOT NULL,
  //           longitude REAL NOT NULL,
  //           timestamp TEXT NOT NULL
  //         )
  //       ''');
  //     },
  //   );
  // }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, _databaseName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_locationsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shift_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (shift_id) REFERENCES shifts(id)
          )
        ''');

        await db.execute('''
        CREATE TABLE shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          end_time TEXT
        )
      ''');
      },
    );
  }

  Future<bool> isTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isTrackingKey) ?? false;
  }

  Future<void> startTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isTrackingKey, true);
  }

  Future<void> stopTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isTrackingKey, false);
  }

  Future<void> storeShiftId(int shiftId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shiftId, shiftId);
  }

  Future<int?> getShiftId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.getInt(_shiftId);
  }

  Future<void> removeShiftId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shiftId);
  }

  Future<void> saveLocation(LocationPoint location) async {
    final db = await database;

    if (await getShiftId() == null) {
      // Optional: throw error or skip
      return;
    }

    await db.insert(
      _locationsTable,
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocationPoint>> getLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_locationsTable);
    return List.generate(maps.length, (i) => LocationPoint.fromMap(maps[i]));
  }

  Future<void> clearLocations() async {
    final db = await database;
    await db.delete(_locationsTable);
  }

  Future<void> startBackgroundTracking() async {
    await _trackLocation();
  }

  Future<void> _trackLocation() async {
    if (await isTracking()) {
      return;
    }

    try {
      // Start the native location service
      await startTracking();
      await NativeChannelService.startNativeLocationService();

      print('Native location service started');
    } catch (e) {
      print('Error tracking location: $e');
      // Don't stop tracking on error, just log it
      await stopTracking();
    }
  }

  Future<void> stopBackgroundTracking() async {
    await stopTracking();
    await NativeChannelService.stopNativeLocationService();
  }

  Future<List<LocationPoint>> syncLocation() async {
    return await NativeChannelService.getStoredLocations();
  }

  Future<void> clearNativeStoredLocationList() async {
    await NativeChannelService.clearNativeStroredLocationList();
  }

  //Shifts
  Future<int> startNewShift() async {
    final db = await database;
    final id = await db.insert('shifts', {
      'start_time': DateTime.now().toIso8601String(),
    });
    // _currentShiftId = id;
    storeShiftId(id);
    // await startTracking();
    return id;
  }

  Future<void> endShift() async {
    final db = await database;
    if (await getShiftId() != null) {
      await db.update(
        'shifts',
        {'end_time': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [await getShiftId()],
      );
      // _currentShiftId = null;
      await removeShiftId();
    }
    await stopTracking();
  }

  Future<List<Shift>> getAllShifts() async {
    final db = await database;
    final result = await db.query('shifts', orderBy: 'id DESC');
    return result.map((e) => Shift.fromMap(e)).toList();
  }

  Future<List<LocationPoint>> getLocationsForShift(int shiftId) async {
    print('Getting locations for shiftId = $shiftId');
    await debugPrintLocations();
    final db = await database;
    final result = await db.query(
      _locationsTable,
      where: 'shift_id = ?',
      whereArgs: [shiftId],
      orderBy: 'timestamp ASC',
    );

    print('Result: ${result.length} rows found');
    for (var row in result) {
      print(row);
    }

    return result.map((e) => LocationPoint.fromMap(e)).toList();
  }

  Future<void> debugPrintLocations() async {
    final db = await database;
    final result = await db.query(_locationsTable);
    for (var row in result) {
      print('Row: $row');
    }
  }
}
