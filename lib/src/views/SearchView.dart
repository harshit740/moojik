import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moojik/src/UI/SongWidget.dart';

import '../bloc/searchService.dart';

class SearchView extends StatelessWidget {
  // This widget is the root of your application.
  /* Widget songList() {
    return Container(
        child: Column(children: <Widget>[
      StreamBuilder(
          stream: searchBlox.searchterm,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data);
            }
          })
    ]));
  }
*/

  Widget searchIcon() {
    return StreamBuilder(
        stream: searchBlox.issearching,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return CircularProgressIndicator();
          } else {
            return Icon(Icons.search);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        maintainBottomViewPadding: true,
        child: Container(
            padding: EdgeInsets.all(1),
            child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              TextField(
                autofocus: true,
                onChanged: searchBlox.changesearchTerm,
                onSubmitted: searchBlox.search,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Search Songs',
                  suffix: searchIcon(),
                ),
              ),
              StreamBuilder(
                  stream: searchBlox.songs,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return SongWidget(
                                  song: snapshot.data[index],
                                  parentWIdgetname: 'Searched Songs',
                                );
                              }));
                    } else {
                      return Container(
                          child: Center(
                              child: Image(
                        image: AssetImage(
                          'assets/SearchBarrAnimation.gif',
                        ),
                      )));
                    }
                  }),
            ])));
  }
}
