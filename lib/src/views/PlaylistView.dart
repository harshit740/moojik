import 'package:moojik/src/Database.dart';
import 'package:moojik/src/UI/newPlaylistDialog.dart';
import 'package:moojik/src/UI/playlistItem.dart';
import 'package:moojik/src/bloc/PlaylistBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:flutter/material.dart';

class PlayListView extends StatefulWidget {
  @override
  PlayListViewState createState() => PlayListViewState();
}

class PlayListViewState extends State<PlayListView> {
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final String playlistname = await displayDialog(context);
    if (playlistname != null) {
      await DBProvider.db.createPlaylist(playlistname);
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$playlistname")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Row(
        children: <Widget>[],
      ),
      StreamBuilder<List<PlayList>>(
          stream: playListBloc.playListsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: snapshot.data.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Dismissible(
                            key: UniqueKey(),
                            background: Container(color: Colors.black12),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (DismissDirection direction) async {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirm"),
                                    content: const Text(
                                        "Are you sure you wish to delete this item?"),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                            if (snapshot
                                                    .data[index].playlistid ==
                                                '1') {
                                              return;
                                            } else {
                                              playListBloc.delete(snapshot
                                                  .data[index].playlistid);
                                            }
                                          },
                                          child: const Text("DELETE")),
                                      FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("CANCEL"),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            },
                            child: PlaylistItem(
                                playlistitem: snapshot.data[index]));
                      }));
            } else {
              return Center(
                child: Text("No PlayList Create One"),
              );
            }
          }),
      FloatingActionButton(
        onPressed: () => _navigateAndDisplaySelection(context),
        child: Icon(Icons.playlist_add),
      )
    ]));
  }
}
