import '../../../constants/enums.dart';

class AppUiEvent {
  const AppUiEvent({
    required this.message,
    required this.type,
  });
  final String message;
  final SnackBarType type;
}
