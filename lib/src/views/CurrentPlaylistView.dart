import 'package:flutter/material.dart';
import 'package:moojik/src/UI/songList.dart';
import 'package:moojik/src/models/SongMode.dart';

class CurrentPlaylistView extends StatelessWidget {
 final List<Song>  playlistItem = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SongList(playList: playlistItem,));
  }
}
