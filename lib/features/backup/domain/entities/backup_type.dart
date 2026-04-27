import 'package:flutter/material.dart';

enum BackupType {
  local(
    icon: Icons.devices_rounded,
    label: 'نسخة محلية',
  ),
  cloud(
    icon: Icons.backup,
    label: 'نسخة سحابية',
  ),
  hybrid(
    icon: Icons.cloud_download,
    label: 'نسخة محلية + سحابية',
  );

  const BackupType({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  ({String title, String subtitle}) get uiInfoBackup {
    return switch (this) {
      local => (
          title: 'محلية',
          subtitle: 'تخزين بياناتك محليا داخل ذاكرة هذا الجهاز.',
        ),
      cloud => (
          title: 'على السحابة',
          subtitle:
              'يتم رفع نسخة احتياطية إلى الخادم مع إمكانية استعادتها من أي جهاز.',
        ),
      hybrid => (
          title: 'محلية + سحابية',
          subtitle: 'يتم حفظ نسخة احتياطية على الجهاز وعلى الخادم معًا.',
        ),
    };
  }
}

enum RestoreBackupType {
  local(
    icon: Icons.devices_rounded,
  ),
  cloud(
    icon: Icons.backup,
  );

  const RestoreBackupType({
    required this.icon,
  });

  final IconData icon;

  ({String title, String subtitle}) get uiInfoRestore {
    return switch (this) {
      local => (
          title: 'من ملف على الجهاز',
          subtitle: 'استرجاع بياناتك من ملف .db محفوظ مسبقًا داخل الجهاز.',
        ),
      cloud => (
          title: 'من نسخة احتياطية من السحابة',
          subtitle:
              'حمل آخر نسخة محفوظة على الخادم لضمان العودة إلى أحدث بياناتك بأمان.',
        ),
    };
  }
}
