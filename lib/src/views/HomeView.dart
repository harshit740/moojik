import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moojik/src/bloc/PlaylistBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlayList>>(
        stream: playListBloc.playListsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 2,
                padding: EdgeInsets.all(5),
                children: List.generate(snapshot.data.length, (index) {
                  return Center(
                      child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Image.network("https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg?auto=format&q=60&fit=max&w=930",
                          colorBlendMode: BlendMode.softLight),
                       Center(child:  Opacity(child:Text(
                         "${snapshot.data[index].title}",
                         style: TextStyle(
                           fontSize: 30.0,
                           fontWeight: FontWeight.bold,
                         ),
                       ), opacity:   1.0 ,))
                      ],
                    )
                  ));
                }));
          } else if (snapshot.hasError == true) {
            return Center(
              child: Icon(Icons.error_outline),
            );
          } else {
            return Center(
              child: Icon(Icons.error),
            );
          }
        });
  }
}
