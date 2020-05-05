import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

getSongLyrics(String name) async {
  name = name.toLowerCase();
  name = name.replaceAll("official", "").replaceAll("music", "").replaceAll("video", "").replaceAll("new", "").replaceAll("song", "");
  name = name.replaceAll(RegExp("\\(\\[?[Ll]yrics?\\)]?\\s?([Vv]ideo)?\\)?"), "");
  name = name.replaceAll(RegExp("\\(?[aA]udio\\)?\\s"), "");
  name = name.replaceAll(RegExp("\\[Lyrics?]"), "");
  name = name.replaceAll(RegExp("\\(Official\\sMusic\\sVideo\\)"), "");
  name = name.replaceAll(RegExp("\\[HD\\s&\\sHQ]"), "");
  name = name.replaceAll("|", " ");
  name = name.split("(",)[0];
  print("Query =$name");
  var url = 'https://www.google.com/search?q=$name+ lyrics';
  Map<String, String> headers = {
    "user-agent":
    "Mozilla/5.0 (Linux; U; Tizen 2.0; en-us) AppleWebKit/537.1 (KHTML, like Gecko) Mobile TizenBrowser/2.0"
  };
  var response = await http.get(url,headers: headers);
  dom.Document document =  parser.parse(response.body);
  try{
  var lyrics = document.querySelectorAll('div.hwc');
  return lyrics.first.children.first.children.first.children.first.innerHtml;
  }
  catch(e){
    return "Lyrics NotFound try typing the song name mannualy";
  }
}
