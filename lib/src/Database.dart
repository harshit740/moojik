import 'dart:io';

import 'package:moojik/src/bloc/PlaylistBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/src/utils/youtubePlaylist.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
          "CREATE TABLE songs (songid INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT,desc TEXT,youtubeUrl TEXT UNIQUE,localUrl TEXT,isDownloaded boolean,thumbnailUrl TEXT,lastPlayedOn DATETIME)");
      await db.execute(
          "CREATE TABLE playlists (playlistid INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT)");
      await db.execute(
          "CREATE TABLE playlists_songs (id INTEGER PRIMARY KEY AUTOINCREMENT,song_id INTEGER,playlist_id INTEGER, FOREIGN KEY (song_id) REFERENCES songs(songid) , FOREIGN KEY (playlist_id)  REFERENCES playlists(playlistid)) ");
      await db.rawInsert("INSERT into playlists (title) values('Liked Songs')");
    });
  }

  Future<int> getSongId(String youtubeUrl) async {
    try {
      final db = await database;
      var songId = await db.rawQuery(
          "select songid from songs where youtubeUrl = '$youtubeUrl'");
      return songId[0]['songid'];
    } catch (e) {
      print(e);
      return e;
    }
  }

  addSongtoDb(Song song) async {
    final db = await database;
    try {
      var res = await db.rawInsert(
          "INSERT Into Songs (title,desc,youtubeUrl,localUrl,isDownloaded,thumbnailUrl) VALUES ('${song.title.replaceAll("'","")}','${song.desc}','${song.youtubeUrl}','${song.localUrl}','${song.isDownloaded}','${song.thumbnailUrl}')");
      return res;
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed:')) {
        var res = await db.rawQuery(
            "select songid from Songs where youtubeUrl = '${song.youtubeUrl}'");
        return res[0]['songid'];
      }
      return e;
    }
  }

  addToLikedSongs(song, playlistID) async {
    try {
      var songId = await addSongtoDb(song);
      if (playlistID == null) {
        await addToPlayList(songId, 1);
      } else {
        await addToPlayList(songId, playlistID);
      }
    } catch (e) {}
  }

  isLikedSOng(String youtubeUrl) async {
    try {
      final db = await database;
      var songId = await getSongId(youtubeUrl);
      var isExist = await db.rawQuery(
          "SELECT id FROM playlists_songs WHERE song_id=$songId and  playlist_id = 1");
      if (isExist.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }
  }

  isInDownloadedSong(String youtubeUrl) async {
    try {
      final db = await database;
      var isInDownloaded = await db.rawQuery(
          "SELECT isDownloaded,localUrl FROM Songs WHERE youtubeUrl='$youtubeUrl'");
      print("isInDownloadedSong $isInDownloaded");
      List list;
      if (isInDownloaded.isNotEmpty) {
        list = [
          getBool(isInDownloaded.first['isDownloaded']),
          getBool(isInDownloaded.first['isDownloaded'])
              ? isInDownloaded.first['localUrl']
              : youtubeUrl
        ];
        return list;
      } else {
        list = [false, youtubeUrl];
        return list;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<PlayList>> getAllPlayList() async {
    final db = await database;
    List<dynamic> res = await db.rawQuery('select * from playlists');
    List<PlayList> p = [];
    p.add(PlayList('All', "All Songs"));
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

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM  songs");
    List<Song> sungs = [];
    res.forEach((f) {
      sungs.add(Song(f['title'], f['desc'], f['youtubeUrl'], f['localUrl'],
          getBool(f['isDownloaded']), f['thumbnailUrl']));
    });
    return sungs;
  }

  Future<List<Song>> getPlayList(playlistId) async {
    try {
      if (playlistId == 'All') {
        return getAllSongs();
      } else {
        final db = await database;
        var res = await db.rawQuery(
            "SELECT * FROM playlists_songs INNER JOIN Songs ON playlists_songs.song_id = SOngs.songid where playlists_songs.playlist_id=$playlistId");
        List<Song> sungs = [];
        res.forEach((f) {
          sungs.add(Song(f['title'], f['desc'], f['youtubeUrl'], f['localUrl'],
              getBool(f['isDownloaded']), f['thumbnailUrl']));
        });
        return sungs;
      }
    } catch (e) {
      print(e);
      return e;
    }
  }

  updateSongToDelted(String youtubeUrl) async {
    try {
      var db = await database;
      var something = await db.rawUpdate(
        "Update Songs set isDownloaded = 0 where youtubeUrl = '$youtubeUrl';",
      );
      return something;
    } catch (e) {}
  }

  addToPlayList(song, playlist) async {
    final db = await database;
    try {
      var res = await db.rawInsert(
          "INSERT Into playlists_songs (playlist_id,song_id) SELECT $playlist ,$song WHERE NOT EXISTS(SELECT * FROM playlists_songs WHERE playlist_id = $playlist AND song_id = $song); ");
      return res;
    } catch (e) {
      print(e);
    }
  }

  deletePlayList(playlistid) async {
    final db = await database;
    await db.delete("playlists_songs",
        where: "playlist_id = ?", whereArgs: [playlistid]);
    await db
        .delete("playlists", where: "playlistid = ?", whereArgs: [playlistid]);
  }

  removeSongFromPlaylist(String youtubeUrl, String playListId) async {
    try {
      final db = await database;
      var songId = await getSongId(youtubeUrl);
      if (playListId == "All") {
        await db.delete("playlists_songs",
            where: "song_id= ?", whereArgs: [songId]);
        await db.delete("songs", where: "songid=?", whereArgs: [songId]);
      } else {
        await db.delete("playlists_songs",
            where: "playlist_id = ? and song_id=?",
            whereArgs: [int.tryParse(playListId), songId]);
      }
    } catch (e) {
      print(e);
    }
  }

  Future addYoutubePlaylistToDb(PlayList playList) async {
    List<Song> songs = await getYoutubePlaylist(playList.playlistid);
    var res = await createPlaylist(playList.title.split("- Playlist")[0]);
    songs.forEach((song) async {
      await addToLikedSongs(song, res.toString());
    });
    playListBloc.gettAllPlaylistStream();
    return res;
  }

  updateLastPlayed(String youtubeUrl) async {
    final db = await database;
    try {
      db.rawUpdate(
          "update songs set lastPlayedOn =  datetime('now') where youtubeUrl = '$youtubeUrl'");
    } catch (e) {
      print(e);
    }
  }

  Future<List<Song>> getLastPlayed() async {
    final db = await database;
    try {
      var res = await db.rawQuery(
          "select * from songs where lastPlayedOn is not null  ORDER BY  lastPlayedOn DESC LIMIT 50");
      List<Song> sungs = [];
      res.forEach((f) {
        sungs.add(Song(f['title'], f['desc'], f['youtubeUrl'], f['localUrl'],
            getBool(f['isDownloaded']), f['thumbnailUrl']));
      });
      return sungs;
    } catch (e) {
      print(e);
      return e;
    }
  }

  //UtilFunction
  getBool(data) {
    data = data.toString();
    if (data.contains("false")) {
      return false;
    } else if (data.contains("1")) {
      return true;
    } else if (data.contains("true")) {
      return true;
    } else if (data.contains("0")) {
      return false;
    } else {
      return false;
    }
  }
}
