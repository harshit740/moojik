import 'dart:async';

import 'package:rxdart/rxdart.dart';

class PlayerBlock {
  PlayerBlock() {
    _isDownloading.listen((onData) {
      print("$onData");
    });
  }

  final _isDownloading = BehaviorSubject<Map<String,dynamic>>(); //downloading StreamController
  get triggerIsDownloading => _isDownloading.sink.add; //change state here
  Stream<Map<String,dynamic>> get isDownloading => _isDownloading.stream;

  triggerDownload(Map<String,dynamic> data) {
    triggerIsDownloading(data);
  }
}

final PlayerBlock playerStates = PlayerBlock();
