// shift_history_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location_tracker/models/shifts.dart';
import 'package:location_tracker/views/shift_end_view.dart';
import '../services/location_service.dart';

class ShiftHistoryView extends StatefulWidget {
  const ShiftHistoryView({super.key});

  @override
  State<ShiftHistoryView> createState() => _ShiftHistoryViewState();
}

class _ShiftHistoryViewState extends State<ShiftHistoryView> {
  List<Shift> _shifts = [];
  DateTime? _selectedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    final allShifts = await LocationService().getAllShifts();
    setState(() {
      _shifts = allShifts;
      _isLoading = false;
    });
  }

  void _filterShiftsByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<Shift> get _filteredShifts {
    if (_selectedDate == null) return _shifts;
    return _shifts.where((shift) {
      return shift.startTime.year == _selectedDate!.year &&
          shift.startTime.month == _selectedDate!.month &&
          shift.startTime.day == _selectedDate!.day;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      _filterShiftsByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Shift History',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: () => _selectDate(context),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredShifts.isEmpty
              ? const Center(
                  child: Text('No shifts found.',
                      style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: _filteredShifts.length,
                  itemBuilder: (context, index) {
                    final shift = _filteredShifts[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Shift #${shift.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Start: ${DateFormat.yMd().add_jm().format(shift.startTime)}\n'
                          'End: ${shift.endTime != null ? DateFormat.yMd().add_jm().format(shift.endTime!) : 'In Progress'}',
                        ),
                        trailing: const Icon(Icons.map),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShiftEndView(shiftId: shift.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
