import 'package:moojik/src/models/SongMode.dart';

abstract class BaseService {
  Future<void> startAudioService();
  Future<bool>  addToDownload(String youtubeUrl);
  Future<void> playOneSong(Song song,String album);
  Future<void> playtheList(List<Song> songs,String album,bool shuffel);
}