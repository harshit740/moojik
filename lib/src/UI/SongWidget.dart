import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moojik/routing_constants.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/UI/addSongtoPlaylist.dart';
import 'package:moojik/src/UI/newPlaylistDialog.dart';
import 'package:moojik/src/bloc/playerBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';

_navigateAndaddToPlayList(Song song, BuildContext context) async {
  final String playlistID = await displayAddtoDialog(context);
  if (playlistID == 'CreatePlayList') {
    final String playlistname = await displayDialog(context);
    if (playlistname != null) {
      await DBProvider.db.createPlaylist(playlistname);
      final String playlistID = await displayAddtoDialog(context);
      await DBProvider.db.addToLikedSongs(song, playlistID);
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("${song.title} is added to the Playlist")));
    }
  } else if (playlistID == null) {
    return;
  } else {
    await DBProvider.db.addToLikedSongs(song, playlistID);
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text("${song.title} is added to the Playlist")));
  }
}

class SongWidget extends StatefulWidget {
  final Song song;
  final parentWidgetName;

  SongWidget({Key key, this.song, this.parentWidgetName}) : super(key: key);

  @override
  _SongWidgetState createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  AudioFun _myService = locator<BaseService>();

  bool isAdding = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(widget.song.youtubeUrl.contains("?v=")){
    playerStates.isDownloading.listen((onData) {
      if (mounted) {
        if (_myService.downloadQueue
            .containsKey(widget.song.youtubeUrl.split("?v=")[1])) {
          setState(() {
            isDownloading = _myService
                .downloadQueue[widget.song.youtubeUrl.split("?v=")[1]];
          });
          if (!_myService
              .downloadQueue[widget.song.youtubeUrl.split("?v=")[1]]) {
            widget.song.isDownloaded = true;
          }
        }
      }
    });}
  }

  addToLikedSongs(song, context) {
    DBProvider.db.addToLikedSongs(song, 1);
    final snackBar = SnackBar(content: Text('Added to Liked SOong'));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  addToPlayList(Song song, context) async {
    if (song.title.contains("- Playlist") ||
        widget.song.youtubeUrl.contains('&list=')) {
      setState(() {
        isAdding = true;
      });
      await DBProvider.db
          .addYoutubePlaylistToDb(PlayList(song.youtubeUrl, song.title.trim()));
      setState(() {
        isAdding = false;
      });
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
              "${song.title} is added to the Playlist",
            ),
            duration: Duration(seconds: 2)));
    } else {
      _navigateAndaddToPlayList(song, context);
    }
  }

  Widget getIcon(title) {
    if (widget.song.title.contains('- Channel')) {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.account_circle),
      );
    } else if (widget.song.title.contains('- Playlist') ||
        widget.song.youtubeUrl.contains('&list=')) {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.playlist_play),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.audiotrack),
      );
    }
  }

  getAddtoLikeIcon(song, context) {
    if (this.widget.parentWidgetName == 'Searched Songs' ||
        widget.parentWidgetName.toString().split("&=")[1] == "All") {
      if (isAdding) {
        return CircularProgressIndicator();
      } else if (!song.title.contains('- Channel')) {
        return GestureDetector(
            onTap: () => addToPlayList(song, context),
            child: Icon(Icons.library_add));
      } else {
        return Divider();
      }
    } else {
      return Divider();
    }
  }

  getDownloadIcon() {
    if (!widget.song.isDownloaded) {
      if (isDownloading) {
        return CircularProgressIndicator();
      } else
        return GestureDetector(
          child: Icon(
            Icons.file_download,
            size: 40,
          ),
          onTap: () async {
            _myService.addToDownload(widget.song.youtubeUrl);
          },
        );
    } else {
      return Divider();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15.0),
        child: InkWell(

            onTap: () {
              if (widget.song.title.contains("- Playlist")||
                  widget.song.youtubeUrl.contains('&list=')) {
                Navigator.pushNamed(context, PlayListDetailRoute,
                    arguments:
                        PlayList(widget.song.youtubeUrl, widget.song.title));
              } else {
                if (widget.parentWidgetName.toString().contains("&=1")) {
                  _myService.playOneSong(widget.song,
                      widget.parentWidgetName.toString().split("&=")[0]);
                } else {
                  _myService.playOneSong(widget.song, widget.parentWidgetName);
                }
              }
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  getIcon(widget.song.title),
                  Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        "${widget.song.title}",
                      )),
                  widget.parentWidgetName != "Searched Songs"
                      ? getDownloadIcon()
                      : Divider(),
                  Column(
                    children: <Widget>[getAddtoLikeIcon(widget.song, context)],
                  )
                ])));
  }
}
