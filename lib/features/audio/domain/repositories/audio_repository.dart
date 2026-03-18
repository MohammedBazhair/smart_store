abstract class AudioRepository {
  Future<void> play(String assetPath);
  Future<Duration?> getAudioDuration(String path);
}
