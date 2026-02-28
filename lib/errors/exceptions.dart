abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class DuplicateBarcodeException extends AppException {
  const DuplicateBarcodeException([
    super.message = 'هذا الباركود مستخدم مسبقا',
  ]);
}

class OtpWrongException extends AppException {
  const OtpWrongException([super.message = 'الرمز المدخل غير صحيح']);
}

class UserNotLoggedInException extends AppException {
  const UserNotLoggedInException(super.message);
}

class AuthAppException extends AppException {
  const AuthAppException(super.message);
}

class CreditsZeroException extends AppException {
  const CreditsZeroException(super.message);
}

class SaveNoteFirstException extends AppException {
  const SaveNoteFirstException(super.message);
}

class AuthFailedException extends AppException {
  const AuthFailedException(super.message);
}

class InternetException extends AppException {
  const InternetException([
    super.message =
        'حدث خطأ في الاتصال، تأكد من اتصالك بالانترنت وأعد المحاولة لاحقا',
  ]);
}

class AlreadyRunnedException extends AppException {
  const AlreadyRunnedException(super.message);
}

class PermissionsException extends AppException {
  const PermissionsException(super.message);
}

class UserPhoneNotFoundException extends AppException {
  const UserPhoneNotFoundException(super.message);
}

class NoStoreSelectedException extends AppException {
  const NoStoreSelectedException(super.message);
}
