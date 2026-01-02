/// Result class للتعامل مع النجاح والفشل
sealed class Result<T> {
  const Result();
}

/// حالة النجاح
final class SuccessState<T> extends Result<T> {
  const SuccessState(this.data);
  final T data;
}

/// حالة الفشل
final class ErrorState<T> extends Result<T> {
  const ErrorState(this.message);
  final String message;
}

