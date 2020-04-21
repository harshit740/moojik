import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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

void myBackgroundTaskEntrypoint(queue) {
  AudioServiceBackground.run(() => MyBackgroundTask());
}

class MyBackgroundTask extends BackgroundAudioTask {
  List<MediaItem> _queue = <MediaItem>[];
  final _mediaItems = <String, MediaItem>{};
  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;
  String _isFetchingYoutube;
  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];
  int offset;

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
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("isRepeatMode") == 2) {
      onSeekTo(0);
      onPlay();
    } else if (hasNext) {
      onSkipToNext();
    } else if (prefs.getInt("isRepeatMode") == 1) {
      _queueIndex = -1;
      onSkipToNext();
    } else {
      _audioPlayer.pause();
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
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      //await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    _setState(state: BasicPlaybackState.connecting);
    if (!mediaItem.id.contains("/watch?v=")) {
      var duration = await _audioPlayer.setUrl(mediaItem.id);
      mediaItem.duration = duration.inMilliseconds;
      setSkipState();
    } else {
      final prefs = await SharedPreferences.getInstance();
      List<String> data = prefs.getStringList(mediaItem.id);
      if (data != null) {
        print(DateTime.now().difference(DateTime.parse(data[2])));
        if (DateTime.now().difference(DateTime.parse(data[2])).inHours < 8) {
          mediaItem.artUri = data[1];
          mediaItem.id = data[0];
          var duration = await _audioPlayer.setUrl(mediaItem.id);
          mediaItem.duration = duration.inMilliseconds;
          AudioServiceBackground.setMediaItem(mediaItem);
          setSkipState();
        } else {
          _isFetchingYoutube = mediaItem.id;
          AudioServiceBackground.getYoutubeLink(
              mediaItem.id.split("/watch?v=")[1]);
        }
      } else {
        _isFetchingYoutube = mediaItem.id;
        AudioServiceBackground.getYoutubeLink(
            mediaItem.id.split("/watch?v=")[1]);
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
  void onStop() {
       _audioPlayer.stop();
       _audioPlayer.dispose();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  @override
  void onAddQueueItem(MediaItem item) {
    // we're not actually maintaining a "queue", we're just keeping a map:
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
    if (_isFetchingYoutube == mediaItem.extras['youtubeUrl']) {
      mediaItem.artUri = details[1];
      mediaItem.id = details[0];
      var duration = await _audioPlayer.setUrl(mediaItem.id);
      mediaItem.duration = duration.inMilliseconds;
      AudioServiceBackground.setMediaItem(mediaItem);
      setSkipState();
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(mediaItem.extras['youtubeUrl'],
          [details[0], details[1], DateTime.now().toString()]);
    } else {
      _queue.forEach((f) {
        if (f.extras['youtubeUrl'] == details[2]) {
          f.id = details[0];
          f.artUri = details[1];
        }
      });
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
