import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Rect region;
  Color colors;
  String playingfrom;
  void setRepeat(int repeatmode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("isRepeatMode", repeatmode);
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
    AudioService.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem != null) {
        setState(() {
          playingfrom = mediaItem.album;
        });
        if (mediaItem.extras != null &&
            mediaItem.extras.containsKey('colors')) {
          print(
              "Called Mdedaiaddsadasdasdasasd ${mediaItem.extras['colors'].toString().split("Color(")[1].split(')')[0]}");
          colors = Color(int.parse(mediaItem.extras['colors']
              .toString()
              .split("Color(")[1]
              .split(')')[0]));
          setState(() {
            colors = colors;
          });
        }
      }
    });
  }

  @override
  void initState() {
    setInitStates();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors != null ? colors : Color(0xFF1B262C),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Playing from $playingfrom"),
          elevation: 0,
          backgroundColor: colors != null ? colors : Color(0xFF1B262C),
          actions: <Widget>[],
        ),
        body: Center(
            child: Container(
                color: colors,
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
                      MediaItem mediaItem = screenState?.mediaItem;
                      final state = screenState?.playbackState;
                      final basicState =
                          state?.basicState ?? BasicPlaybackState.none;
                      if (snapshot.hasData) {
                        return Container(
                            child: Column(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(60.0)),
                                  ),
                                  child: getArt(mediaItem),
                                ))),
                            Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: Text(
                                        "I'm not looking for an answer I just hope these words will help Whoever's listening If someone cares to listen in I've been up and down in life Sure, every day's a chance to fight Forever wrestling, trying to make amends again",
                                        textAlign: TextAlign.center,
                                        textScaleFactor: 1.1,
                                        maxLines: 3,
                                        softWrap: true,
                                        textWidthBasis: TextWidthBasis.parent,
                                        style: TextStyle(
                                            fontStyle: FontStyle.normal),
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ),
                                    if (mediaItem != null &&
                                        mediaItem.title != null) ...[
                                      Center(
                                        child: Text(
                                          "${mediaItem.title.toString().split("- Duration")[0]}",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24),
                                        ),
                                      )
                                    ] else if (mediaItem == null) ...[
                                      Text(
                                        "Welcome Nigga",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ],
                                  ],
                                )),
                            if (basicState != BasicPlaybackState.none &&
                                basicState != BasicPlaybackState.stopped) ...[
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: positionIndicator(mediaItem, state),
                              )
                            ],
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(
                                        Icons.blur_circular,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                      onPressed: null),
                                  IconButton(
                                      icon: Icon(Icons.featured_play_list,
                                          color: Colors.white, size: 35),
                                      onPressed: null),
                                  IconButton(
                                      icon: Icon(
                                        Icons.file_download,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                      onPressed: null),
                                ],
                              ),
                            ),
                            Flex(
                              mainAxisSize: MainAxisSize.min,
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
                                FlatButton(
                                  child: Icon(
                                    Icons.skip_previous,
                                    size: 50,
                                  ),
                                  onPressed: () {
                                    AudioService.skipToPrevious();
                                  },
                                ),
                                if (basicState == BasicPlaybackState.none) ...[
                                  startButton(),
                                ] else if (basicState ==
                                        BasicPlaybackState.playing ||
                                    basicState ==
                                        BasicPlaybackState.buffering) ...[
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
                                        BasicPlaybackState
                                            .skippingToPrevious) ...[
                                  CircularProgressIndicator()
                                ],
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
                                ),
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
                        ));
                      } else {
                        return Center(
                            child: Text('No media is currently Playing'));
                      }
                    }))));
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
          String twoDigitSeconds = twoDigits(
              Duration(milliseconds: duration.toInt()).inSeconds.remainder(60));
          String twoDigitMinutes = twoDigits(
              Duration(milliseconds: duration.toInt()).inMinutes.remainder(60));
          String twoDigitSecondss = twoDigits(
              Duration(milliseconds: state.currentPosition.toInt())
                  .inSeconds
                  .remainder(60));
          String twoDigitMinutess = twoDigits(
              Duration(milliseconds: state.currentPosition.toInt())
                  .inMinutes
                  .remainder(60));
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              //state.currentPosition / 1000
              children: <Widget>[
                Text("$twoDigitMinutess:$twoDigitSecondss"),
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Slider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white60,
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
                Text("$twoDigitMinutes:$twoDigitSeconds")
              ]);
        } else {
          return Slider(
            activeColor: Colors.white,
            inactiveColor: Colors.white60,
            min: 0.0,
            max: 0,
            onChanged: (double value) {},
            value: 0,
          );
        }
      },
    );
  }

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  GestureDetector startButton() => GestureDetector(
        child: Icon(
          Icons.play_circle_outline,
          size: 50,
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
          Icons.play_circle_outline,
          size: 60,
        ),
        onTap: AudioService.play,
      );

  GestureDetector pauseButton() => GestureDetector(
        child: Icon(
          Icons.pause_circle_outline,
          size: 60,
        ),
        onTap: AudioService.pause,
      );

  GestureDetector stopButton() => GestureDetector(
        child: Icon(
          Icons.stop,
          size: 60,
        ),
        onTap: AudioService.stop,
      );

  getArt(MediaItem mediaItem) {
    if (mediaItem != null && mediaItem.artUri != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          mediaItem.artUri,
        ),
        backgroundColor: colors,
        foregroundColor: colors,
        maxRadius: 115,
        minRadius: 100,
      );
    } else {
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
