import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/face_validation_result.dart';

class FaceDetectionDataSource {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  CameraController? get cameraController => _cameraController;

  Future<void> initialize() async {
    // Get front camera
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, // For ML Kit processing
    );

    await _cameraController!.initialize();

    // Setup ML Kit Face Detector
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: true, // Untuk deteksi mata terbuka jika diperlukan
        enableTracking: false,
        minFaceSize: 0.15, // minimal 15% dari frame
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<FaceValidationResult> validateFace(XFile imageFile) async {
    if (_faceDetector == null) {
      return const FaceValidationResult(
        isValid: false,
        errorMessage: 'Face detector tidak diinisialisasi',
      );
    }

    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _faceDetector!.processImage(inputImage);

    // 1. Cek jumlah wajah
    if (faces.isEmpty) {
      return const FaceValidationResult(
        isValid: false,
        faceDetected: false,
        errorMessage: 'Tidak ada wajah terdeteksi. Pastikan wajah terlihat jelas.',
      );
    }

    if (faces.length > 1) {
      return const FaceValidationResult(
        isValid: false,
        faceDetected: true,
        isSingleFace: false,
        errorMessage: 'Terdeteksi lebih dari 1 wajah. Pastikan hanya ada 1 wajah.',
      );
    }

    // 2. Blur detection
    final imageBytes = await imageFile.readAsBytes();
    final isNotBlurry = await _checkSharpness(imageBytes);
    if (!isNotBlurry) {
      return const FaceValidationResult(
        isValid: false,
        faceDetected: true,
        isSingleFace: true,
        isNotBlurry: false,
        errorMessage: 'Foto terlalu blur. Pegang kamera dengan lebih stabil.',
      );
    }

    // 3. Lighting check (menggunakan brightness rata-rata)
    final hasGoodLighting = await _checkLighting(imageBytes);
    if (!hasGoodLighting) {
      return const FaceValidationResult(
        isValid: false,
        faceDetected: true,
        isSingleFace: true,
        isNotBlurry: true,
        hasGoodLighting: false,
        errorMessage: 'Pencahayaan terlalu gelap. Cari tempat yang lebih terang.',
      );
    }

    return FaceValidationResult(
      isValid: true,
      faceDetected: true,
      isSingleFace: true,
      isNotBlurry: true,
      hasGoodLighting: true,
      capturedImage: imageBytes,
    );
  }

  /// Blur detection: Hitung variance dari grayscale pixels
  Future<bool> _checkSharpness(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return false;

    // Resize untuk performa
    final resized = img.copyResize(image, width: 100);

    double variance = 0;
    double mean = 0;
    int count = resized.width * resized.height;

    // Hitung rata-rata luminance
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        mean += (pixel.r + pixel.g + pixel.b) / 3;
      }
    }
    mean /= count;

    // Hitung variance
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final lum = (pixel.r + pixel.g + pixel.b) / 3;
        variance += (lum - mean) * (lum - mean);
      }
    }
    variance /= count;

    const sharpnessThreshold = 100.0;
    return variance >= sharpnessThreshold;
  }

  /// Lighting check: Hitung rata-rata brightness
  Future<bool> _checkLighting(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return false;

    final resized = img.copyResize(image, width: 100);
    double totalBrightness = 0;
    int count = resized.width * resized.height;

    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        totalBrightness += (pixel.r + pixel.g + pixel.b) / 3;
      }
    }

    final avgBrightness = totalBrightness / count;
    return avgBrightness >= 60; // 0-255 scale
  }

  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
  }
}
