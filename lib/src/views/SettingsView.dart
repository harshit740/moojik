import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF000B1C),
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Text(
                "About",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                "Version 0.2.4",
                style: TextStyle(fontSize: 24),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 180,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Devoloped By ThegeekFlux",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          "FllowUs onFacebook https://www.facebook.com/thegeekflux",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 180,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Designed By TheGraphBox",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          "FllowUs onFacebook https://www.facebook.com/thegraphbox",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
