import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/themes/color_palette.dart';
import '../../data/datasources/face_detection_ds.dart';
import '../../domain/entities/face_validation_result.dart';
import '../../domain/entities/gps_validation_result.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_controller.dart';
import '../widgets/face_overlay_widget.dart';
import '../widgets/lighting_indicator_widget.dart';

class FaceCaptureScreen extends StatefulWidget {
  final GPSValidationResult gpsResult;
  final bool isClockIn;

  const FaceCaptureScreen({
    super.key,
    required this.gpsResult,
    required this.isClockIn,
  });

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  final FaceDetectionDataSource _dataSource = FaceDetectionDataSource();
  bool _isInitializing = true;
  bool _isProcessing = false;
  FaceValidationResult? _lastValidationResult;

  // Real-time lighting tracking variables could be added here
  bool _isLightingGood = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _dataSource.initialize();
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal inisialisasi kamera: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndValidate() async {
    if (_dataSource.cameraController == null || !_dataSource.cameraController!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _lastValidationResult = null;
    });

    try {
      final imageFile = await _dataSource.cameraController!.takePicture();
      final result = await _dataSource.validateFace(imageFile);

      if (mounted) {
        setState(() {
          _lastValidationResult = result;
          _isLightingGood = result.hasGoodLighting;
        });

        if (result.isValid && result.capturedImage != null) {
          _processAttendance(result);
        } else {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Validasi gagal'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _processAttendance(FaceValidationResult faceResult) async {
    final att = context.read<AttendanceProvider>();
    final auth = context.read<AuthController>();
    final user = auth.user;

    if (user == null) {
      Navigator.pop(context);
      return;
    }

    bool success;
    if (widget.isClockIn) {
      success = await att.clockIn(
        employeeId: user.userId,
        employeeName: user.name,
        gpsResult: widget.gpsResult,
        imageBytes: faceResult.capturedImage!,
      );
    } else {
      success = await att.clockOut(
        gpsResult: widget.gpsResult,
        imageBytes: faceResult.capturedImage!,
      );
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      // Pop until dashboard
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
      att.refreshWeeklyStats(user.userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(att.successMessage ?? 'Berhasil!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(att.errorMessage ?? 'Gagal menyimpan absensi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.safetyOrange),
        ),
      );
    }

    final att = context.watch<AttendanceProvider>();
    final isActuallyProcessing = _isProcessing || att.actionState == AttendanceActionState.loading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Validasi Wajah', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_dataSource.cameraController != null)
            CameraPreview(_dataSource.cameraController!),

          // Overlay (Alignment guide)
          FaceOverlayWidget(
            isValid: _lastValidationResult?.isValid ?? false,
          ),

          // Lighting Indicator
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: LightingIndicatorWidget(isGood: _isLightingGood),
            ),
          ),

          // Validation hints
          if (_lastValidationResult != null && !_lastValidationResult!.isValid)
            Positioned(
              bottom: 140,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _lastValidationResult!.errorMessage ?? 'Gagal',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: isActuallyProcessing
                  ? const CircularProgressIndicator(color: AppColors.safetyOrange)
                  : GestureDetector(
                      onTap: _takePictureAndValidate,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: AppColors.safetyOrange.withOpacity(0.8),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
