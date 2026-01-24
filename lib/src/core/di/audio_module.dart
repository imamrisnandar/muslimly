import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

@module
abstract class AudioModule {
  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();
}
