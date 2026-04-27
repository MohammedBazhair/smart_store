import 'dart:io';
import 'dart:typed_data';

import '../../../core/constants/log.dart';
import '../../../core/database/local/database_helper.dart';

class BackupFileHelper {
  BackupFileHelper._();

  static const int _headerLength = 128;

 static Future<Uint8List?> readOriginalDbBytes() async {
    try {
      final dbPath = await DatabaseHelper.instance.getDatabaseFilePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return null;

      return await dbFile.readAsBytes();
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }


  static Uint8List addBackupHeader(Uint8List bytes) {
    final result = BytesBuilder();

    final secret = DateTime.now().microsecondsSinceEpoch;

    final headerData = ByteData(_headerLength)..setInt64(0, secret);

    result.add(headerData.buffer.asUint8List());
    result.add(bytes);

    return result.toBytes();
  }

  static Uint8List removeBackupHeader(Uint8List bytes) {
    if (bytes.lengthInBytes <= _headerLength) {
      throw const FormatException(
        'ملف النسخة الاحتياطية غير صالح أو تالف',
      );
    }

    return bytes.sublist(_headerLength);
  }

  
}
