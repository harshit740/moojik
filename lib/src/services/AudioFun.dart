import 'package:audio_service/audio_service.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:moojik/src/services/audioService.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioFun extends BaseService {
  static const platformMethodChannel =
      const MethodChannel('com.moojikflux/music');
  Song oneSong;

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
    }
  }

  @override
  playOneSong(Song song, String album) async {
    if (!AudioService.running) {
      await startAudioService();
    }
    await AudioService.addQueueItem(MediaItem(
        id: song.youtubeUrl,
        title: song.title,
        album: album,
        artUri:
            "https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg?auto=format&q=60&fit=max&w=930",
        displaySubtitle: song.title,
        extras: {"youtubeUrl": song.youtubeUrl}));
    await AudioService.playFromMediaId(song.youtubeUrl);
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
        extras: {"youtubeUrl": oneSong.youtubeUrl}));
    await AudioService.skipToNext();
  }
}
