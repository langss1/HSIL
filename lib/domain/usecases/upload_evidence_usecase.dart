import 'dart:io';
import '../../core/utils/app_result.dart';
import '../../data/datasources/firebase_storage_service.dart';

class UploadEvidenceUseCase {
  final FirebaseStorageService _storageService;

  UploadEvidenceUseCase(this._storageService);

  Future<AppResult<String>> call(File file, String userId) async {
    return _storageService.uploadEvidence(file, userId);
  }
}
