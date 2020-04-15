import 'package:rxdart/rxdart.dart';
import 'dart:async';

class PlayerBlock {
  PlayerBlock() {
    isYOutubeLenkGetting.listen((onData) {
    });
  }

  final _isGettingYoutubeList = BehaviorSubject<bool>(); //searchterm StreamController
  get triggerYoutubeLenkGetting =>
      _isGettingYoutubeList.sink.add; //searchterm StreamController
  Stream<bool> get isYOutubeLenkGetting => _isGettingYoutubeList.stream;

  triggerYOutube(bool data) {
    triggerYoutubeLenkGetting(data);
  }
}

final PlayerBlock playerStates = PlayerBlock();
