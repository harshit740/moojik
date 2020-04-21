import 'package:flutter/services.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/UI/addSongtoPlaylist.dart';
import 'package:moojik/src/UI/newPlaylistDialog.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moojik/src/Database.dart';

_navigateAndaddToPlayList(Song song, BuildContext context) async {
  final String playlistID = await displayAddtoDialog(context);
  if (playlistID == 'CreatePlayList') {
    final String playlistname = await displayDialog(context);
    if (playlistname != null) {
      await DBProvider.db.createPlaylist(playlistname);
      final String playlistID = await displayAddtoDialog(context);
      await DBProvider.db.addToLikedSOngs(song, playlistID);
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("${song.title} is added to the Playlist")));
    }
  } else if (playlistID == null) {
    return;
  } else {
    await DBProvider.db.addToLikedSOngs(song, playlistID);
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text("${song.title} is added to the Playlist")));
  }
}

class SongWidget extends StatelessWidget {
  AudioFun _myService = locator<BaseService>();
  final channel = MethodChannel("com.moojikflux/music");
  final Song song;
  final parentWIdgetname;
  addtoLikedSongs(song, context) {
    DBProvider.db.addToLikedSOngs(song, 1);
    final snackBar = SnackBar(content: Text('Added to Liked SOong'));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  addToPlayList(song, context) {
    _navigateAndaddToPlayList(song, context);
  }

  SongWidget({Key key, this.song, this.parentWIdgetname}) : super(key: key);
  Widget getIcon(title) {
    if (song.title.contains('- Channel')) {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.account_circle),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.audiotrack),
      );
    }
  }

  getAddtoLikeIcon(song, context) {
    if (this.parentWIdgetname == 'Searched Songs') {
      return GestureDetector(
          onTap: () => addToPlayList(song, context),
          child: Icon(Icons.library_add));
    } else if (this.parentWIdgetname == 'PlayListSongList') {
      return GestureDetector(
          //  onTap: () => addtoLikedSongs(song, context),
          child: Icon(Icons.remove_from_queue));
    }
  }

  getDownloadIcon() {
    if (song.isDownloaded) {
      return GestureDetector(child: Icon(Icons.remove_circle_outline));
    } else {
      return GestureDetector(
        child: Icon(
          Icons.file_download,
          size: 40,
        ),
        onTap: () async {
          await channel.invokeMethod(
              "addToDownloadQueue", song.youtubeUrl.split("/watch?v=")[1]);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15.0),
        child: InkWell(
            onTap: () => _myService.playOneSong(song, parentWIdgetname),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  getIcon(song.title),
                  Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        "${song.title}",
                      )),
                 parentWIdgetname != "Searched Songs"?getDownloadIcon():Divider(),
                  Column(
                    children: <Widget>[getAddtoLikeIcon(song, context)],
                  )
                ])));
  }
}
