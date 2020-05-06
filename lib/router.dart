import 'package:moojik/src/views/CurrentPlaylistView.dart';
import 'package:moojik/src/views/PlayListDetailView.dart';
import 'package:moojik/src/views/PlayerView.dart';
import 'package:flutter/material.dart';
import 'package:moojik/src/views/SettingsView.dart';
import 'package:moojik/src/views/HomeView.dart';

import 'package:moojik/routing_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => HomeView());
    case PlayListDetailRoute:
      var detailArgument = settings.arguments;
      return MaterialPageRoute(
          builder: (context) =>
              PlayListDetailView(playlistItem: detailArgument));
    case PlayerViewRoute:
      return MaterialPageRoute(builder: (context) => PlayerView());
    case CurrentPlaylistRoute:
      return MaterialPageRoute(builder: (context) => CurrentPlaylistView());
    case SettingsRoute:
      return MaterialPageRoute(builder: (context) => SettingsView());
    default:
      return MaterialPageRoute(builder: (context) => HomeView());
  }
}
