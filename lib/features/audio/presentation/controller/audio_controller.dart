import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/audio_repository.dart';
import 'audio_provider.dart';

class AudioController extends Notifier<void> {
  late final AudioRepository _repository;

  @override
  void build() {
    _repository = ref.read(audioRepositoryProvider);
  }

  Future<void> playSound(String assetPath) {
    return _repository.play(assetPath);
  }

  Future<void> playScannerBeep() {
    return playSound('assets/sounds/store_scanner_beep.mp3');
  }

  Future<void> playSuccessResult() {
    return playSound('assets/sounds/correct.mp3');
  }

  Future<void> playButtonClick() {
    return playSound('assets/sounds/button_click.mp3');
  }

  Future<void> playLogoIntro() {
    return playSound('assets/sounds/logo_intro.mp3');
  }

  Future<Duration> getSoundDuration(String? path) async {
    try {
      if (path == null) throw Exception();
      final duration = await _repository.getAudioDuration(path);
      return duration ?? Duration.zero;
    } catch (e) {
      return Duration.zero;
    }
  }
}
