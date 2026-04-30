import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/log.dart';
import '../../../core/database/local/database_helper.dart';

typedef OnProgress = void Function(double value);

class BackupFileHelper {
  BackupFileHelper._();

  static const int _headerLength = 128;

  static Stream<List<int>> readDbStream(String dbFilePath) async* {
    RandomAccessFile? raf;
    try {
      final dbFile = File(dbFilePath);

      if (!await dbFile.exists()) return;

      raf = await dbFile.open();

      await raf.setPosition(_headerLength);
      final totalBytes = await dbFile.length();
      const chunkSize = 8 * 1024;

      while (await raf.position() < totalBytes) {
        final bytes = await raf.read(chunkSize);

        if (bytes.isEmpty) break;

        yield bytes;
      }
    } finally {
      await raf?.close();
    }
  }

  static Future<Uint8List?> readDbBytes({
    String? dbFilePath,
    required OnProgress onProgress,
  }) async {
    try {
      final dbPath =
          dbFilePath ?? await DatabaseHelper.instance.getDatabaseFilePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return null;

      final totalBytes = await dbFile.length();
      final allBytes = <int>[];
      int readBytes = 0;

      await for (final chunk in dbFile.openRead()) {
        allBytes.addAll(chunk);
        readBytes += chunk.length;

        final progress = readBytes / totalBytes;
        Logger.debugLog(message: chunk.length.toString());
        Logger.debugLog(message: progress.toString());
        onProgress(progress);
      }

      return Uint8List.fromList(allBytes);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }

  static Future<void> writeBytesToDb({
    required Uint8List bytes,
    required OnProgress onProgress,
  }) async {
    IOSink? sink;
    try {
      final totalBytes = bytes.lengthInBytes;
      int writtenBytes = 0;

      const chunkSize = 8 * 1024; // 8KB

      final dbFilePath = await DatabaseHelper.instance.getDatabaseFilePath();

      await DatabaseHelper.instance.close();

      final targetFile = File(dbFilePath);

      sink = targetFile.openWrite();

      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end =
            (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize;

        final chunk = bytes.sublist(i, end);

        sink.add(chunk);

        writtenBytes += chunk.length;
        final progress = writtenBytes / totalBytes;

        onProgress(progress);
      }
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      rethrow;
    } finally {
      await sink?.flush();
      await sink?.close();
    }
  }

  static Future<void> writeStreamToDb({
    required Stream<List<int>> dbStream,
    required OnProgress onProgress,
    required int totalBytes,
  }) async {
    IOSink? sink;
    try {
      final rightTotalBytes = totalBytes - _headerLength;
      int writtenBytes = 0;
      final dbFilePath = await DatabaseHelper.instance.getDatabaseFilePath();
      final targetFile = File(dbFilePath);

      await DatabaseHelper.instance.close();

      sink = targetFile.openWrite();

      await for (final chunk in dbStream) {
        sink.add(chunk);

        writtenBytes += chunk.length;
        final progress = writtenBytes / rightTotalBytes;

        onProgress(progress);
      }
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      rethrow;
    } finally {
      await sink?.flush();
      await sink?.close();
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
