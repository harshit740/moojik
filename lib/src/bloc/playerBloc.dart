import 'dart:async';

import 'package:rxdart/rxdart.dart';

class PlayerBlock {
  PlayerBlock() {
    _isDownloading.listen((onData) {
      print("$onData");
    });
  }

  final _isDownloading = BehaviorSubject<List<Map<String,dynamic>>>(); //downloading StreamController
  get triggerIsDownloading => _isDownloading.sink.add; //change state here
  Stream<List<Map<String,dynamic>>> get isDownloading => _isDownloading.stream;

  triggerDownload(List<Map<String,dynamic>> data) {
    triggerIsDownloading(data);
  }
}

final PlayerBlock playerStates = PlayerBlock();
