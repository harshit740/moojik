import 'package:moojik/routing_constants.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:flutter/material.dart';

class PlaylistItem extends StatelessWidget {
  final PlayList playlistItem;
  Widget getPlayListIcon() {
    return Icon(Icons.playlist_play,size: 25,);
  }

  const PlaylistItem({Key key, this.playlistItem}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: InkWell(
            onTap: () {Navigator.pushNamed(context,PlayListDetailRoute,arguments: playlistItem);},
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
              getPlayListIcon(),
              Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    "${playlistItem.title}",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),
                  )),
            ])));
  }
}
