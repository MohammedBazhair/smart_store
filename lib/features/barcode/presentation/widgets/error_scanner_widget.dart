import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/utils/result.dart';
import '../controllers/flashlight_controller.dart';

class ErrorScannerWidget extends ConsumerWidget {
  const ErrorScannerWidget({
    super.key,
    required this.error,
  });

  final MobileScannerException error;

  String get errorMessage {
    try {
      return switch (error.errorCode) {
        MobileScannerErrorCode.permissionDenied =>
          'يجب منح صلاحية الوصول للكاميرا',
        MobileScannerErrorCode.unsupported =>
          'استعمال الماسح غير مدعوم في هذا الجهاز',
        MobileScannerErrorCode.controllerAlreadyInitialized =>
          throw UnimplementedError(),
        MobileScannerErrorCode.controllerDisposed => throw UnimplementedError(),
        MobileScannerErrorCode.controllerUninitialized =>
          throw UnimplementedError(),
        MobileScannerErrorCode.genericError => throw UnimplementedError(),
      };
    } on UnimplementedError catch (_) {
      return 'حدثت اخطاء منعت تشغيل الماسح';
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: [
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = ref.read(mobileScannerControllerProvider);
              switch (error.errorCode) {
                case MobileScannerErrorCode.permissionDenied:
                  final result = await PermissionsService.requestCamera();
                  if (result is ErrorState<bool>) {
                    context.showSnakbar(
                      'لم يتمكن من أخذ الصلاحية بنجاح',
                      type: SnackBarType.error,
                    );
                  }
                case MobileScannerErrorCode.controllerUninitialized:
                case MobileScannerErrorCode.controllerDisposed:
                  await controller.start();
                case MobileScannerErrorCode.controllerAlreadyInitialized:
                case MobileScannerErrorCode.genericError:
                  ref.invalidate(mobileScannerControllerProvider);
                  context.pop();
                case MobileScannerErrorCode.unsupported:
              }
            },
            child: const Text('إصلاح'),
          ),
        ],
      ),
    );
  }
}
