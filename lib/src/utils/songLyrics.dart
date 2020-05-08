import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:moojik/src/utils/checkConnectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

getSongLyrics(String name, String youtubeUrl) async {
  final prefs = await SharedPreferences.getInstance();
  var lyrics = prefs.getString("$youtubeUrl&Lyrics");
  if (lyrics != null) {
    return lyrics;
  } else {
    if (await checkConnectivity()) {
      name = name
          .toLowerCase()
          .substring(0, name.length > 35 ? 35 : name.length - 1);
      name = name
          .replaceAll("official", "")
          .replaceAll("music", "")
          .replaceAll("video", "")
          .replaceAll("new", "")
          .replaceAll("song", "")
          .replaceAll(":", "");
      name = name
          .replaceAll("lyrics", "")
          .replaceAll("audio", "")
          .replaceAll("hd", "")
          .replaceAll("hq", "")
          .replaceAll("|", " ");
      name = name.split(
        "(",
      )[0];
      print("Query =$name lyrics");
      var url = 'https://www.google.com/search?q=$name lyrics';
      Map<String, String> headers = {
        "user-agent":
            "Mozilla/5.0 (Linux; U; Tizen 2.0; en-us) AppleWebKit/537.1 (KHTML, like Gecko) Mobile TizenBrowser/2.0"
      };
      var response = await http.get(url, headers: headers);
      dom.Document document = parser.parse(response.body);
      try {
        var lyrics = document.querySelectorAll('div.hwc');
        prefs.setString(
            "$youtubeUrl&Lyrics",
            lyrics
                .first.children.first.children.first.children.first.innerHtml);
        return lyrics
            .first.children.first.children.first.children.first.innerHtml;
      } catch (e) {
        return "Lyrics NotFound try typing the song name mannualy";
      }
    } else {
      return "You Are Not Connected to internet";
    }
  }
}
