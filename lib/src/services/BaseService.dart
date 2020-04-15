import 'package:audio_service/audio_service.dart';
import 'package:moojik/src/models/SongMode.dart';

abstract class BaseService {
  Future<void> startAudioService();
  Future<void> getYoutubeLenk(String url,);
  Future<void> playOneSong(Song song);
//   playtheList(List<Song> songs);
}