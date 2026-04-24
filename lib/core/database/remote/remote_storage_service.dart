import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RemoteStorageService {
  String getUrlFrom({required String path, required String storageBucket});

/// fileName with extension [filename.txt]
  Future<String> uploadFile({
    required String fileName,
    required String filePath,
    required String storageBucket,
    required String userPhone,
  });

  Future<void> deleteAllFilesInFolder({
    required String folderPath,
    required String storageBucket,
  });
}

class RemoteStorageServiceImpl implements RemoteStorageService {
  RemoteStorageServiceImpl(this._storage);
  final SupabaseStorageClient _storage;

  @override
  String getUrlFrom({required String path, required String storageBucket}) {
    
    return _storage.from(storageBucket).getPublicUrl(path);
  }

  @override
  Future<String> uploadFile({
    required String fileName,
    required String filePath,
    required String storageBucket,
    required String userPhone,
  }) async {
    final file = File(filePath);
    final folderName = userPhone;
    final resultPath = 'public/$folderName/$fileName';

    await _storage
        .from(storageBucket)
        .upload(resultPath, file, fileOptions: const FileOptions(upsert: true));

    return resultPath;
  }

  @override
  Future<void> deleteAllFilesInFolder({
    required String folderPath,
    required String storageBucket,
  }) async {
    final files = await _storage.from(storageBucket).list(path: folderPath);
    if (files.isEmpty) return;

   final paths = files.map((f) => '$folderPath/${f.name}').toList();
    await _storage.from(storageBucket).remove(paths);
  }
}
