import 'dart:async';
import 'dart:convert';

import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

import '../../core/utils/app_result.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/gps_validation_result.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';
import '../../core/services/local_notification_service.dart';

/// State for clock-in/out operations.
enum AttendanceActionState {
  /// No operation in progress.
  idle,

  /// Clock-in or clock-out is being processed.
  loading,

  /// Operation completed successfully.
  success,

  /// Operation failed.
  error,
}

/// Manages attendance state: today's record, clock-in/out, weekly stats.
String? _compressImageToBase64(Uint8List imageBytes) {
  try {
    // LANGSUNG encode ke base64 tanpa proses decode/resize menggunakan package 'image'
    // Proses 'image' package sangat berat dan menyebabkan aplikasi nge-hang di debug mode.
    // Karena resolusi kamera sudah diset ke ResolutionPreset.low, ukurannya sudah cukup kecil.
    final base64String = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64String';
  } catch (e) {
    return null;
  }
}

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider({
    required ClockInUseCase clockInUseCase,
    required ClockOutUseCase clockOutUseCase,
    required GetWeeklyStatsUseCase getWeeklyStatsUseCase,
    required AttendanceRepository attendanceRepository,
  })  : _clockInUseCase = clockInUseCase,
        _clockOutUseCase = clockOutUseCase,
        _getWeeklyStatsUseCase = getWeeklyStatsUseCase,
        _attendanceRepository = attendanceRepository;

  final ClockInUseCase _clockInUseCase;
  final ClockOutUseCase _clockOutUseCase;
  final GetWeeklyStatsUseCase _getWeeklyStatsUseCase;
  final AttendanceRepository _attendanceRepository;

  // ── State ──────────────────────────────────────────────────────────────────

  AttendanceActionState _actionState = AttendanceActionState.idle;
  AttendanceActionState get actionState => _actionState;

  AttendanceRecord? _todayRecord;
  AttendanceRecord? get todayRecord => _todayRecord;

  Map<String, int> _weeklyStats = {
    'hadir': 0,
    'telat': 0,
    'izin': 0,
    'alpha': 0,
  };
  Map<String, int> get weeklyStats => _weeklyStats;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  StreamSubscription<AttendanceRecord?>? _todaySubscription;

  // ── Computed ───────────────────────────────────────────────────────────────

  /// Whether the employee can clock in (no record yet today).
  bool get canClockIn => _todayRecord == null || !_todayRecord!.hasClockedIn;

  /// Whether the employee can clock out (clocked in but not out).
  bool get canClockOut =>
      _todayRecord != null &&
      _todayRecord!.hasClockedIn &&
      !_todayRecord!.hasClockedOut;

  /// Whether today's cycle is complete.
  bool get isComplete => _todayRecord?.isComplete ?? false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Initializes the provider: loads today's record and weekly stats.
  Future<void> initialize(String employeeId) async {
    // Start watching today's record in real-time
    _todaySubscription?.cancel();
    _todaySubscription = _attendanceRepository
        .watchTodayAttendance(employeeId)
        .listen((record) {
      _todayRecord = record;
      
      // Schedule reminder based on current clock-in status
      LocalNotificationService.scheduleDailyReminder(
        hasClockedInToday: record?.hasClockedIn ?? false,
      );
      
      notifyListeners();
    });

    // Load weekly stats
    await refreshWeeklyStats(employeeId);
  }

  /// Performs a clock-in with GPS validation.
  Future<bool> clockIn({
    required String employeeId,
    required String employeeName,
    required GPSValidationResult gpsResult,
    required Uint8List imageBytes,
  }) async {
    _actionState = AttendanceActionState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final imageUrl = await uploadSelfie(
        userId: employeeId,
        imageBytes: imageBytes,
        date: dateStr,
        type: 'clock_in',
      );

      final result = await _clockInUseCase.call(
        employeeId: employeeId,
        employeeName: employeeName,
        gpsResult: gpsResult,
        imageUrl: imageUrl,
      );

      return result.when(
      success: (record) {
        _todayRecord = record;
        _actionState = AttendanceActionState.success;
        _successMessage = 'Clock-in berhasil! Status: ${record.status}';
        
        // Smart cancellation: reschedule reminder to skip today
        LocalNotificationService.scheduleDailyReminder(hasClockedInToday: true);

        LocalNotificationService.showNotification(
          id: 1,
          title: 'Clock-in Berhasil',
          body: 'Absensi Anda untuk hari ini telah tercatat (${record.status}).',
          userId: record.employeeId,
          type: 'success',
        );
        notifyListeners();
        return true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _actionState = AttendanceActionState.error;
        LocalNotificationService.showNotification(
          id: 2,
          title: 'Clock-in Gagal',
          body: failure.message,
          userId: _todayRecord?.employeeId,
          type: 'failure',
        );
        notifyListeners();
        return false;
      },
    );
    } catch (e) {
      _errorMessage = 'Gagal mengupload foto: $e';
      _actionState = AttendanceActionState.error;
      notifyListeners();
      return false;
    }
  }

  /// Performs a clock-out with GPS validation.
  Future<bool> clockOut({
    required GPSValidationResult gpsResult,
    required Uint8List imageBytes,
  }) async {
    if (_todayRecord == null) {
      _errorMessage = 'Belum ada record clock-in hari ini.';
      _actionState = AttendanceActionState.error;
      notifyListeners();
      return false;
    }

    _actionState = AttendanceActionState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final imageUrl = await uploadSelfie(
        userId: _todayRecord!.employeeId,
        imageBytes: imageBytes,
        date: dateStr,
        type: 'clock_out',
      );

      final result = await _clockOutUseCase.call(
        attendanceId: _todayRecord!.id,
        gpsResult: gpsResult,
        imageUrl: imageUrl,
      );

      return result.when(
      success: (record) {
        _todayRecord = record;
        _actionState = AttendanceActionState.success;
        _successMessage = 'Clock-out berhasil!';
        LocalNotificationService.showNotification(
          id: 3,
          title: 'Clock-out Berhasil',
          body: 'Terima kasih atas kerja keras Anda hari ini.',
          userId: record.employeeId,
          type: 'success',
        );
        notifyListeners();
        return true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _actionState = AttendanceActionState.error;
        LocalNotificationService.showNotification(
          id: 4,
          title: 'Clock-out Gagal',
          body: failure.message,
          userId: _todayRecord?.employeeId,
          type: 'failure',
        );
        notifyListeners();
        return false;
      },
    );
    } catch (e) {
      _errorMessage = 'Gagal mengupload foto: $e';
      _actionState = AttendanceActionState.error;
      notifyListeners();
      return false;
    }
  }

  Future<String> uploadSelfie({
    required String userId,
    required Uint8List imageBytes,
    required String date,
    required String type,
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('Ukuran foto 0 bytes. Kamera gagal menangkap gambar.');
    }

    try {
      // Menjalankan proses kompresi gambar yang berat di thread terpisah (Isolate)
      // agar tidak membekukan UI (Layar Hitam)
      final base64Result = await compute(_compressImageToBase64, imageBytes);
      
      if (base64Result == null) {
        return 'https://via.placeholder.com/400x400.png?text=Compression+Failed';
      }
      
      return base64Result;
    } catch (e) {
      debugPrint('Base64 Encoding Error: $e');
      return 'https://via.placeholder.com/400x400.png?text=Face+Capture+Fallback';
    }
  }

  /// Refreshes weekly stats from the repository.
  Future<void> refreshWeeklyStats(String employeeId) async {
    final result = await _getWeeklyStatsUseCase.call(employeeId);
    result.when(
      success: (stats) {
        _weeklyStats = stats;
        notifyListeners();
      },
      failure: (_) {
        // Silently fail — keep previous stats
      },
    );
  }

  /// Clears action state messages.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _actionState = AttendanceActionState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _todaySubscription?.cancel();
    super.dispose();
  }
}
