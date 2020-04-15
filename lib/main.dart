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

void connect() async {
  await AudioService.connect();
}

void disconnect() {
  AudioService.disconnect();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    connect();
    return MaterialApp(
      title: 'Moojikflux',
      onGenerateRoute: router.generateRoute,
      initialRoute: HomeViewRoute,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: AudioServiceWidget(
        child: MyHomePage(title: 'Moojikflux'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
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

  onChange() {}
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
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
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  if (AudioService.currentMediaItem != null) ...[
                    if (isStarted) ...[
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(AudioService.currentMediaItem.artUri),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width/1.5,
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
                      ]
                    ]
                  ]
                ],
              )
              //_widgetOptions.elementAt(_selectedIndex),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                title: Text('Search'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                title: Text('PlayList'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green,
            onTap: _onItemTapped,
          ),
        ));
  }
}
