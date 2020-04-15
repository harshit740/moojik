import 'package:audio_service/audio_service.dart';
import 'package:moojik/src/UI/songList.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../service_locator.dart';
import '../Database.dart';

class PlayListDetailView extends StatelessWidget {
  final PlayList playlistItem;
  List<Song> songs;
  AudioFun _myService = locator<BaseService>();

  PlayListDetailView({Key key, this.playlistItem}) : super(key: key) {}
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
                child: RaisedButton(
              onPressed: () => playtheList(),
              child: Text("Play"),
              textColor: Colors.white,
              colorBrightness: Brightness.dark,
              elevation: 120,
              padding: EdgeInsets.only(left: 10, right: 10),
              textTheme: ButtonTextTheme.accent,
            )),
            FutureBuilder<List<Song>>(
                future: DBProvider.db.getPlayList(playlistItem.playlistid),
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

  playtheList() async {
    if (songs.length > 0) {
      if (!AudioService.running) {
        await _myService.startAudioService();
      }
      songs.forEach((f) async {
        AudioService.addQueueItem(MediaItem(
            id: f.youtubeUrl,
            album: playlistItem.title,
            title: f.title,
            displayTitle: f.title,
            displaySubtitle: f.title,
            artUri: "",
            extras: {"youtubeUrl": f.youtubeUrl}));
      });
      // await AudioService.addQueue(items);
      await AudioService.skipToNext();
    }
  }
}
