import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/youtube_videos.dart';
import 'package:cadence_mtb/services/youtube_service.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class BodyConditioning extends StatefulWidget {
  @override
  _BodyConditioningState createState() => _BodyConditioningState();
}

class _BodyConditioningState extends State<BodyConditioning> {
  YoutubeVideos _bodyConVideosList = YoutubeVideos();
  List<VideoItem> _searchList = <VideoItem>[];
  late Future<YoutubeVideos> _futureHolder;
  bool _wantToRefresh = false;

  @override
  void initState() {
    super.initState();
    _bodyConVideosList.items ??= [];
    _futureHolder = _loadBodyConditioningVideos();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Size _size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: FloatingSearchAppBar(
            title: const Text(
              'Body Conditioning',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              maxLines: 1,
            ),
            elevation: 0,
            liftOnScrollElevation: 0,
            titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
            hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            color: Color(0xFF496D47),
            colorOnScroll: Color(0xFF496D47),
            iconColor: Colors.white,
            automaticallyImplyBackButton: true,
            automaticallyImplyDrawerHamburger: false,
            transitionCurve: Curves.ease,
            transitionDuration: const Duration(milliseconds: 50),
            actions: [
              FloatingSearchBarAction.searchToClear(
                showIfClosed: true,
                color: Colors.white,
              ),
            ],
            clearQueryOnClose: true,
            onQueryChanged: (currentText) {
              String searchQuery = currentText.toLowerCase();
              if (searchQuery.length != 0) {
                _searchList =
                    _bodyConVideosList.items!.where((item) => item.snippet!.title.toLowerCase().contains(searchQuery)).toList(growable: false);
              } else {
                _searchList = _bodyConVideosList.items!;
              }
            },
            onSubmitted: (currentText) {
              setState(() {});
            },
            onFocusChanged: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  _searchList = _bodyConVideosList.items!;
                });
              }
            },
            body: RefreshIndicator(
              backgroundColor: Colors.white,
              color: Color(0xFF496D47),
              onRefresh: _refreshVideos,
              child: FutureBuilder<YoutubeVideos>(
                future: _futureHolder,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Center(child: AutoSizeText(snapshot.error as String));
                      } else {
                        return VideoList(
                          isPortrait: _isPortrait,
                          screenSize: _size,
                          videoList: _searchList,
                        );
                      }
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                    default:
                      return Center(child: SpinKitCircle(color: Color(0xFF496D47)));
                  }
                },
              ),
            ),
          ),
          floatingActionButton: !sosEnabled['Body Conditioning']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  Future<YoutubeVideos> _loadBodyConditioningVideos() async {
    if (_bodyConVideosList.items!.isEmpty) {
      String oldData = StorageHelper.getString('bodyConVideos') ?? '';
      if (oldData.isNotEmpty) {
        _bodyConVideosList.items = YoutubeVideos.fromJson(oldData).items;
      } else {
        await InternetConnectionChecker().hasConnection.then((hasInternet) async {
          if (hasInternet) {
            YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.bodyConditioning);
            _bodyConVideosList.items = newData.items;
            StorageHelper.setString('bodyConVideos', _bodyConVideosList.toJson());
          } else {
            return Future.error('No Internet!');
          }
        });
      }
    } else if (_bodyConVideosList.items!.isNotEmpty && _wantToRefresh) {
      await InternetConnectionChecker().hasConnection.then((hasInternet) async {
        if (hasInternet) {
          YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.bodyConditioning);
          _bodyConVideosList.items!.clear();
          _bodyConVideosList.items!.addAll(newData.items!);
          StorageHelper.setString('bodyConVideos', _bodyConVideosList.toJson());
        } else {
          CustomToast.showToastSimple(context: context, simpleMessage: 'No Internet');
        }
      });
      _wantToRefresh = false;
    }
    _searchList = _bodyConVideosList.items!;
    return _bodyConVideosList;
  }

  Future<void> _refreshVideos() async {
    _wantToRefresh = true;
    _loadBodyConditioningVideos().then((value) => setState(() {}));
  }
}
