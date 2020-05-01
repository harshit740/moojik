import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moojik/routing_constants.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/UI/addSongtoPlaylist.dart';
import 'package:moojik/src/UI/newPlaylistDialog.dart';
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
  final parentWIdgetname;

  SongWidget({Key key, this.song, this.parentWIdgetname}) : super(key: key);

  @override
  _SongWidgetState createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  AudioFun _myService = locator<BaseService>();

  bool isAdding = false;

  addtoLikedSongs(song, context) {
    DBProvider.db.addToLikedSongs(song, 1);
    final snackBar = SnackBar(content: Text('Added to Liked SOong'));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  addToPlayList(Song song, context) async {
    if (song.title.contains("- Playlist")) {
      setState(() {
        isAdding = true;
      });
      await DBProvider.db
          .addYoutubePlaylistToDb(PlayList(song.youtubeUrl, song.title));
      setState(() {
        isAdding = false;
      });
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("${song.title} is added to the Playlist",),duration: Duration(seconds: 2)));
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
    } else if (widget.song.title.contains('- Playlist')) {
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
    if (this.widget.parentWIdgetname == 'Searched Songs') {
      if(isAdding){
        return CircularProgressIndicator();
      }
     else if (!song.title.contains('- Channel')) {
        return GestureDetector(
            onTap: () => addToPlayList(song, context),
            child: Icon(Icons.library_add));
      } else {
        return Icon(Icons.do_not_disturb);
      }
    }else{
      return Divider();
    }
  }

  getDownloadIcon() {
    if (widget.song.isDownloaded) {
      return GestureDetector(child: Icon(Icons.remove_circle_outline));
    } else {
      return GestureDetector(
        child: Icon(
          Icons.file_download,
          size: 40,
        ),
        onTap: () async {
          _myService.addToDownload(widget.song.youtubeUrl);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15.0),
        child: InkWell(
            onTap: () {
              if (widget.song.title.contains("- Playlist")) {
                Navigator.pushNamed(context, PlayListDetailRoute,
                    arguments: PlayList(widget.song.youtubeUrl, widget.song.title));
              } else {
                _myService.playOneSong(widget.song, widget.parentWIdgetname);
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
                  widget.parentWIdgetname != "Searched Songs"
                      ? getDownloadIcon()
                      : Divider(),
                  Column(
                    children: <Widget>[getAddtoLikeIcon(widget.song, context)],
                  )
                ])));
  }
}
