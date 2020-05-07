import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moojik/routing_constants.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/bloc/playerBloc.dart';
import 'package:moojik/src/models/ScreenStateModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/MusicHelperService.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Database.dart';

class PlayerView extends StatefulWidget {
  @override
  PlayerViewState createState() => PlayerViewState();
}

AudioFun _myService = locator<BaseService>();

class PlayerViewState extends State<PlayerView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  AudioFun _myService = locator<BaseService>();
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);
  Song currentSong;
  int isRepeatMode;
  Color colors;
  bool showLyrics = false;
  MediaItem currentMediaItem;
  bool isDownloading = false;
  bool isLikedSong = false;
  String playingFrom = " ";
  var minRedius;
  var maxRedius;
  int virticalMarginBetweenControls;
  int bodyBottomPadding;
  var height;
  var width;
  var bottomBody = 10;
  void setRepeat(int repeatMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("isRepeatMode", repeatMode);
    setState(() {
      isRepeatMode = repeatMode;
    });
  }

  setInitStates() async {
    initDownloaderStat();
    AudioService.currentMediaItemStream.listen((mediaItem) {
      if (mounted) {
        if (mediaItem != null) {
          currentMediaItem = mediaItem;
          isInLikedSong(mediaItem.extras['youtubeUrl']);
          setState(() {
            currentMediaItem = AudioService.currentMediaItem;
            playingFrom = mediaItem.album;
          });
          if (_myService.downloadQueue.containsKey(AudioService
              .currentMediaItem.extras['youtubeUrl']
              .split("/watch?v=")[1])) {
            setState(() {
              isDownloading = _myService.downloadQueue[AudioService
                  .currentMediaItem.extras['youtubeUrl']
                  .split("/watch?v=")[1]];
            });
          } else {
            setState(() {
              isDownloading = false;
            });
          }
          if (mediaItem.extras != null &&
              mediaItem.extras.containsKey('colors')) {
            colors = Color(int.parse(mediaItem.extras['colors']
                .toString()
                .split("Color(")[1]
                .split(')')[0]));
            setState(() {
              colors = colors;
            });
          }
        }
      }
    });

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRepeatMode = prefs.getInt("isRepeatMode");
    });
  }

  initDownloaderStat() {
    playerStates.isDownloading.listen((onData) async {
      if (mounted) {
        if (_myService.downloadQueue.containsKey(AudioService
            .currentMediaItem.extras['youtubeUrl']
            .split("/watch?v=")[1])) {
          setState(() {
            isDownloading = _myService.downloadQueue[AudioService
                .currentMediaItem.extras['youtubeUrl']
                .split("/watch?v=")[1]];
          });
        } else {
          setState(() {
            isDownloading = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setInitStates();
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).height - reducedBy) / dividedBy;
  }

  double screenWidth(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).width - reducedBy) / dividedBy;
  }

  double screenHeightExcludingToolbar(BuildContext context,
      {double dividedBy = 1}) {
    return screenHeight(context,
        dividedBy: dividedBy, reducedBy: kToolbarHeight);
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      leading: IconButton(icon: Icon(Icons.keyboard_arrow_down), onPressed: () => Navigator.pop(context),),
      title: Text("Playing from $playingFrom"),
      elevation: 0,
      backgroundColor: colors != null ? colors : Color(0xFF1B262C),
      actions: <Widget>[],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var screenSize = MediaQuery.of(context).size;
    width = screenSize.width;
    height = screenSize.height;
    var hightExludingAppbar = height - appBar().preferredSize.height;
    if (hightExludingAppbar > 660) {
      minRedius = 125;
      maxRedius = 150;
      bodyBottomPadding = 10;
      virticalMarginBetweenControls = 25;
    } else if (hightExludingAppbar > 615 && width > 358) {
      minRedius = 115;
      maxRedius = 135;
      bodyBottomPadding = 10;
      virticalMarginBetweenControls = 10;
    } else if (hightExludingAppbar > 630) {
      minRedius = 115;
      maxRedius = 132;
      bodyBottomPadding = 10;
      virticalMarginBetweenControls = 15;
    } else if (hightExludingAppbar < 630) {
      minRedius = 100;
      maxRedius = 105;
      virticalMarginBetweenControls = 15;
      bodyBottomPadding = 5;
      bottomBody = 3;
    } else if (hightExludingAppbar < 598) {
      minRedius = 100;
      maxRedius = 100;
      virticalMarginBetweenControls = 0;
      bodyBottomPadding = 0;
      bottomBody = 0;
    }
    else if (hightExludingAppbar < 590) {
      minRedius = 80;
      maxRedius = 80;
      virticalMarginBetweenControls = 0;
      bodyBottomPadding = 0;
      bottomBody = 0;
    }
    return Scaffold(
        backgroundColor: colors != null ? colors : Color(0xFF1B262C),
        appBar: appBar(),
        body: AnimatedContainer(
            duration: Duration(seconds: 2),
            curve: Curves.bounceIn,
            color: colors != null ? colors : Color(0xFF1B262C),
            child: Flex(
                mainAxisSize: MainAxisSize.max,
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Container(
                      height: screenHeightExcludingToolbar(context) -
                          appBar().preferredSize.height,
                      padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: bodyBottomPadding.toDouble()),
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
                            MediaItem mediaItem = screenState?.mediaItem;
                            final state = screenState?.playbackState;
                            final basicState =
                                state?.basicState ?? BasicPlaybackState.none;
                            if (snapshot.hasData) {
                              return Container(
                                  child: Column(
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, bottom: bottomBody.toDouble()),
                                      child: Center(
                                          child: Container(
                                              child: InkWell(
                                        onDoubleTap: () {
                                          if (showLyrics == false) {
                                            setState(() {
                                              showLyrics = true;
                                            });
                                          } else {
                                            setState(() {
                                              showLyrics = false;
                                            });
                                          }
                                        },
                                        child: AnimatedCrossFade(
                                            firstChild: Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                CircleAvatar(
                                                  radius:
                                                      maxRedius + 9.toDouble(),
                                                  backgroundColor: Colors.white,
                                                  child: getArt(mediaItem,
                                                      minRedius, maxRedius),
                                                ),
                                              ],
                                            ),
                                            firstCurve: Curves.easeInOutCubic,
                                            secondCurve: Curves.easeInOut,
                                            secondChild: CircleAvatar(
                                                backgroundColor: colors,
                                                maxRadius: maxRedius
                                                        .toDouble() +
                                                    (hightExludingAppbar < 598
                                                        ? 5
                                                        : 20),
                                                minRadius: minRedius
                                                        .toDouble() +
                                                    (hightExludingAppbar < 598
                                                        ? 5
                                                        : 20),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: Text(
                                                    mediaItem !=null ?
                                                    mediaItem.extras['lyrics']:"No Audio is Beign Played",
                                                    textAlign: TextAlign.center,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    textScaleFactor: 1.1,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )),
                                            crossFadeState: showLyrics
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                            duration: Duration(seconds: 1)),
                                      )))),
                                  Container(
                                      margin: EdgeInsets.only(
                                          bottom: virticalMarginBetweenControls
                                              .toDouble()),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(bottom: 15),
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
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ],
                                      )),
                                  if (basicState != BasicPlaybackState.none &&
                                      basicState !=
                                          BasicPlaybackState.stopped) ...[
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child:
                                          positionIndicator(mediaItem, state),
                                    )
                                  ],
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom: virticalMarginBetweenControls
                                            .toDouble()),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        isLikedSong == true
                                            ? IconButton(
                                                icon: Icon(
                                                  EvaIcons.heart,
                                                  size: 35,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    addInLikedSong(0))
                                            : IconButton(
                                                icon: Icon(
                                                  EvaIcons.heartOutline,
                                                  size: 35,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () =>
                                                    addInLikedSong(1)),
                                        IconButton(
                                            icon: Icon(Icons.featured_play_list,
                                                color: Colors.white, size: 35),
                                            onPressed: () =>
                                                Navigator.pushNamed(context,
                                                    CurrentPlaylistRoute)),
                                        isDownloading
                                            ? CircularProgressIndicator()
                                            :mediaItem!=null &&  mediaItem.extras[
                                                        "isDownloaded"] ==
                                                    "false"
                                                ? IconButton(
                                                    icon: SvgPicture.asset(
                                                      'assets/down-group2.svg',
                                                      color: Colors.white,
                                                      width: 60,
                                                      height: 60,
                                                    ),
                                                    onPressed: () =>
                                                        addtoDownload(context))
                                                : IconButton(
                                                    icon: Icon(EvaIcons
                                                        .checkmarkCircleOutline),
                                                    onPressed: null),
                                      ],
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Flex(
                                        mainAxisSize: MainAxisSize.min,
                                        direction: Axis.horizontal,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
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
                                          if (basicState ==
                                              BasicPlaybackState.none) ...[
                                            startButton(),
                                          ] else if (basicState ==
                                                  BasicPlaybackState.playing ||
                                              basicState ==
                                                  BasicPlaybackState
                                                      .buffering) ...[
                                            pauseButton(),
                                          ] else if (basicState ==
                                              BasicPlaybackState.paused) ...[
                                            playButton(),
                                          ] else if (basicState ==
                                              BasicPlaybackState
                                                  .connecting) ...[
                                            CircularProgressIndicator()
                                          ] else if (basicState ==
                                                  BasicPlaybackState
                                                      .skippingToNext ||
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
                                                  _myService
                                                      .startAudioService();
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
                                      )),
                                ],
                              ));
                            } else {
                              return Center(
                                  child: Text('No media is currently Playing'));
                            }
                          }))
                ])));
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
              children: <Widget>[
                Text("$twoDigitMinutess:$twoDigitSecondss"),
                Container(
                  width: MediaQuery.of(context).size.width - 110,
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
          Icons.play_circle_filled,
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
        child: SvgPicture.asset(
          'assets/play-button.svg',
          color: Colors.white,
          width: 60,
          height: 60,
        ),
        onTap: AudioService.play,
      );

  GestureDetector pauseButton() => GestureDetector(
        child: SvgPicture.asset(
          'assets/pause(1).svg',
          color: Colors.white,
          width: 60,
          height: 60,
        ),
        onTap: AudioService.pause,
      );

  GestureDetector stopButton() => GestureDetector(
        child: Icon(
          EvaIcons.stopCircleOutline,
          size: 60,
        ),
        onTap: AudioService.stop,
      );

  getArt(MediaItem mediaItem, int minRedius, int maxRedius) {
    if (mediaItem != null && mediaItem.artUri != null) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          mediaItem.artUri.split("?")[0]!=""?mediaItem.artUri.split("?")[0]:mediaItem.artUri
        ),
        backgroundColor: colors,
        foregroundColor: colors,
        maxRadius: maxRedius.toDouble() + 5,
        minRadius: minRedius.toDouble() + 5,
      );
    } else {
      return Image.network(
        'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg?auto=format&q=60&fit=max&w=930',
        fit: BoxFit.fitWidth,
      );
    }
  }

  isInLikedSong(String youtubeUrl) async {
    var val = await DBProvider.db.isLikedSOng(youtubeUrl);
    if (mounted) {
      setState(() {
        isLikedSong = val;
      });
    }
  }

  isInDownloadSongs(String youtubeUrl) async {
    var val = await DBProvider.db.isLikedSOng(youtubeUrl);
    if (mounted) {
      setState(() {
        isLikedSong = val;
      });
    }
  }

  addInLikedSong(removeOrAdd) async {
    if (removeOrAdd == 1) {
      var song = Song(
          AudioService.currentMediaItem.title,
          " ",
          AudioService.currentMediaItem.extras['youtubeUrl'],
          "",
          false,
          AudioService.currentMediaItem.artUri);
      await DBProvider.db.addToLikedSongs(song, null);
      isInLikedSong(AudioService.currentMediaItem.extras['youtubeUrl']);
    } else if (removeOrAdd == 0) {
      await DBProvider.db.removeSongFromPlaylist(
          AudioService.currentMediaItem.extras['youtubeUrl'], 1.toString());
      await isInLikedSong(AudioService.currentMediaItem.extras['youtubeUrl']);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

addtoDownload(context) async {
  var song = Song(
      AudioService.currentMediaItem.title,
      " ",
      AudioService.currentMediaItem.extras['youtubeUrl'],
      "",
      false,
      AudioService.currentMediaItem.artUri);
  if (AudioService.currentMediaItem.album == "Searched Songs") {
    await DBProvider.db.addSongtoDb(song);
  }
  var va = await _myService.addToDownload(song.youtubeUrl);
  if (va) {
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text("${song.title} is added DownloadQueue Keep Calm ")));
  } else {
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(
              "${song.title} is Either in DownloadQueue or already Downnloaded ")));
  }
}
