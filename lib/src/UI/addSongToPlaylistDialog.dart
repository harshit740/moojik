import 'package:moojik/src/Database.dart';
import 'package:moojik/src/models/PlayListModel.dart';
import 'package:flutter/material.dart';

displayAddToDialog(
  BuildContext context,
) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<PlayList>>(
                      future: DBProvider.db.getAllPlayList(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          snapshot.data.removeAt(0);
                          return Expanded(
                              child: ListView.builder(
                                  padding: EdgeInsets.all(10),
                                  itemCount: snapshot.data.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.all(10),
                                      title: Text(snapshot.data[index].title),
                                      onTap: () => Navigator.pop(context,
                                          snapshot.data[index].playlistid),
                                    );
                                  }));
                        } else {
                          return Center(child: Icon(Icons.error_outline));
                        }
                      }),
                  SizedBox(
                      width: 320.0,
                      child: Column(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context, 'CreatePlayList');
                            },
                            child: Text(
                              "Create New PlayList",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancle",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        );
      });
}
