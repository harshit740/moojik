import 'package:moojik/src/views/CurrentPlaylistView.dart';
import 'package:moojik/src/views/PlayListDetailView.dart';
import 'package:moojik/src/views/PlayerView.dart';
import 'package:flutter/material.dart';
import './src/views/HomeView.dart';

import './routing_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => HomeView());
    case PlayListDetailRoute:
       var detailArgument = settings.arguments;
      print(settings.arguments);
      return MaterialPageRoute( builder: (context) => PlayListDetailView(playlistItem: detailArgument));
    case PlayerViewRoute:
      return MaterialPageRoute(
          builder: (context) => PlayerView());
    case CurrentPlaylistRoute:
      return MaterialPageRoute(
          builder: (context) => CurrentPlaylistView());
    default:
      return MaterialPageRoute(builder: (context) => HomeView());
  }
}
