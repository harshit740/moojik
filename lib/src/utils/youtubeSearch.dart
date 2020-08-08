import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moojik/src/utils/serilizeSongs.dart';

searchYoutube(query) async {
  Map<String, String> headers = {"user-agent": "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko; googleweblight) Chrome/38.0.1025.166 Mobile Safari/535.19"};
  var url = 'https://m.youtube.com/results?search_query=$query';
  var response = await http.get(url, headers: headers);

  return compute(parseVideo, response.body);
}
