import '../../../../core/constants/log.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_player_datasource.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl(this._datasource);
  final AudioPlayerDatasource _datasource;

  @override
  Future<void> play(String assetPath) async {
    try {
      await _datasource.playAsset(assetPath);
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }

  @override
  Future<Duration?> getAudioDuration(String path) {
    return _datasource.getAudioDuration(path);
  }
}
