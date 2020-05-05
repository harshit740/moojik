import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moojik/src/utils/serilizeSongs.dart';

searchYoutube(query) async {
  Map<String, String> headers = {"user-agent": "fdsfds"};
  var url = 'https://m.youtube.com/results?search_query=$query';
  var response = await http.get(url, headers: headers);
  return compute(parseVideo, response.body);
}
