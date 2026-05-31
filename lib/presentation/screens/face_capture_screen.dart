import 'dart:async';
import 'dart:ui';

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
  bool _isLightingGood = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  String _getInstructionText() {
    if (_lastValidationResult == null) return "Posisikan wajah di dalam bingkai";
    if (!_lastValidationResult!.faceDetected || !_lastValidationResult!.isSingleFace) return "Posisikan wajah di dalam bingkai";
    if (!_lastValidationResult!.hasGoodLighting) return "Pencahayaan terlalu gelap";
    if (!_lastValidationResult!.isNotBlurry) return "Tahan posisi Anda (Kamera blur)";
    return "Sempurna! Silakan foto";
  }

  Color _getInstructionColor() {
    if (_lastValidationResult == null) return Colors.white;
    if (!_lastValidationResult!.faceDetected || !_lastValidationResult!.isSingleFace) return Colors.white;
    if (!_lastValidationResult!.hasGoodLighting || !_lastValidationResult!.isNotBlurry) return AppColors.safetyOrange;
    return AppColors.success;
  }

  Future<void> _initCamera() async {
    try {
      await _dataSource.initialize();
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
      });

      // Start live stream validation
      _dataSource.startLiveValidation((result) {
        if (mounted && !_isProcessing) {
          setState(() {
            _lastValidationResult = result;
            _isLightingGood = result.hasGoodLighting;
          });
        }
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

  Future<void> _captureAndSave() async {
    if (_isProcessing) return;
    final canCapture = _lastValidationResult?.isValid ?? false;
    if (!canCapture) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final imageFile = await _dataSource.takeFinalPicture();
      if (imageFile != null && mounted) {
        final bytes = await imageFile.readAsBytes();
        
        final finalResult = FaceValidationResult(
          isValid: true,
          faceDetected: true,
          isSingleFace: true,
          isNotBlurry: true,
          hasGoodLighting: true,
          capturedImage: bytes,
        );

        await _processAttendance(finalResult);
      } else {
        if (mounted) setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
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
      att.refreshWeeklyStats(user.userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(att.successMessage ?? 'Berhasil!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Kembali ke Dashboard dengan aman (mencegah black screen akibat double pop)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // Jika gagal, tampilkan dialog error alih-alih restart kamera (kamera sering blank setelah error)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.deepNavy,
          title: const Text('Absensi Gagal', style: TextStyle(color: Colors.white)),
          content: Text(
            att.errorMessage ?? 'Gagal menyimpan absensi',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke layar sebelumnya
              },
              child: const Text('Kembali', style: TextStyle(color: AppColors.safetyOrange)),
            ),
          ],
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
    final canCapture = _lastValidationResult?.isValid ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isProcessing ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Validasi Wajah', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.safetyOrange),
                  SizedBox(height: 24),
                  Text(
                    'Memproses Absensi...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_dataSource.cameraController != null)
            Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / _dataSource.cameraController!.value.aspectRatio,
                  child: CameraPreview(_dataSource.cameraController!),
                ),
              ),
            ),

          // Overlay (Alignment guide)
          FaceOverlayWidget(
            isValid: canCapture,
          ),

          // Main Instruction Text (Sleek Pill)
          if (_lastValidationResult != null)
            Positioned(
              bottom: 250,
              left: 20,
              right: 20,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: canCapture ? AppColors.safetyOrange : Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: canCapture ? AppColors.safetyOrange : Colors.white.withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                    boxShadow: canCapture ? [
                      BoxShadow(
                        color: AppColors.safetyOrange.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      )
                    ] : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        canCapture ? Icons.check_circle_rounded : Icons.face_retouching_natural_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        canCapture ? 'Wajah Sempurna! Tekan Tombol' : 'Posisikan Wajah ke Tengah',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Status Chips (Modern floating indicators)
          if (_lastValidationResult != null)
            Positioned(
              bottom: 165,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusChip(
                    icon: Icons.person_outline_rounded,
                    label: 'Wajah',
                    isValid: _lastValidationResult!.faceDetected && _lastValidationResult!.isSingleFace,
                  ),
                  const SizedBox(width: 12),
                  _StatusChip(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Cahaya',
                    isValid: _lastValidationResult!.hasGoodLighting,
                  ),
                  const SizedBox(width: 12),
                  _StatusChip(
                    icon: Icons.center_focus_strong_rounded,
                    label: 'Fokus',
                    isValid: _lastValidationResult!.isNotBlurry,
                  ),
                ],
              ),
            ),

          // Premium Minimalist Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: isActuallyProcessing
                  ? Container(
                      width: 86,
                      height: 86,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                        border: Border.all(color: AppColors.safetyOrange, width: 2),
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.safetyOrange,
                        strokeWidth: 3,
                      ),
                    )
                  : GestureDetector(
                      onTap: canCapture ? _captureAndSave : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        width: canCapture ? 92 : 82,
                        height: canCapture ? 92 : 82,
                        padding: EdgeInsets.all(canCapture ? 6 : 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: canCapture ? AppColors.safetyOrange : Colors.white.withValues(alpha: 0.4), 
                            width: canCapture ? 4 : 2,
                          ),
                          boxShadow: canCapture ? [
                            BoxShadow(
                              color: AppColors.safetyOrange.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            )
                          ] : [],
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: canCapture 
                                ? AppColors.safetyOrange 
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: Icon(
                              canCapture ? Icons.fingerprint_rounded : Icons.face_rounded, 
                              color: Colors.white, 
                              size: canCapture ? 42 : 36,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isValid;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isValid 
            ? AppColors.safetyOrange.withValues(alpha: 0.15) 
            : Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid 
              ? AppColors.safetyOrange.withValues(alpha: 0.5) 
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isValid ? AppColors.safetyOrange : Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isValid ? Colors.white : Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: isValid ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
