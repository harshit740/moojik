import 'dart:async';

import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/utils/trendingSongs.dart';
import 'package:rxdart/rxdart.dart';

class TrendingBloc {
  TrendingBloc() {
    triggerTrendingSOngs();
  }

  final _tredingSongs = BehaviorSubject<List<Song>>(); //downloading StreamController
  get addTrendingSongs => _tredingSongs.sink.add; //change state here
  Stream<List<Song>> get getTrendingSongs => _tredingSongs.stream;

  triggerTrendingSOngs() async {
    print("Triggerd Tresnding");
    trendingSongs();
  }
}

final TrendingBloc trendingBloc = TrendingBloc();
