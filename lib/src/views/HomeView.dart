import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:moojik/src/bloc/PlaylistBloc.dart';
import 'package:moojik/src/models/PlayListModel.dart';

import '../../routing_constants.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlayList>>(
        stream: playListBloc.playListsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
                crossAxisCount: 3,
                cacheExtent: 5,
                padding: EdgeInsets.all(3),
                children: List.generate(snapshot.data.length, (index) {
                  return InkWell(
                      onTap: () => Navigator.pushNamed(context,PlayListDetailRoute,arguments: snapshot.data[index]),
                      child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Icon(Icons.library_music),
                        Center(
                            child:  snapshot.data[index].title.split(" ").length > 1 && snapshot.data[index].title.split(" ").length <4 ?
                            Flex(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: getChildrensText(snapshot.data[index].title), direction: Axis.vertical,
                            ):Text(snapshot.data[index].title,style:TextStyle(fontSize: 17,),textAlign: TextAlign.center,maxLines: 4,overflow: TextOverflow.ellipsis,))
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

  getChildrensText(String title) {
    List<Widget>  childrens  = [];
    if( title.split(" ").length >1 && title.split(" ").length <4){
    title.split(" ").forEach((f){
      childrens.add(Center(child: Text(f,textAlign: TextAlign.center,style: TextStyle(fontSize: 17),),));
    });
    return childrens;
    }
  }
}
