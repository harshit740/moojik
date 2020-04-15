import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
Map<String, String> headers = {"user-agent": "fdsfds"};
getYoutubeLink(String link) async {
  print("YOutube URL ${link.split('/watch?v=')}");
  var url =
      'https://freemp3downloads.online/download?url=${link.split('/watch?v=')[1]}';
  var response = await http.get(url,headers: headers);
  dom.Document document = parser.parse(response.body);
  
  var thumbnail = document.querySelector('img.figure-img');
  var youtubelenked = document.getElementById('collapseAudio4');
  var youtubelenk = youtubelenked.getElementsByTagName('a');
  List song = [];
  song[1] = youtubelenk[0].attributes['href'];
  song[2] = thumbnail.attributes['src'];
  return song;
}

