import 'package:moojik/service_locator.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/utils/checkConnectivity.dart';
import 'package:moojik/src/utils/youtubeSearch.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:moojik/src/services/MusicHelperService.dart';
import 'package:moojik/src/services/BaseService.dart';
class SearchBloc {
  AudioFun _myService = locator<BaseService>();

  //Extended Object cause we can't add Mixing without inheritance
  //Controler
  final _searchterm = BehaviorSubject<String>(); //searchterm StreamController
  final _songs = BehaviorSubject<List<Song>>(); //searchterm StreamController
  final _isSearching = BehaviorSubject<bool>(); //searchterm StreamController

  //feeding data
  get changesearchTerm => _searchterm.sink.add;
  get addSongs => _songs.sink.add;
  get trigerSearching => _isSearching.sink.add;
  //output data
  Stream<String> get searchterm => _searchterm.stream;
  Stream<List<Song>> get songs => _songs.asBroadcastStream();
  Stream<bool> get issearching => _isSearching.stream;

  dispose() {
    _searchterm.close();
    _isSearching.close();
    _songs.close();
  }

  void search(String value) async {
    if(await checkConnectivity()){
    trigerSearching(true);
    _myService.searchSongs(value);
   // this._songs.sink.add(await searchYoutube(value));

    }else{

    }
  }
}

final SearchBloc searchBlox = SearchBloc();
