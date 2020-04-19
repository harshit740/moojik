import 'package:audio_service/audio_service.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'SongWidget.dart';

class SongList extends StatelessWidget {
  final List<Song> playList;
  var _myService = locator<BaseService>();
  SongList({Key key, this.playList}) : super(key: key);
  var currentIndex;
  var currentSong;
  BuildContext context;
  @override
  Widget build(BuildContext context) {
    this.context = context;
    return StreamBuilder(
        stream: AudioService.currentMediaItemStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
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
        });
  }
}
