import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// سرویس مدیریت آپلود/حذف فایل (تصاویر، صوت، رسید پرداخت) در Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadFile(File file, String folder) async {
    final fileName = '${_uuid.v4()}${_extension(file.path)}';
    final ref = _storage.ref().child('$folder/$fileName');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // فایل ممکن است از قبل حذف شده باشد
    }
  }

  String _extension(String path) {
    final idx = path.lastIndexOf('.');
    return idx == -1 ? '' : path.substring(idx);
  }
}
