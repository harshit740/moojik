import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moojik/src/bloc/playerBloc.dart';

class PlayerView extends StatefulWidget {
  @override
  PlayerViewState createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> with WidgetsBindingObserver {
  bool isPlaying;
  bool isStarted;
  AudioFun _myService = locator<BaseService>();
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  Song currentSong;
  int isRepeatMode;
  var som;
  bool isGetigFromYoutube = false;
  void setRepeat(int repeatmode) async {
    final prefs = await SharedPreferences.getInstance();
    var data = await prefs.setInt("isRepeatMode", repeatmode);
    setState(() {
      isRepeatMode = repeatmode;
    });
  }

  setInitStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRepeatMode = prefs.getInt("isRepeatMode");
      isGetigFromYoutube = false;
    });
  }

  @override
  void initState() {
    setInitStates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Playing from some Library"),
          elevation: 10,
          backgroundColor: Colors.black26,
          actions: <Widget>[
            FlatButton(
              child: Icon(Icons.file_download),
              onPressed: () {},
            )
          ],
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(10),
            child: StreamBuilder(
                stream: Rx.combineLatest3<List<MediaItem>, MediaItem,
                        PlaybackState, ScreenState>(
                    AudioService.queueStream,
                    AudioService.currentMediaItemStream,
                    AudioService.playbackStateStream,
                    (queue, mediaItem, playbackState) =>
                        ScreenState(queue, mediaItem, playbackState)),
                builder: (context, snapshot) {
                  final screenState = snapshot.data;
                  final queue = screenState?.queue;
                  final mediaItem = screenState?.mediaItem;
                  final state = screenState?.playbackState;
                  final basicState =
                      state?.basicState ?? BasicPlaybackState.none;
                  if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.only(top: 5, bottom: 20),
                            child: Center(
                              child: getArt(mediaItem),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            if (mediaItem != null &&
                                mediaItem.title != null) ...[
                              Text(
                                "${mediaItem.title}",
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ] else if (mediaItem == null) ...[
                              Text(
                                "Welcome Nigga",
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ],
                          ],
                        ),
                        if (basicState != BasicPlaybackState.none &&
                            basicState != BasicPlaybackState.stopped) ...[
                          Container(
                            width: 400,
                            child: positionIndicator(mediaItem, state),
                          )
                        ],
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              child: Icon(
                                Icons.shuffle,
                                size: 25,
                              ),
                              onTap: () {},
                            ),
                            if (basicState ==
                                    BasicPlaybackState.skippingToPrevious ||
                                basicState ==
                                    BasicPlaybackState.skippingToQueueItem ||
                                isGetigFromYoutube) ...[
                              CircularProgressIndicator(),
                            ] else ...[
                              FlatButton(
                                child: Icon(
                                  Icons.skip_previous,
                                  size: 50,
                                ),
                                onPressed: () {
                                  AudioService.skipToPrevious();
                                },
                              ),
                            ],
                            if (basicState == BasicPlaybackState.none) ...[
                              startButton(),
                            ] else if (basicState ==
                                    BasicPlaybackState.playing ||
                                basicState == BasicPlaybackState.buffering) ...[
                              pauseButton(),
                            ] else if (basicState ==
                                BasicPlaybackState.paused) ...[
                              playButton(),
                            ] else if (basicState ==
                                BasicPlaybackState.connecting) ...[
                              CircularProgressIndicator()
                            ] else if (basicState ==
                                    BasicPlaybackState.skippingToNext ||
                                basicState ==
                                    BasicPlaybackState.skippingToPrevious) ...[
                              CircularProgressIndicator()
                            ],
                            if (basicState ==
                                    BasicPlaybackState.skippingToNext ||
                                basicState ==
                                    BasicPlaybackState.skippingToQueueItem ||
                                isGetigFromYoutube) ...[
                              CircularProgressIndicator(),
                            ] else ...[
                              FlatButton(
                                child: Icon(
                                  Icons.skip_next,
                                  size: 50,
                                ),
                                onPressed: () {
                                  try {
                                    if (!AudioService.running) {
                                      _myService.startAudioService();
                                    }
                                    AudioService.skipToNext();
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              )
                            ],
                            if (isRepeatMode == 1) ...[
                              InkWell(
                                child: Icon(
                                  Icons.repeat,
                                  size: 25,
                                ),
                                onTap: () {
                                  setRepeat(2);
                                },
                              )
                            ] else if (isRepeatMode == 2) ...[
                              InkWell(
                                child: Icon(
                                  Icons.repeat_one,
                                  size: 25,
                                ),
                                onTap: () {
                                  setRepeat(0);
                                },
                              )
                            ] else ...[
                              InkWell(
                                child: Icon(
                                  Icons.do_not_disturb_alt,
                                  size: 25,
                                ),
                                onTap: () {
                                  setRepeat(1);
                                },
                              )
                            ]
                          ],
                        )
                      ],
                    );
                  } else {
                    return Center(child: Text('No media is currently Playing'));
                  }
                })));
  }

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = snapshot.data ?? state.currentPosition.toDouble();
        double duration = mediaItem?.duration?.toDouble();
        if (duration != null) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    "${Duration(minutes: int.tryParse((state.currentPosition / 1000).toStringAsFixed(0))).inSeconds}"),
                Container(
                  width: 250,
                  child: Slider(
                    activeColor: Colors.white,
                    min: 0.0,
                    max: duration,
                    value: seekPos ?? max(0.0, min(position, duration)),
                    onChanged: (value) {
                      _dragPositionSubject.add(value);
                    },
                    onChangeEnd: (value) {
                      AudioService.seekTo(value.toInt());
                      // TODO: Improve this code.
                      seekPos = value;
                      _dragPositionSubject.add(null);
                    },
                  ),
                ),
                Text("${Duration(milliseconds: duration.toInt()).inMinutes}"),
              ]);
        } else {
          return Divider();
        }
      },
    );
  }

  GestureDetector startButton() => GestureDetector(
        child: Icon(
          Icons.play_circle_filled,
          size: 76,
        ),
        onTap: () async {
          if (!AudioService.running) {
            _myService.startAudioService();
          }
          AudioService.play();
        },
      );

  GestureDetector playButton() => GestureDetector(
        child: Icon(
          Icons.play_circle_filled,
          size: 76,
        ),
        onTap: AudioService.play,
      );
  GestureDetector pauseButton() => GestureDetector(
        child: Icon(
          Icons.pause_circle_filled,
          size: 76,
        ),
        onTap: AudioService.pause,
      );
  GestureDetector stopButton() => GestureDetector(
        child: Icon(
          Icons.stop,
          size: 76,
        ),
        onTap: AudioService.stop,
      );

  getArt(MediaItem mediaItem) {
    if (mediaItem != null && mediaItem.artUri != null)
      return Image.network(
        mediaItem.artUri,
        height: MediaQuery.of(context).size.height / 2.5,
        fit: BoxFit.fill,
        colorBlendMode: BlendMode.darken,
      );
    else {
      return Image.network(
        'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg?auto=format&q=60&fit=max&w=930',
        fit: BoxFit.fitWidth,
      );
    }
  }
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}
