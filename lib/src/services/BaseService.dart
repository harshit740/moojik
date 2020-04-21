import 'package:moojik/src/models/SongMode.dart';

abstract class BaseService {
  Future<void> startAudioService();
  Future<void> getYoutubeLenk(String url,);
  Future<void> playOneSong(Song song,String album);
  Future<void> playtheList(List<Song> songs,String album,bool shuffel);
}