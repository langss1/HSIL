import 'dart:typed_data';

/// Represents the result of a face detection & validation process.
class FaceValidationResult {
  const FaceValidationResult({
    required this.isValid,
    this.faceDetected = false,
    this.isSingleFace = false,
    this.isNotBlurry = false,
    this.hasGoodLighting = false,
    this.errorMessage,
    this.capturedImage,
  });

  /// True if all validations passed.
  final bool isValid;

  /// True if at least one face was detected.
  final bool faceDetected;

  /// True if exactly one face was detected.
  final bool isSingleFace;

  /// True if the image is sharp enough.
  final bool isNotBlurry;

  /// True if the image lighting is adequate.
  final bool hasGoodLighting;

  /// Error message explaining why validation failed (if applicable).
  final String? errorMessage;

  /// The raw image bytes of the captured selfie, present if isValid is true.
  final Uint8List? capturedImage;
}
