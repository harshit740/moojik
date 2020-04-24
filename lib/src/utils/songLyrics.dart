import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

getSongLyrics(query) async {
  print("query = $query lyrics");
  var url = 'https://www.google.com/search?q=$query+ lyrics';
  Map<String, String> headers = {
    "user-agent":
    "Mozilla/5.0 (Linux; U; Tizen 2.0; en-us) AppleWebKit/537.1 (KHTML, like Gecko) Mobile TizenBrowser/2.0"
  };
  var response = await http.get(url,headers: headers);
  dom.Document document =  parser.parse(response.body);
  var lyrics = document.querySelectorAll('div.hwc');
  return lyrics.first.children.first.children.first.children.first.innerHtml;
}
