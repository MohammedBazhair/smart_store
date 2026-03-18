import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_player_datasource.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl(this._datasource);
  final AudioPlayerDatasource _datasource;

  @override
  Future<void> play(String assetPath) {
    
    return _datasource.playAsset(assetPath);
  }

  @override
  Future<Duration?> getAudioDuration(String path) {
    return _datasource.getAudioDuration(path);
  }
}
