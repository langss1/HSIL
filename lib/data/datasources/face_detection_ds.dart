import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/face_validation_result.dart';

import 'dart:io';

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
      ResolutionPreset.low, // LOWEST resolution for best performance on slow devices
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888, 
    );

    await _cameraController!.initialize();

    // Setup ML Kit Face Detector
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: true, // Untuk deteksi mata terbuka jika diperlukan
        enableTracking: false,
        minFaceSize: 0.35, // Ditingkatkan agar wajah harus memenuhi frame (35%)
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  bool _isProcessingFrame = false;
  Function(FaceValidationResult)? _onFrameAnalyzed;

  Future<void> startLiveValidation(Function(FaceValidationResult) onResult) async {
    _onFrameAnalyzed = onResult;
    if (_cameraController != null && !_cameraController!.value.isStreamingImages) {
      await _cameraController!.startImageStream(_processCameraFrame);
    }
  }

  Future<void> stopLiveValidation() async {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _faceDetector == null) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      // Check face count
      final faceDetected = faces.isNotEmpty;
      final isSingleFace = faces.length == 1;

      // Check Lighting & Sharpness (optimized for low-end devices, stride=8)
      final isNotBlurry = _checkSharpnessYUV(image);
      final hasGoodLighting = _checkLightingYUV(image);

      final isValid = faceDetected && isSingleFace && isNotBlurry && hasGoodLighting;

      String? errorMsg;
      if (!faceDetected) errorMsg = 'Arahkan wajah ke kamera';
      else if (!isSingleFace) errorMsg = 'Hanya boleh 1 wajah';
      else if (!hasGoodLighting) errorMsg = 'Cari tempat lebih terang';
      else if (!isNotBlurry) errorMsg = 'Jangan goyang (Blur)';

      _onFrameAnalyzed?.call(FaceValidationResult(
        isValid: isValid,
        faceDetected: faceDetected,
        isSingleFace: isSingleFace,
        isNotBlurry: isNotBlurry,
        hasGoodLighting: hasGoodLighting,
        errorMessage: errorMsg,
      ));

    } catch (e, stack) {
      print('ML_KIT_ERROR: $e\n$stack');
    }

    // Throttle 500ms for low-end devices
    await Future.delayed(const Duration(milliseconds: 500));
    _isProcessingFrame = false;
  }

  InputImage? _buildInputImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = _cameraController!.description;
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      
      final inputImageFormat = Platform.isAndroid 
          ? InputImageFormat.nv21 
          : InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.bgra8888;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      return null;
    }
  }

  bool _checkSharpnessYUV(CameraImage image) {
    if (image.planes.isEmpty) return false;
    final bytes = image.planes[0].bytes;
    final width = image.planes[0].bytesPerRow;
    final height = bytes.length ~/ width;

    int diffSum = 0;
    int count = 0;
    // Sample a grid for speed (stride=8 for low end devices)
    for (int y = 0; y < height - 1; y += 8) {
      for (int x = 0; x < width - 1; x += 8) {
        final idx = y * width + x;
        final curr = bytes[idx];
        final right = bytes[idx + 1];
        diffSum += (curr - right).abs();
        count++;
      }
    }
    
    if (count == 0) return false;
    final avgDiff = diffSum / count;
    // Ditingkatkan dari 1.2 ke 3.5 agar sensor lebih ketat menolak foto blur
    return avgDiff >= 3.5;
  }

  bool _checkLightingYUV(CameraImage image) {
    if (image.planes.isEmpty) return false;
    final bytes = image.planes[0].bytes;
    int sum = 0;
    int count = 0;
    // Sample every 8th pixel for speed
    for (int i = 0; i < bytes.length; i += 8) {
      sum += bytes[i];
      count++;
    }
    if (count == 0) return false;
    final avg = sum / count;
    return avg >= 50; 
  }

  Future<XFile?> takeFinalPicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return null;
    try {
      // Don't stop before takePicture!
      final imageFile = await _cameraController!.takePicture();
      await stopLiveValidation(); 
      return imageFile;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    stopLiveValidation();
    _cameraController?.dispose();
    _faceDetector?.close();
  }
}
