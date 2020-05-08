import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:moojik/src/Database.dart';
import 'package:moojik/src/UI/horizontalSongList.dart';
import 'package:moojik/src/bloc/PlaylistBloc.dart';
import 'package:moojik/src/bloc/trendingSongsBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:moojik/src/models/SongMode.dart';
import 'package:moojik/routing_constants.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
      shrinkWrap: true,
      children: [
        Text(
          "Recentaly Played",
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
            height: 200,
            child: FutureBuilder<List<Song>>(
                future: DBProvider.db.getLastPlayed(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == true) {
                    return HorizontalSongList(songs: snapshot.data,parentWidgetName: "Recently Played",);
                  } else {
                    return  Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
        Text(
          "Trending Today",
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
            height: 200,
            child: StreamBuilder<List<Song>>(
                stream: trendingBloc.getTrendingSongs,
                builder: (context, snapshot) {
                  if (snapshot.hasData == true) {
                    return HorizontalSongList(songs: snapshot.data,parentWidgetName: "Trending Songs",);
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
        Text(
          "Your Playlists",
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
        StreamBuilder<List<PlayList>>(
            stream: playListBloc.playListsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: ScrollPhysics(),
                  // to disable GridView's scrolling
                  crossAxisCount: 3,
                  cacheExtent: 5,
                  padding: EdgeInsets.all(3),
                  children: List.generate(snapshot.data.length, (index) {
                    return InkWell(
                        splashColor: Colors.white,
                        onTap: () => Navigator.pushNamed(
                            context, PlayListDetailRoute,
                            arguments: snapshot.data[index]),
                        child: Card(
                            color: Color(0xFF01183D),
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Icon(Icons.library_music),
                                Center(
                                    child: snapshot.data[index].title
                                                    .split(" ")
                                                    .length >
                                                1 &&
                                            snapshot.data[index].title
                                                    .split(" ")
                                                    .length <
                                                4
                                        ? Flex(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: getChildrensText(
                                                snapshot.data[index].title),
                                            direction: Axis.vertical,
                                          )
                                        : Text(
                                            snapshot.data[index].title,
                                            style: TextStyle(
                                              fontSize: 17,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                              ],
                            )));
                  }),
                );
              } else if (snapshot.hasError == true) {
                return Center(
                  child: Icon(Icons.error_outline),
                );
              } else {
                return Center(
                  child: Icon(Icons.error),
                );
              }
            })
      ],
    ));
  }


  getChildrensText(String title) {
    List<Widget> childrens = [];
    if (title.split(" ").length > 1 && title.split(" ").length < 4) {
      title.split(" ").forEach((f) {
        childrens.add(Center(
          child: Text(
            f,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          ),
        ));
      });
      return childrens;
    }
  }
}
