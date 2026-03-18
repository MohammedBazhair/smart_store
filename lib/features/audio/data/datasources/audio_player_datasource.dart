import 'package:audioplayers/audioplayers.dart';

import '../../../../core/constants/log.dart';


class AudioPlayerDatasource {
  AudioPlayerDatasource(this._player);

  final AudioPlayer _player;

  Future<void> playAsset(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }

  Future<void> playFile(String path) async {
    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  Future<Duration?> getAudioDuration(String path) async {
    try {
      await _player.setSourceDeviceFile(path);

      final duration = await _player.getDuration();
      return duration;
    } catch (e,st) {
      Logger.debugLog(error: 'Error getting audio duration: $e',stackTrace: st);
      return null;
    }
  }
}
