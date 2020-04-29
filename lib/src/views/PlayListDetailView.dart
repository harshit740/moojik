import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moojik/src/UI/songList.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:moojik/src/utils/youtubePlaylist.dart';

import '../../service_locator.dart';
import '../Database.dart';

class PlayListDetailView extends StatelessWidget {
  final PlayList playlistItem;
  List<Song> songs;
  AudioFun _myService = locator<BaseService>();

  PlayListDetailView({Key key, this.playlistItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            child: Column(
          children: <Widget>[
            Center(
              child: Text(
                playlistItem.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width / 3,
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: () => _myService.playtheList(
                        songs, playlistItem.title, false),
                    child: Text("Play"),
                    textColor: Colors.white,
                    colorBrightness: Brightness.dark,
                    elevation: 120,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    textTheme: ButtonTextTheme.accent,
                  ),
                ),
                ButtonTheme(
                    minWidth: 200,
                    height: 50.0,
                    child: RaisedButton(
                      onPressed: () => _myService.playtheList(
                          songs, playlistItem.title, true),
                      child: Text("ShuffelPlay"),
                      textColor: Colors.white,
                      colorBrightness: Brightness.dark,
                      elevation: 120,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      textTheme: ButtonTextTheme.accent,
                    ))
              ],
            )),
            FutureBuilder<List<Song>>(
                future: playlistItem.playlistid.contains("list=")
                    ? getYoutubePlaylist(playlistItem.playlistid)
                    : DBProvider.db.getPlayList(playlistItem.playlistid),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    this.songs = snapshot.data;
                    return Expanded(
                        child: SongList(
                      playList: snapshot.data,
                    ));
                  } else if (snapshot.hasError == true) {
                    return Center(
                      child: Icon(Icons.error_outline),
                    );
                  } else {
                    return Center(
                      child: Icon(Icons.error),
                    );
                  }
                })
          ],
        )));
  }
}
