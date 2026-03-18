import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/audio_player_datasource.dart';
import '../../data/repositories/audio_repository_impl.dart';
import 'audio_controller.dart';

final audioProvider = Provider((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final audioDatasourceProvider = Provider((ref) {
  final player = ref.read(audioProvider);
  return AudioPlayerDatasource(player);
});

final audioRepositoryProvider = Provider((ref) {
  final datasource = ref.read(audioDatasourceProvider);
  return AudioRepositoryImpl(datasource);
});

final audioControllerProvider = NotifierProvider<AudioController, void>(
  AudioController.new,
);
