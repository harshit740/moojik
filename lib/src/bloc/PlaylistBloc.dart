import 'package:moojik/src/Database.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:rxdart/rxdart.dart';

class PlayListBloc {
  //searchterm StreamControlle
  PlayListBloc() {
    print("object");
    this.gettAllPlaylistStream();
  }
  final _playLists = BehaviorSubject<List<PlayList>>();
  //final _isFetching = BehaviorSubject<bool>(); //searchterm StreamController

  // //feeding data
  get addPlayLists => _playLists.sink.add;
  //get trigerFetching => _isFetching.sink.add;
  //output data
  Stream<List<PlayList>> get playListsStream => _playLists.asBroadcastStream();
 // Stream<bool> get isFetching => _isFetching.stream;

  void gettAllPlaylistStream() async {
  //  trigerFetching(true);
    this.addPlayLists(await DBProvider.db.getAllPlayList());
  //  trigerFetching(false);
  }

  void addoneplayList(PlayList onelist) async {}

  void delete(playlistID) {
    DBProvider.db.deletePlayList(playlistID);
    gettAllPlaylistStream();
  }
}

final PlayListBloc playListBloc = PlayListBloc();
