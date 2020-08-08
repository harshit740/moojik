import 'package:moojik/src/bloc/trendingSongsBloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moojik/src/utils/serilizeSongs.dart';
import 'package:shared_preferences/shared_preferences.dart';

 trendingSongs() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    List<String> stringList = prefs.getStringList("TrendingPage");
    if (stringList != null &&
        DateTime.now().difference(DateTime.tryParse(stringList[0])).inMinutes <
            5) {
      trendingBloc.addTrendingSongs(await compute(parseVideo, stringList[2]));
    } else {
      if (stringList != null) {
        trendingBloc.addTrendingSongs(await compute(parseVideo, stringList[2]));
      }
      Map<String, String> headers = {"user-agent": "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko; googleweblight) Chrome/38.0.1025.166 Mobile Safari/535.19"};
      var url =
          'https://www.youtube.com/feed/trending?bp=4gIuCggvbS8wNHJsZhIiUExGZ3F1TG5MNTlhbUhuZUdJdnVBQ25XcmhMUHpkMTRRVA%3D%3D';
      var response = await http.get(url, headers: headers);
      List<String> _stringList = [
        DateTime.now().toString(),
        url,
        response.body
      ];
      prefs.setStringList("TrendingPage", _stringList);
      print(_stringList);
      trendingBloc.addTrendingSongs(await compute(parseVideo,response.body));
    }
  } catch (e) {
    print(e);
  }
}
