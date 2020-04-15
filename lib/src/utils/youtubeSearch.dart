import 'package:moojik/src/models/SongMode.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

List<Song> parseVideo(response) {
  dom.Document document = parser.parse(response);
  var videos = document.querySelectorAll('h3.yt-lockup-title');
  //var channels = document.getElementsByClassName('yt-uix-sessionlink spf-link');
  List<Song> youtubeVideolinkMap = [];
  videos.forEach((f) {
    var link = f.getElementsByTagName('a');
    Song newSong = Song(f.text, "desc", link[0].attributes['href'], "localUrl",
        false, 'thumbnail');
    youtubeVideolinkMap.add(newSong);
  });
  return youtubeVideolinkMap;
}

searchYoutube(query) async {
  Map<String, String> headers = {"user-agent": "fdsfds"};
  var url = 'https://m.youtube.com/results?search_query=$query';
  var response = await http.get(url, headers: headers);
  return compute(parseVideo, response.body);
}
