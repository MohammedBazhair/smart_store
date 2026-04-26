import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/extensions/extensions.dart';
import 'backup_type.dart';

class BackupState {
  BackupState({
    required this.type,
    required this.updatedAt,
    required this.sizeInMega,
  });

  factory BackupState.fromMap(Map<String, dynamic> map) {
    return BackupState(
      type: BackupType.values.byName(map['type']),
      updatedAt: DateTime.parse(map['updatedAt']),
      sizeInMega: (map['size'] as num).toDouble(),
    );
  }

  factory BackupState.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return BackupState.fromMap(map);
  }

  factory BackupState.fromFile({
    required File file,
    required BackupType type,
  }) {
    final sizeInBytes = file.lengthSync();
    final updatedAt = DateTime.now();

    return BackupState(
      sizeInMega: sizeInBytes.bytesToMb,
      updatedAt: updatedAt,
      type: type,
    );
  }

  factory BackupState.fromBytes({
    required Uint8List bytes,
    required BackupType type,
  }) {
    final sizeInBytes = bytes.lengthInBytes;
    final updatedAt = DateTime.now();

    return BackupState(
      sizeInMega: sizeInBytes.bytesToMb,
      updatedAt: updatedAt,
      type: type,
    );
  }

  final BackupType type;
  final DateTime updatedAt;
  final double sizeInMega;

  String get sizeText => '${sizeInMega.formatDouble} MB';

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'updatedAt': updatedAt.toIso8601String(),
      'size': sizeInMega,
    };
  }

  String toJson() => jsonEncode(toMap());

  BackupState copyWith({
    BackupType? type,
    DateTime? updatedAt,
    double? size,
  }) {
    return BackupState(
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      sizeInMega: size ?? sizeInMega,
    );
  }
}
