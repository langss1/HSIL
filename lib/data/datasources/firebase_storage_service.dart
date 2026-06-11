import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/utils/app_result.dart';
import '../../core/errors/failures.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService(this._storage);

  Future<AppResult<String>> uploadEvidence(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '${timestamp}_evidence.$extension';
      
      final ref = _storage.ref().child('izin/$userId/$fileName');
      
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return AppSuccess(downloadUrl);
    } catch (e) {
      return AppFailure(DataFailure('Gagal mengunggah bukti: ${e.toString()}'));
    }
  }
}
