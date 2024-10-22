import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/utils/checkConnectivity.dart';
import 'package:moojik/src/utils/songLyrics.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

void myBackgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => MusicService());
}

class MusicService extends BackgroundAudioTask {
  static List<MediaItem> _queue = <MediaItem>[];
  final _mediaItems = <String, MediaItem>{};
  int _queueIndex = -1;
  var prefs;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;
  bool firstTime;

  MediaItem get mediaItem => _queue[_queueIndex];
  PaletteGenerator paletteGenerator;
  Color colors;

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  @override
  Future<void> onStart() async {
    firstTime = true;
    prefs = await SharedPreferences.getInstance();
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    AudioServiceBackground.setQueue(_queue);
    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() async {
    if (prefs.getInt("isRepeatMode") == 2) {
      onSeekTo(0);
      onPlay();
    } else if (hasNext) {
      onSkipToNext();
    } else if (prefs.getInt("isRepeatMode") == 1) {
      _queueIndex = -1;
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final isConnected = await checkConnectivity();
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) {
      if (firstTime) {
        firstTime = false;
        return;
      } else if (_queue.isNotEmpty) {
        if (offset == -1) {
          _queueIndex = _queue.length;
          return onSkipToPrevious();
        } else if (offset == 1) {
          _queueIndex = -1;
          return onSkipToNext();
        }
      }
      return;
    }
    if (_queueIndex == 0 && _queue.length - 1 == 0) {
      return;
    }
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      //await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    mediaItem.extras['lyrics'] = "Getting Your Lyrics calm down";
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    _setState(state: BasicPlaybackState.connecting);
    if (!mediaItem.id.contains("/watch?v=")) {
      var duration;
      if (mediaItem.extras["isDownloaded"] == "true" &&
          mediaItem.id.contains("com.moojik.moojik")) {
        duration = await _audioPlayer.setFilePath(mediaItem.id);
      } else {
        if (isConnected) {
          duration = await _audioPlayer.setUrl(mediaItem.id);
        } else {
          if (hasNext && mediaItem.extras["isDownloaded"] == "true") {
            return onSkipToNext();
          } else {
            onStop();
          }
        }
      }
      mediaItem.duration = duration.inMilliseconds;
      AudioServiceBackground.setMediaItem(mediaItem);
      setSkipState();
      await DBProvider.db.updateLastPlayed(mediaItem.extras['youtubeUrl']);
      await getLyrics(mediaItem.title);
      return await _updatePaletteGenerator();
    } else {
      List<String> data = prefs.getStringList(mediaItem.id);
      if (data != null && isConnected) {
        if (DateTime.now().difference(DateTime.parse(data[2])).inHours < 5) {
          mediaItem.artUri = data[1];
          mediaItem.id = data[0];
          var duration = await _audioPlayer.setUrl(mediaItem.id);
          mediaItem.duration = duration.inMilliseconds;
          AudioServiceBackground.setMediaItem(mediaItem);
          setSkipState();
          await DBProvider.db.updateLastPlayed(mediaItem.extras['youtubeUrl']);
          await getLyrics(mediaItem.title);
          return await _updatePaletteGenerator();
        } else {
          if (isConnected) {
            AudioServiceBackground.getYoutubeLink(
                mediaItem.extras['youtubeUrl'].split("/watch?v=")[1]);
          } else {
            if (hasNext && mediaItem.extras["isDownloaded"] == "true") {
              return onSkipToNext();
            } else {
              onStop();
            }
          }
          await getLyrics(mediaItem.title);
        }
      } else {
        if (isConnected) {
          AudioServiceBackground.getYoutubeLink(
              mediaItem.extras['youtubeUrl'].split("/watch?v=")[1]);
        } else {
          if (hasNext && mediaItem.extras["isDownloaded"] == "true") {
            onSkipToNext();
          } else {
            onStop();
          }
        }
        await getLyrics(mediaItem.title);
      }
    }
  }

  @override
  Future<void> onCustomAction(String name, arguments) async {
    super.onCustomAction(name, arguments);
    switch (name) {
      case "clearQueue":
        _queue.clear();
        _mediaItems.clear();
        _queueIndex = -1;
        AudioServiceBackground.setQueue(_queue);
        break;
      case "UpdateMediaItem":
        if (_mediaItems.containsKey("/watch?v=${arguments[0]}")) {
          MediaItem currentItem = _mediaItems["/watch?v=${arguments[0]}"];
          currentItem.id = arguments[1];
          currentItem.extras['isDownloaded'] = true;
          _mediaItems["/watch?v=${arguments[0]}"] = currentItem;
          if (mediaItem.extras["youtubeUrl"] == "/watch?v=${arguments[0]}") {
            AudioServiceBackground.setMediaItem(currentItem);
          }
          int index = _queue.indexWhere((MediaItem test) {
            return test.extras['youtubeUrl'] == "/watch?v=${arguments[0]}"
                ? true
                : false;
          });
          if (index >= 0) _queue[index] = currentItem;
        }
    }
  }

  void setSkipState() {
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  void onAudioFocusLost() {
      onPause();
    _setState(state: BasicPlaybackState.paused);
  }


  @override
  void onAudioFocusGained() {
    onPlay();
  }

  @override
  void onStop() {
    _setState(state: BasicPlaybackState.stopped);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _completer.complete();
  }

  @override
  void onAddQueueItem(MediaItem item) {
    if (!_mediaItems.containsKey(item.extras['youtubeUrl'])) {
      _mediaItems[item.extras['youtubeUrl']] = item;
      _queue.add(item);
    }
  }

  @override
  void onPlayFromMediaId(String mediaId) {
    if (_mediaItems.containsKey(mediaId)) {
      int index = _queue.indexWhere((MediaItem test) {
        return test.extras['youtubeUrl'] == mediaId ? true : false;
      });
      if (index >= 0) _queueIndex = index - 1;
      onSkipToNext();
    }
    // play the item at mediaItems[mediaId]
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  @override
  void setYotutubeLink(List details) async {
    if (details[2] ==
        mediaItem.extras['youtubeUrl'].toString().split("?v=")[1]) {
      mediaItem.artUri = details[1];
      mediaItem.id = details[0];
      var duration = await _audioPlayer.setUrl(mediaItem.id);
      mediaItem.duration = duration.inMilliseconds;
      AudioServiceBackground.setMediaItem(mediaItem);
      setSkipState();
      await DBProvider.db.updateLastPlayed(mediaItem.extras['youtubeUrl']);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(mediaItem.extras['youtubeUrl'],
          [details[0], details[1], DateTime.now().toString()]);
    } else {
      await compute(addParsedToQueue, details);
    }
    return await _updatePaletteGenerator();
  }

  static addParsedToQueue(List details) async {
    _queue.forEach((f) {
      if (f.extras['youtubeUrl'].split("?v=")[1] == details[2]) {
        f.id = details[0];
        f.artUri = details[1];
      }
    });
  }

  getLyrics(String title) async {
    var lyrics = await getSongLyrics(
        title.replaceAll(" - ", " ").split(" Duration")[0],
        mediaItem.extras["youtubeUrl"]);
    mediaItem.extras['lyrics'] = lyrics;
    AudioServiceBackground.setMediaItem(mediaItem);
  }

  Future<void> _updatePaletteGenerator() async {
    if (mediaItem.artUri != null &&
        mediaItem.artUri != "" &&
        !mediaItem.extras.containsKey('colors')) {
      paletteGenerator = await PaletteGenerator.fromImageProvider(
          CachedNetworkImageProvider(mediaItem.artUri),
          maximumColorCount: 6,
          timeout: Duration(seconds: 50));
      if (paletteGenerator.darkMutedColor != null) {
        colors = paletteGenerator.darkMutedColor.color;
      } else if (paletteGenerator.darkVibrantColor != null) {
        colors = paletteGenerator.darkVibrantColor.color;
      } else {
        colors = Color(0xFF1B262C);
      }
      mediaItem.extras['colors'] = colors.toString();
      AudioServiceBackground.setMediaItem(mediaItem);
    }
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }
}
