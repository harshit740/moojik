import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:moojik/routing_constants.dart';
import 'package:moojik/service_locator.dart';
import 'package:moojik/src/views/HomeView.dart';
import 'package:moojik/src/views/PlaylistView.dart';
import 'package:moojik/src/views/SearchView.dart';
import 'package:flutter/material.dart';
import 'package:moojik/router.dart' as router;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
  setupServiceLocator();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moojikflux',
      onGenerateRoute: router.generateRoute,
      initialRoute: HomeViewRoute,
      theme: ThemeData(
          fontFamily: 'Gilroy',
          brightness: Brightness.dark,
          primaryColorDark: Color(0xFF000B1C),
          backgroundColor: Color(0xFF000B1C),
          scaffoldBackgroundColor: Color(0xFF000B1C),
          bottomAppBarColor: Color(0xFF000B1C),
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Color(0xfff2f2f2),
              displayColor: Color(0xfff2f2f2),
              fontFamily: 'Gilroy'),
          primarySwatch: MaterialColor(4280361249, {
            50: Color(0xFF000B1C),
            100: Color(0xFF000B1C),
            200: Color(0xFF000B1C),
          })),
      darkTheme: ThemeData(
        fontFamily: 'Gilroy',
        brightness: Brightness.dark,
        primaryColorDark: Color(0xFF000B1C),
        primaryColor: Color(0xFF000B1C),
        backgroundColor: Color(0xFF000B1C),
        bottomAppBarColor: Color(0xFF000B1C),
        scaffoldBackgroundColor: Color(0xFF000B1C),
        textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Color(0xfff2f2f2),
            displayColor: Color(0xfff2f2f2),
            fontFamily: 'Gilroy'),
        primarySwatch: MaterialColor(4280361249, {
          50: Color(0xFF000B1C),
          100: Color(0xFF000B1C),
          200: Color(0xFF000B1C),
        }),
      ),
      home: AudioServiceWidget(
        child: MyHomePage(title: 'Moojikflux'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  bool isPlaying = false;
  int _selectedIndex = 0;
  bool isStarted = false;

  void _onItemTapped(int index) async {
    _tabController.animateTo(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void initControlers() {
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_setActiveTabIndex);
  }

  @override
  void initState() {
    super.initState();
    AudioService.playbackStateStream.listen((onData) {
        if (onData.basicState == BasicPlaybackState.none) {
          setState(() {
            isStarted = false;
          });
        } else {
          setState(() {
            isStarted = true;
          });
        }
        if (onData.basicState == BasicPlaybackState.playing) {
          setState(() {
            isPlaying = true;
          });
        } else if (onData.basicState == BasicPlaybackState.paused) {
          setState(() {
            isPlaying = false;
          });
        }
    });
    if (AudioService.playbackState != null) {
      if (AudioService.playbackState.basicState == BasicPlaybackState.paused) {
        setState(() {
          isPlaying = false;
        });
      }
      if (AudioService.playbackState.basicState == BasicPlaybackState.playing) {
        setState(() {
          isPlaying = true;
        });
      }
    }
    this.initControlers();
  }

// within your initState() method

  void _setActiveTabIndex() {
    setState(() {
      _selectedIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFF01183D),
            centerTitle: true,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            titleSpacing: 5,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Title(
                  child: Text("MoojikFlux"),
                  color: Colors.white,
                ),
                Text("              "),
                Title(
                  child: Text("Home"),
                  color: Colors.white,
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, SettingsRoute);
                },
              )
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    HomeView(),
                    SearchView(),
                    PlayListView(),
                  ],
                ),
              ),
              Container(
                color: Color(0xFF01183D),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if (AudioService.currentMediaItem != null) ...[
                      if (isStarted) ...[
                        CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                          AudioService.currentMediaItem.artUri,
                        )),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              reverse: true,
                              child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, PlayerViewRoute),
                                  child: Text(
                                    AudioService.currentMediaItem.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ))),
                        ),
                        if (AudioService.playbackState != null && !isPlaying ||
                            AudioService.playbackState.basicState ==
                                BasicPlaybackState.paused) ...[
                          IconButton(
                              onPressed: () async {
                                setState(() {
                                  isPlaying = true;
                                });
                                await AudioService.play();
                              },
                              iconSize: 45,
                              icon: Icon(
                                Icons.play_circle_filled,
                                size: 45,
                                color: Colors.white,
                              ))
                        ] else if (AudioService.playbackState != null &&
                                isPlaying ||
                            AudioService.playbackState.basicState ==
                                BasicPlaybackState.playing) ...[
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  isPlaying = false;
                                });
                                AudioService.pause();
                              },
                              iconSize: 45,
                              icon: Icon(
                                Icons.pause_circle_filled,
                                size: 45,
                                color: Colors.white,
                              ))
                        ] else if (AudioService.playbackState.basicState ==
                            BasicPlaybackState.connecting) ...[
                          CircularProgressIndicator()
                        ]
                      ]
                    ]
                  ],
                ),
              )
              //_widgetOptions.elementAt(_selectedIndex),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Color(0xFF01183D),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/homeButton.svg',
                  color: Colors.white,
                  width: 25,
                  height: 25,
                  semanticsLabel: "Library",
                ),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/searchButton.svg',
                  color: Colors.white,
                  width: 25,
                  height: 25,
                ),
                title: Text('Search'),
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/libraryButton.svg',
                  color: Colors.white,
                  width: 25,
                  height: 25,
                  semanticsLabel: "Library",
                ),
                title: Text('PlayList'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        ));
  }
}
