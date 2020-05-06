import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/bloc/playerBloc.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:moojik/src/services/MusicService.dart';

class AudioFun extends BaseService {
  static const platformMethodChannel =
      const MethodChannel('com.moojikflux/music');
  Map<String, dynamic> downloadQueue = <String, bool>{};

  AudioFun() {
    platformMethodChannel.setMethodCallHandler(_handleMethod);
  }

  @override
  Future<void> startAudioService() async {
    await AudioService.start(
      androidNotificationChannelDescription: "MoojikFlux",
      backgroundTaskEntrypoint: myBackgroundTaskEntrypoint,
      androidNotificationChannelName: 'MoojicService',
      notificationColor: 0xFF01183D,
      androidNotificationIcon: 'drawable/ic_launcher_notification',
      enableQueue: true,
      resumeOnClick: true,
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "setDownloadStatus":
        downloadQueue[call.arguments] = true;
        playerStates.triggerIsDownloading(downloadQueue);
        return new Future.value("");
        break;
      case "setDownloadComplete":
        if (downloadQueue.containsKey(call.arguments[0]))
          downloadQueue[call.arguments[0]] = false;
        AudioService.customAction("UpdateMediaItem", call.arguments);
        playerStates.triggerIsDownloading(downloadQueue);
        return new Future.value("");
    }
  }

  @override
  playOneSong(Song song, String album) async {
    if (!AudioService.running) {
      await startAudioService();
    }
    if (album == "TrendingSongs") {
      await DBProvider.db.addSongtoDb(song);
    }
    if (album == "Searched Songs" || album == "TrendingSongs") {
      var values = await DBProvider.db.isInDownloadedSong(song.youtubeUrl);
      song.isDownloaded = values[0];
      values[0] ? song.localUrl = values[1] : song.localUrl = "";
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
            extras: {
              "youtubeUrl": f.youtubeUrl,
              "isDownloaded": "${f.isDownloaded}"
            }));
      });
      await AudioService.playFromMediaId(songs[0].youtubeUrl);
    }
  }

  @override
  addToDownload(String youtubeUrl) async {
    if (!isInTheQueue(youtubeUrl)) {
      downloadQueue[youtubeUrl.split("/watch?v=")[1]] = true;
      playerStates.triggerIsDownloading(downloadQueue);
      await platformMethodChannel.invokeMethod(
          "addToDownloadQueue", youtubeUrl.split("/watch?v=")[1]);
      return true;
    } else {
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
