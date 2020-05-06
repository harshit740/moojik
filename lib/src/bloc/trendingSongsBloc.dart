import 'dart:async';

import 'package:moojik/src/bloc/bloc.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/utils/trendingSongs.dart';
import 'package:rxdart/rxdart.dart';

class TrendingBloc extends Bloc{
  TrendingBloc() {
    triggerTrendingSOngs();
  }

  final _tredingSongs = BehaviorSubject<List<Song>>(); //downloading StreamController
  get addTrendingSongs => _tredingSongs.sink.add; //change state here
  Stream<List<Song>> get getTrendingSongs => _tredingSongs.stream;

  triggerTrendingSOngs() async {
    trendingSongs();
  }

  @override
  void dispose() {
    _tredingSongs.close();
  }
}

final TrendingBloc trendingBloc = TrendingBloc();
