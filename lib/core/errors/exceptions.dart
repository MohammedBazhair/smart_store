abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class DuplicateBarcodeException extends AppException {
  const DuplicateBarcodeException([super.message = 'هذا الباركود مستخدم مسبقا']);
}
