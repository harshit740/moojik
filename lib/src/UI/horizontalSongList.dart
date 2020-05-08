import 'package:flutter/material.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moojik/src/services/MusicHelperService.dart';
import 'package:moojik/src/services/BaseService.dart';

class HorizontalSongList extends StatelessWidget {
  final List<Song> songs;
  final parentWidgetName;
  final AudioFun _myService = locator<BaseService>();

  HorizontalSongList({Key key, this.songs, this.parentWidgetName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return songs.length > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return Column(children: <Widget>[
                InkWell(
                    splashColor: Colors.white,
                    onTap: () =>
                        _myService.playOneSong(songs[index], parentWidgetName),
                    child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 70,
                        child: songs[index].thumbnailUrl != null
                            ? CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.audiotrack,
                            color: Colors.white,
                            size: 50,
                          ),
                          backgroundImage: CachedNetworkImageProvider(
                              songs[index].thumbnailUrl),
                        )
                            : Icon(
                          Icons.audiotrack,
                          color: Colors.white,
                          size: 50,
                        ))),
                Container(child: Text(songs[index].title,maxLines: 3),width: 110,)
              ],);
            },
            scrollDirection: Axis.horizontal,
          )
        : Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.hourglass_empty), Text("Empty")],
            ),
          );
  }
}

/**
 *Align(
    alignment: Alignment.center,
    child: CircleAvatar(
    radius: 80.0,
    backgroundImage:
    CachedNetworkImageProvider(songs[index].thumbnailUrl)),
    );
 */
