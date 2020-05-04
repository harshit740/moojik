import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/bloc/playerBloc.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:moojik/src/services/audioService.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AudioFun extends BaseService {
  static const platformMethodChannel =
      const MethodChannel('com.moojikflux/music');
  Song oneSong;
  Map<String, dynamic> downloadQueue = <String, bool>{};
  List<Song> songQueue = [];

  AudioFun() {
    platformMethodChannel.setMethodCallHandler(_handleMethod);
  }

  @override
  Future<void> startAudioService() async {
    await AudioService.start(
      androidNotificationChannelDescription: "MoojikFlux",
      backgroundTaskEntrypoint: myBackgroundTaskEntrypoint,
      androidNotificationChannelName: 'Moojic Service',
      notificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      enableQueue: true,
      resumeOnClick: true,
    );
  }

  @override
  Future<Null> getYoutubeLenk(String url) async {
    String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('getYoutubeLenk', url);
      _message = result;
    } on PlatformException catch (e) {
      _message = "Problem Retriving Lenk: ${e.message}.";
    }
    print(_message);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "setYoutubeLenk":
        setUrl(call.arguments);
        return new Future.value("");
        break;
      case "setDownloadStatus":
        downloadQueue[call.arguments]=true;
        playerStates.triggerIsDownloading(downloadQueue);
        return new Future.value("");
        break;
       case "setDownloadComplete":
         if(downloadQueue.containsKey(call.arguments[0])) downloadQueue[call.arguments[0]] = false;
         AudioService.customAction("UpdateMediaItem",call.arguments);
         playerStates.triggerIsDownloading(downloadQueue);
         return new Future.value("");
    }
  }

  void setUrl(arguments) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> details = [];
    details.add(arguments[1]);
    details.add(arguments[2]);
    details.add(DateTime.now().toString());
    prefs.setStringList(oneSong.youtubeUrl, details);
    if (!AudioService.running) {
      await startAudioService();
    }
    await AudioService.addQueueItem(MediaItem(
        id: arguments[1],
        title: oneSong.title,
        album: "hgh",
        artUri: arguments[2],
        displaySubtitle: oneSong.title,
        extras: {
          "youtubeUrl": oneSong.youtubeUrl,
          "isDownloaded": oneSong.isDownloaded
        }));
    await AudioService.skipToNext();
  }

  @override
  playOneSong(Song song, String album) async {
    if (!AudioService.running) {
      await startAudioService();
    }
    if(album == "Searched Songs"){
      var values = await DBProvider.db.isInDownloadedSong(song.youtubeUrl);
      song.isDownloaded = values[0];
      values[0]?song.localUrl = values[1]:song.localUrl="";
    }
    await AudioService.addQueueItem(MediaItem(
        id: song.isDownloaded ? song.localUrl : song.youtubeUrl,
        title: song.title,
        album: album,
        artUri: song.thumbnailUrl != ""
            ? song.thumbnailUrl
            : "https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg?auto=format&q=60&fit=max&w=930",
        displaySubtitle: song.title,
        extras: {
          "youtubeUrl": song.youtubeUrl,
          "isDownloaded": "${song.isDownloaded}"
        }));
    await AudioService.playFromMediaId(song.youtubeUrl);
  }

  @override
  Future<void> playtheList(List<Song> songs, String playlist, shuffel) async {
    if (shuffel) {
      songs.shuffle();
    }
    if (songs.length > 0) {
      if (!AudioService.running) {
        await startAudioService();
      }
      await AudioService.customAction("clearQueue", "_queue");
      songs.forEach((f) async {
        AudioService.addQueueItem(MediaItem(
            id: f.isDownloaded ? f.localUrl : f.youtubeUrl,
            album: playlist,
            title: f.title,
            artUri: f.thumbnailUrl != ""
                ? f.thumbnailUrl
                : "https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg?auto=format&q=60&fit=max&w=930",
            extras: {"youtubeUrl": f.youtubeUrl,"isDownloaded":"${f.isDownloaded}"}));
      });
      await AudioService.playFromMediaId(songs[0].youtubeUrl);
    }
  }

  addToDownload(String youtubeUrl) async {
    if (!isInTheQueue(youtubeUrl)) {
      downloadQueue[youtubeUrl.split("/watch?v=")[1]] =true;
      playerStates.triggerIsDownloading(downloadQueue);
      await platformMethodChannel.invokeMethod(
          "addToDownloadQueue", youtubeUrl.split("/watch?v=")[1]);
      return true;
    }
    else{
      return false;
    }
  }

  isInTheQueue(String youtubeUrl) {
      if (downloadQueue.containsKey(youtubeUrl)) {
        return true;
      } else {
        return false;
      }
  }
}
