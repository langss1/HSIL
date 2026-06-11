import 'package:flutter/foundation.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/get_attendance_history_usecase.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({required GetAttendanceHistoryUseCase getHistory})
      : _getHistory = getHistory;

  final GetAttendanceHistoryUseCase _getHistory;

  List<AttendanceRecord> _records = [];
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String? _filterStatus; // null = semua
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceRecord> get records => _records;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  String? get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Filtered records based on selected status filter.
  List<AttendanceRecord> get filteredRecords {
    if (_filterStatus == null) return _records;
    if (_filterStatus!.toLowerCase() == 'izin') {
      return _records.where((r) => r.status.toLowerCase() == 'izin' || r.status.toLowerCase() == 'sakit').toList();
    }
    return _records.where((r) => r.status.toLowerCase() == _filterStatus!.toLowerCase()).toList();
  }

  /// Monthly summary stats.
  Map<String, int> get monthlyStats {
    final stats = {'hadir': 0, 'telat': 0, 'izin': 0, 'sakit': 0, 'alpha': 0};
    for (final record in _records) {
      final key = stats.containsKey(record.status.toLowerCase()) ? record.status.toLowerCase() : 'alpha';
      stats[key] = (stats[key] ?? 0) + 1;
    }
    return {
      'hadir': stats['hadir'] ?? 0,
      'telat': stats['telat'] ?? 0,
      'izin': (stats['izin'] ?? 0) + (stats['sakit'] ?? 0),
      'alpha': stats['alpha'] ?? 0,
    };
  }

  /// Load records for the selected month.
  Future<void> loadMonth({
    required String employeeId,
    int? year,
    int? month,
  }) async {
    if (year != null) _selectedYear = year;
    if (month != null) _selectedMonth = month;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getHistory(
      employeeId: employeeId,
      year: _selectedYear,
      month: _selectedMonth,
    );

    result.when(
      success: (records) {
        _records = records;
        // Sort descending by date
        _records.sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
      },
    );
    notifyListeners();
  }

  void setFilter(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilter() {
    _filterStatus = null;
    notifyListeners();
  }

  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    notifyListeners();
  }

  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    notifyListeners();
  }
}
