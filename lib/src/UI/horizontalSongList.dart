import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HorizontalSongList extends StatelessWidget {
  final List<Song> songs;

  const HorizontalSongList({Key key, this.songs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context, index) {
          return CircleAvatar(radius: 70,child: CircleAvatar(
              radius: 70,
              backgroundImage: CachedNetworkImageProvider(
                  songs[index].thumbnailUrl),),);
        },
        scrollDirection: Axis.horizontal,
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
