import 'dart:io';

import 'package:moojik/src/bloc/PlaylistBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "MoojkFlux.db");

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE songs (songid INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT,desc TEXT,youtubeUrl TEXT UNIQUE,localUrl TEXT,isDownloaded boolean,thumbnailUrl TEXT)");
      await db.execute(
          "CREATE TABLE playlists (playlistid INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT)");
      await db.execute(
          "CREATE TABLE playlists_songs (id INTEGER PRIMARY KEY AUTOINCREMENT,song_id INTEGER,playlist_id INTEGER, FOREIGN KEY (song_id) REFERENCES songs(songid) , FOREIGN KEY (playlist_id)  REFERENCES playlists(playlistid)) ");
      await db.rawInsert("INSERT into playlists (title) values('Liked Songs')");
    });
  }

  addSongtoDb(song) async {
    final db = await database;
    try {
      var res = await db.rawInsert(
          "INSERT Into Songs (title,desc,youtubeUrl,localUrl,isDownloaded,thumbnailUrl) VALUES ('${song.title}','${song.desc}','${song.youtubeUrl}','${song.localUrl}','${song.isDownloaded}','${song.thumbnailUrl}')");
      return res;
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed:')) {
        var res = await db.rawQuery(
            "select songid from Songs where youtubeUrl = '${song.youtubeUrl}'");
        print(res[0]['songid']);
        return res[0]['songid'];
      }
      return e;
    }
  }

  addToLikedSOngs(song, playlistID) async {
    try {
      var sondid = await addSongtoDb(song);
      print("songid $sondid");
      if (playlistID == null) {
        var res = await addToPlayList(sondid, 1);
        print("Liked SOngs res $res");
      } else {
        var res = await addToPlayList(sondid, playlistID);
        print("Playlist SOngs res $res");
      }
    } catch (e) {}
  }

  Future<List<PlayList>> getAllPlayList() async {
    final db = await database;
    List<dynamic> res = await db.rawQuery('select * from playlists');
    List<PlayList> p = [];
    res.forEach((f) {
      var pl = PlayList(f['playlistid'].toString(), f['title']);
      p.add(pl);
    });
    return p;
  }

//PlayList
  Future createPlaylist(String playlistname) async {
    try {
      final db = await database;
      var res = await db
          .rawInsert("insert into playlists (title) values('$playlistname')");
      playListBloc.gettAllPlaylistStream();
      return res;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<List<Song>> getPlayList(playlistId) async {
    try {
      final db = await database;
      var res = await db.rawQuery(
          "SELECT * FROM playlists_songs INNER JOIN Songs ON playlists_songs.song_id = SOngs.songid where playlists_songs.playlist_id=$playlistId");
      List<Song> sungs = [];
      res.forEach((f) {
        sungs.add(Song(f['title'], f['desc'], f['youtubeUrl'], f['localUrl'],
            !f['isDownloaded'].contains('false'), f['thumbnailUrl']));
      });
      return sungs;
    } catch (e) {
      print(e);
      return e;
    }
  }

  addToPlayList(song, playlist) async {
    final db = await database;
    try {
      var res = await db.rawInsert(
          "INSERT Into playlists_songs (playlist_id,song_id) SELECT $playlist ,$song WHERE NOT EXISTS(SELECT * FROM playlists_songs WHERE playlist_id = $playlist AND song_id = $song); ");
      print("res $res");
      return res;
    } catch (e) {
      print(e);
    }
  }

  deletePlayList(playlistid) async {
    final db = await database;
     await db
        .delete("playlists", where: "playlistid = ?", whereArgs: [playlistid]);
  }
}
