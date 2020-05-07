import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:path_provider/path_provider.dart';

import 'package:moojik/src/UI/SongWidget.dart';

class SongList extends StatefulWidget {
  final List<Song> playList;
  final PlayList playListItem;

  SongList({Key key, this.playList, this.playListItem}) : super(key: key);

  @override
  _SongListState createState() => _SongListState();
}
class _SongListState extends State<SongList> {
  var currentIndex;
  var currentSong;
  bool isDeleteFromFile = false;
  BuildContext context;


  @override
  Widget build(BuildContext context) {
    this.context = context;
    return StreamBuilder<List<MediaItem>>(
        stream: widget.playList.isEmpty ? AudioService.queueStream : null,
        builder: (context, snapshot) {
          if (widget.playList.isNotEmpty) {
            return ListView.builder(
                padding: EdgeInsets.all(5),
                itemCount: widget.playList.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    onDismissed: (dismissedDirection){
                      setState(() {
                        widget.playList[index].isDownloaded = false;
                      });
                    },
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                                "Are you sure you wish to delete this item?"),
                            actions: <Widget>[
                              widget.playListItem.playlistid == "All" &&
                                      widget.playList[index].isDownloaded
                                  ? FlatButton(
                                      onPressed: () async {
                                        await DBProvider.db
                                            .removeSongFromPlaylist(
                                                widget.playList[index].youtubeUrl,
                                                widget.playListItem.playlistid);
                                        Navigator.of(context).pop(true);
                                        widget.playList.removeAt(index);
                                        return true;
                                      },
                                      child: Text("DELTE FROM EveryWhere"))
                                  : FlatButton(
                                      onPressed: () async {
                                        await DBProvider.db
                                            .removeSongFromPlaylist(
                                                widget.playList[index].youtubeUrl,
                                                widget.playListItem.playlistid);
                                        Navigator.of(context).pop(true);
                                        widget.playList.removeAt(index);
                                        return true;
                                      },
                                      child: const Text("DELETE From Playlist")),
                              widget.playList[index].isDownloaded?FlatButton(
                                  onPressed: () async {
                                    await DBProvider.db.updateSongToDelted(widget.playList[index].youtubeUrl, );
                                    Directory documentsDirectory = await getApplicationDocumentsDirectory();
                                    final dir = Directory("${documentsDirectory.path}/Moojik/${widget.playList[index].youtubeUrl.split("?v=")[1]}");
                                    dir.deleteSync(recursive: true);
                                    Navigator.of(context).pop(false);
                                    widget.playList[index].isDownloaded = false;
                                    return false;
                                  },
                                  child: const Text("DELETE form Disc")):Divider(),
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: SongWidget(
                      song: widget.playList[index],
                      parentWidgetName: 'PlayListSongList &=${widget.playListItem.playlistid}',
                    ),
                    key: UniqueKey(),
                  );
                });
          } else if (snapshot.hasData) {
            debugPrint("called  ${snapshot.data}");
            return ListView.builder(
                itemCount: snapshot.data.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext ctxt, int index) {
                  return InkWell(
                    child: SongWidget(
                      song: Song(
                          snapshot.data[index].title,
                          " ",
                          snapshot.data[index].extras['youtubeUrl'],
                          "",
                          snapshot.data[index].extras['isDownloaded'],
                          snapshot.data[index].artUri),
                      parentWidgetName: 'PlayListSongList',
                    ),
                  );
                });
          } else {
            return Icon(Icons.check);
          }
        });
  }
}
