import 'package:flutter/material.dart';
import 'package:moojik/src/UI/songList.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/services/AudioFun.dart';
import 'package:moojik/src/services/BaseService.dart';

import '../../service_locator.dart';

class CurrentPlaylistView extends StatelessWidget {
 final List<Song>  playlistItem = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SongList(playList: playlistItem,));
  }
}
