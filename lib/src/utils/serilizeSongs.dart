import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:moojik/src/models/SongMode.dart';

List<Song> parseVideo(response) {
  dom.Document document = parser.parse(response);
  var videos = document.querySelectorAll('h3.yt-lockup-title');
  var thumbnail = document.querySelectorAll('span.yt-thumb-simple');
  List<Song> youtubeVideolinkMap = [];
  print(videos);
  videos.asMap().forEach((index, f) {
    var link = f.getElementsByTagName('a');
    Song newSong = Song(
        f.text,
        "desc",
        link[0].attributes['href'],
        "localUrl",
        false,
        thumbnail[index].children.first.attributes['data-thumb'] != null
            ? thumbnail[index].children.first.attributes['data-thumb']
            : thumbnail[index].children.first.attributes['src']);
    youtubeVideolinkMap.add(newSong);
  });
  return youtubeVideolinkMap;
}