import 'dart:async';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/app_settings.dart';
import 'package:cadence_mtb/pages/bike_project.dart';
import 'package:cadence_mtb/pages/first_aid.dart';
import 'package:cadence_mtb/pages/navigate.dart';
import 'package:cadence_mtb/pages/trails.dart';
import 'package:cadence_mtb/pages/bike_activity_history.dart';
import 'package:cadence_mtb/pages/video_player.dart';
import 'package:cadence_mtb/services/youtube_service.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
part 'home_screen/home_video_carousel.dart';
part 'home_screen/user_activity_panel.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  YoutubeVideos _homeVideosList = YoutubeVideos();
  final PanelController _slidePanelController = PanelController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  ScrollController _sPContentController = ScrollController();
  bool _wantToRefresh = false;
  /* This is to prevent the whole "Widget build()" to not be rebuilt when a setstate is triggered.
  This will ensure that the _loadHomeVideos function only runs the future builder once. */
  late Future _futureHolder;
  DrawableRoot? svgRoot;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeMetrics() {
    /* NOTE: didChangeMetrics runs before any MediaQueryData is updated by the framework.
    So if you did a MediaQuery.of(context).orientation here, you will get the value
    before the orientation change is finished. To fix this, use  WidgetsBinding.instance.addPostFrameCallback() */
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final _orientation = MediaQuery.of(context).orientation;
      if (_orientation == Orientation.portrait) {
        _slidePanelController.show();
      } else {
        _slidePanelController.hide();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    generateAvatar();
    _homeVideosList.items ??= <VideoItem>[];
    _futureHolder = _loadHomeVideos();
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final _orientation = MediaQuery.of(context).orientation;
      if (_orientation != Orientation.portrait) {
        _slidePanelController.hide();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size _screenSize = MediaQuery.of(context).size;
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SlidingUpPanel(
      margin: EdgeInsets.zero,
      controller: _slidePanelController,
      panelSnapping: true,
      backdropEnabled: false,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).scaffoldBackgroundColor.darken(0.2),
          blurRadius: 2,
          spreadRadius: 1,
          offset: Offset(0, -1),
        ),
      ],
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      minHeight: _screenSize.height * 0.35,
      maxHeight: _screenSize.height * 0.70,
      onPanelOpened: () {
        //Do not remove. This updates the drag icon to arrow down icon.
        //When the user choose to slide up instead of tapping to expand
        //or close.
        if (_slidePanelController.isPanelShown) {
          setState(() {});
        }
      },
      onPanelClosed: () {
        if (_slidePanelController.isPanelShown) {
          _sPContentController.jumpTo(0.0);
          setState(() {});
        }
      },
      panelBuilder: (controller) {
        _sPContentController = controller;
        return UserActivityPanel(
          slidePanelController: _slidePanelController,
          scrollController: _sPContentController,
        );
      },
      body: Column(
        children: [
          Container(
            height: AppBar().preferredSize.height,
            width: AppBar().preferredSize.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).scaffoldBackgroundColor.darken(0.2),
                  blurRadius: 1,
                  offset: Offset(0, 1.0),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: InkWell(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: svgRoot == null
                            ? SvgPicture.asset(
                                'assets/icons/home_dashboard/final_app_icon.svg',
                                height: 50,
                                width: 50,
                              )
                            : CustomPaint(
                                foregroundPainter: AvatarPainter(svgRoot!, Size(50.0, 50.0)),
                                child: Container(),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: InkWell(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Text(
                          '${currentUser!.profileName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF496D47),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                OpenContainer(
                  closedElevation: 0,
                  openElevation: 0,
                  closedColor: Colors.transparent,
                  openColor: Colors.transparent,
                  closedBuilder: (_, action) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        iconSize: 28,
                        padding: EdgeInsets.zero,
                        color: const Color(0xFF496D47),
                        splashRadius: 20,
                        tooltip: 'Settings',
                        onPressed: () => action(),
                      ),
                    );
                  },
                  openBuilder: (_, __) {
                    return AppSettings();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: _isPortrait ? 20 : 15,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: _screenSize.height * 0.008),
              child: Table(
                children: [
                  TableRow(
                    children: [
                      Center(
                        child: SizedBox(
                          height: _screenSize.height * 0.066,
                          child: AspectRatio(
                            aspectRatio: _isPortrait ? (1 / 1) : (3 / 1),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFFB8784B),
                                padding: const EdgeInsets.all(5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: SvgPicture.asset('assets/icons/home_dashboard/trail_list.svg'),
                              onPressed: () {
                                Navigator.push(context, CustomRoutes.fadeThrough(page: Trails(), duration: Duration(milliseconds: 300)));
                              },
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: _screenSize.height * 0.066,
                          child: AspectRatio(
                            aspectRatio: _isPortrait ? 1 / 1 : 3 / 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFF3D5164),
                                padding: const EdgeInsets.all(5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: SvgPicture.asset('assets/icons/home_dashboard/navigate.svg'),
                              onPressed: () {
                                Navigator.push(context, CustomRoutes.fadeThrough(page: Navigate(), duration: Duration(milliseconds: 300)));
                              },
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: _screenSize.height * 0.066,
                          child: AspectRatio(
                            aspectRatio: _isPortrait ? 1 / 1 : 3 / 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFFFF8B02),
                                padding: const EdgeInsets.all(5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: SvgPicture.asset('assets/icons/home_dashboard/bike_project.svg'),
                              onPressed: () {
                                Navigator.push(context, CustomRoutes.fadeThrough(page: BikeProject(), duration: Duration(milliseconds: 300)));
                              },
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: _screenSize.height * 0.066,
                          child: AspectRatio(
                            aspectRatio: _isPortrait ? 1 / 1 : 3 / 1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFFF15024),
                                padding: const EdgeInsets.all(5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: SvgPicture.asset('assets/icons/home_dashboard/first_aid.svg'),
                              onPressed: () {
                                Navigator.push(context, CustomRoutes.fadeThrough(page: FirstAid(), duration: Duration(milliseconds: 300)));
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(height: _screenSize.height * 0.008),
                      SizedBox(height: _screenSize.height * 0.008),
                      SizedBox(height: _screenSize.height * 0.008),
                      SizedBox(height: _screenSize.height * 0.008)
                    ],
                  ),
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFF496D47)),
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 1),
                          child: const AutoSizeText(
                            'Trails',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 1),
                          child: const AutoSizeText(
                            'Navigate',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 1),
                          child: const AutoSizeText(
                            'Bike Project',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 1),
                          child: const AutoSizeText(
                            'First Aid',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: _isPortrait ? 80 : 85,
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 8,
                    child: Align(
                      alignment: Alignment(-0.95, 0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'VIDEOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _isPortrait ? 20 : 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 92,
                    child: RefreshIndicator(
                      backgroundColor: Colors.white,
                      color: Color(0xFF496D47),
                      key: _refreshIndicatorKey,
                      onRefresh: _refreshVideos,
                      child: FutureBuilder(
                        future: _futureHolder,
                        builder: (_, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    snapshot.error as String,
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 15),
                                  ),
                                );
                              } else {
                                return _HomeVideoCarousel(
                                  isPortrait: _isPortrait,
                                  videos: _homeVideosList.items!.take(5).toList(),
                                );
                              }

                            case ConnectionState.active:
                            case ConnectionState.waiting:
                            default:
                              return Center(
                                child: SpinKitChasingDots(
                                  color: Color(0xFF496D47),
                                ),
                              );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: _isPortrait ? _screenSize.height * 0.35 : 10,
          ),
        ],
      ),
    );
  }

  void generateAvatar() async {
    return SvgWrapper(multiavatar(currentUser!.avatarCode)).generateLogo().then((value) {
      setState(() {
        svgRoot = value;
      });
    });
  }

  void closePanel() {
    if (_slidePanelController.isPanelOpen && _slidePanelController.isPanelShown) {
      _slidePanelController.close();
    }
  }

  Future<YoutubeVideos> _loadHomeVideos() async {
    if (_homeVideosList.items!.isEmpty) {
      String oldData = StorageHelper.getString('homeVideos') ?? '';
      if (oldData.isNotEmpty) {
        _homeVideosList.items!.addAll(YoutubeVideos.fromJson(oldData).items!);
      } else {
        await InternetConnectionChecker().hasConnection.then((hasInternet) async {
          if (hasInternet) {
            YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.homeVideos);
            _homeVideosList.items = (newData.items);
            _homeVideosList.items!.shuffle();
            StorageHelper.setString('homeVideos', _homeVideosList.toJson());
          } else {
            return Future.error('No Internet!');
          }
        });
      }
    } else if (_homeVideosList.items!.isNotEmpty && _wantToRefresh) {
      await InternetConnectionChecker().hasConnection.then((hasInternet) async {
        if (hasInternet) {
          YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.homeVideos);
          _homeVideosList.items!.clear();
          _homeVideosList.items!.addAll(newData.items!);
          _homeVideosList.items!.shuffle();
          StorageHelper.setString('homeVideos', _homeVideosList.toJson());
        } else {
          CustomToast.showToastSimple(context: context, simpleMessage: 'No Internet');
        }
      });
      _wantToRefresh = false;
    }
    return _homeVideosList;
  }

  Future<void> _refreshVideos() async {
    _wantToRefresh = true;
    _loadHomeVideos().then((value) => setState(() {}));
  }
}


