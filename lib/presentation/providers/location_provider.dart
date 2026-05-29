import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_result.dart';
import '../../domain/entities/gps_validation_result.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/validate_gps_usecase.dart';

/// State for the GPS location tracking feature.
enum LocationState {
  /// Initial state — location not yet requested.
  idle,

  /// Requesting permission or loading initial position.
  loading,

  /// Location successfully acquired and validated.
  ready,

  /// Error occurred (permission denied, GPS off, etc.)
  error,
}

/// Manages real-time GPS location, geofence validation, and enter/exit events.
class LocationProvider extends ChangeNotifier {
  LocationProvider({
    required LocationRepository locationRepository,
    required ValidateGPSUseCase validateGPSUseCase,
  })  : _locationRepository = locationRepository,
        _validateGPSUseCase = validateGPSUseCase;

  final LocationRepository _locationRepository;
  final ValidateGPSUseCase _validateGPSUseCase;

  // ── State ──────────────────────────────────────────────────────────────────

  LocationState _state = LocationState.idle;
  LocationState get state => _state;

  GPSValidationResult? _currentResult;
  GPSValidationResult? get currentResult => _currentResult;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isInArea = false;
  bool get isInArea => _isInArea;

  double _distanceMeters = 0;
  double get distanceMeters => _distanceMeters;

  double? _accuracy;
  double? get accuracy => _accuracy;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  // ── Geofencing ─────────────────────────────────────────────────────────────

  bool _previouslyInArea = false;
  StreamSubscription<GPSValidationResult>? _positionSubscription;

  /// Callback invoked when the user enters the geofence.
  VoidCallback? onEnterGeofence;

  /// Callback invoked when the user exits the geofence.
  VoidCallback? onExitGeofence;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Performs a one-shot GPS validation.
  Future<void> validateOnce() async {
    _state = LocationState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _validateGPSUseCase.call();
    result.when(
      success: (gpsResult) {
        _applyResult(gpsResult);
        _state = LocationState.ready;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _state = LocationState.error;
      },
    );
    notifyListeners();
  }

  /// Starts real-time location tracking with geofencing.
  Future<void> startTracking() async {
    // Validate once first to check permissions
    await validateOnce();
    if (_state == LocationState.error) return;

    // Start streaming
    _positionSubscription?.cancel();
    _positionSubscription = _locationRepository
        .watchLocationStream()
        .listen(
          _onPositionUpdate,
          onError: (Object error) {
            _errorMessage = error.toString();
            _state = LocationState.error;
            notifyListeners();
          },
        );
  }

  /// Stops real-time location tracking.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Retries validation after an error.
  Future<void> retry() async {
    await validateOnce();
    if (_state == LocationState.ready) {
      await startTracking();
    }
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _onPositionUpdate(GPSValidationResult result) {
    _applyResult(result);

    // Geofence enter/exit detection
    if (!_previouslyInArea && result.isInArea) {
      onEnterGeofence?.call();
    } else if (_previouslyInArea && !result.isInArea) {
      onExitGeofence?.call();
    }
    _previouslyInArea = result.isInArea;

    _state = LocationState.ready;
    notifyListeners();
  }

  void _applyResult(GPSValidationResult result) {
    _currentResult = result;
    _isInArea = result.isInArea;
    _distanceMeters = result.distanceMeters;
    _accuracy = result.accuracy;
    _lastUpdated = result.timestamp;
    _previouslyInArea = result.isInArea;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
