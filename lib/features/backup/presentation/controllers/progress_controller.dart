import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressState {
  // وصف المرحلة

  const ProgressState({
    required this.value,
    required this.stage,
  });
  final double value; // من 0 إلى 1
  final String stage;

  String get progressUiText => '${(value * 100).toInt().clamp(0, 100)}';

  ProgressState copyWith({
    double? value,
    String? stage,
  }) {
    return ProgressState(
      value: value ?? this.value,
      stage: stage ?? this.stage,
    );
  }
}

class ProgressController extends Notifier<ProgressState> {
  ProgressController() : super();

  @override
  ProgressState build() {
    return const ProgressState(value: 0, stage: '');
  }

  bool _running = false;
  double _target = 0;
  double _display = 0;

  void update(double value) {
    final clamped = value.clamp(0.0, 1.0);

    _target = clamped;
  }

  void setStage(String stage) {
    _tick();

    _reset();
    state = state.copyWith(stage: stage);
  }

  void _tick() {
    if (_running) return;
    _running = true;

    Future.doWhile(() async {
      if (!ref.mounted) return false;

      final diff = _target - _display;

      if (_target == 1.0) {
        _display = 1.0;
        state = state.copyWith(value: _display);
      } else if (_display < _target) {
        _display += diff * 0.1;
        state = state.copyWith(value: _display);
      }

      await Future.delayed(const Duration(milliseconds: 27));
      return true;
    });
  }

  void _reset() {
    _display = 0;
    _target = 0.3;
    state = const ProgressState(value: 0, stage: '');
  }
}

final progressControllerProvider =
    NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);
