import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:moojik/src/models/SongMode.dart';

List<Song> parseVideo(response) {
  dom.Document document = parser.parse(response);
  var videos = document.querySelectorAll('a.pl-video-title-link');
  List<Song> youtubeVideodiskMap = [];
  videos.forEach((f) {
    Song newSong = Song(f.text.toString().trim(), "desc", f.attributes['href'].split('&')[0],
        "localUrl", false, 'thumbnail');
    youtubeVideodiskMap.add(newSong);
  });
  return youtubeVideodiskMap;
}

Future<List<Song>> getYoutubePlaylist(String listId) async {
  Map<String, String> headers = {"user-agent": "fdsfds"};
  listId = listId.split("&")[1];
  var url = 'https://www.youtube.com/playlist?$listId';
  print("Listiff = $url");
  var response = await http.get(url, headers: headers);
  return compute(parseVideo, response.body);
}
