import 'package:flutter/material.dart';
import 'package:moojik/src/services/BaseService.dart';
import 'package:moojik/src/services/MusicHelperService.dart';

import '../../service_locator.dart';

class SongDetailedView extends StatelessWidget {
  final String songYoutubeUrl;
  final AudioFun _myService = locator<BaseService>();

  SongDetailedView({Key key, this.songYoutubeUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xFF000B1C), appBar: AppBar(title: Text("So  ngDetailes"),));
  }
}
