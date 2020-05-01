import 'package:audio_service/audio_service.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:flutter/material.dart';
import 'SongWidget.dart';

class SongList extends StatelessWidget {
  final List<Song> playList;

  SongList({Key key, this.playList}) : super(key: key);
  var currentIndex;
  var currentSong;
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    debugPrint("PlayListCurent vidsfsd ${playList.isEmpty}");
    return StreamBuilder<List<MediaItem>>(
        stream: playList.isEmpty ? AudioService.queueStream : null,
        builder: (context, snapshot) {
          if (playList.isNotEmpty) {
            return ListView.builder(
                itemCount: playList.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext ctxt, int index) {
                  return InkWell(
                    child: SongWidget(
                      song: playList[index],
                      parentWIdgetname: 'PlayListSongList',
                    ),
                  );
                });
          } else if(snapshot.hasData) {
            debugPrint("called ${snapshot.data} ${AudioService.queue}");
            return ListView.builder(
                itemCount: snapshot.data.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext ctxt, int index) {
                  return InkWell(
                    child: SongWidget(
                      song:  Song(
                          snapshot.data[index].title,
                          " ",
                          snapshot.data[index].extras['youtubeUrl'],
                          "",
                          snapshot.data[index].extras['isDownloaded'],
                          snapshot.data[index].artUri),
                      parentWIdgetname: 'PlayListSongList',
                    ),
                  );
                });
          }else{
            return Icon(Icons.check);
          }
        });
  }
}
