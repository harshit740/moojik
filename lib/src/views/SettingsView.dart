import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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

/*
* RichText(
                text: TextSpan(
                    text: 'Don\'t have an account?',
                    style: TextStyle(
                        color: Colors.black, fontSize: 18),
                    children: <TextSpan>[
                      TextSpan(text: ' Made with<3',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                      TextSpan(text: "TextSpan",style:  TextStyle(
                          color: Colors.white, fontSize: 18),)
                    ]
                ),
              )
* **/
