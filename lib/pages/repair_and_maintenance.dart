import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/services/youtube_service.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class RepairAndMaintenance extends StatefulWidget {
  @override
  _RepairAndMaintenanceState createState() => _RepairAndMaintenanceState();
}

class _RepairAndMaintenanceState extends State<RepairAndMaintenance> with SingleTickerProviderStateMixin {
  YoutubeVideos _repairVideosList = YoutubeVideos();
  YoutubeVideos _maintenanceVideosList = YoutubeVideos();
  FloatingSearchBarController _fSBController = FloatingSearchBarController();
  List<VideoItem>? _rSearchList = <VideoItem>[];
  List<VideoItem>? _mSearchList = <VideoItem>[];
  late TabController _tabController;
  late Future _futureRepairHolder;
  late Future _futureMaintenanceHolder;
  bool _wantToRefreshRepair = false;
  bool _wantToRefreshMaintenance = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _repairVideosList.items ??= [];
    _futureRepairHolder = _loadRepairVideos();
    _maintenanceVideosList.items ??= [];
    _futureMaintenanceHolder = _loadMaintenanceVideos();
  }

  @override
  void dispose() {
    _fSBController.dispose();
    super.dispose();
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
            controller: _fSBController,
            title: const Text(
              'Repair and Maintenance',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
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
              if (_tabController.index == 0) {
                if (searchQuery.length != 0) {
                  _rSearchList =
                      _repairVideosList.items!.where((item) => item.snippet!.title.toLowerCase().contains(searchQuery)).toList(growable: false);
                } else {
                  _rSearchList = _repairVideosList.items;
                }
              } else {
                if (searchQuery.length != 0) {
                  _mSearchList =
                      _maintenanceVideosList.items!.where((item) => item.snippet!.title.toLowerCase().contains(searchQuery)).toList(growable: false);
                } else {
                  _mSearchList = _maintenanceVideosList.items;
                }
              }
            },
            onFocusChanged: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  _rSearchList = _repairVideosList.items;
                  _mSearchList = _maintenanceVideosList.items;
                });
              }
            },
            onSubmitted: (currentText) {
              setState(() {});
            },
            body: Column(
              children: [
                Visibility(
                  visible: _fSBController.query.isEmpty || _fSBController.isClosed,
                  child: Material(
                    color: Color(0xFF496D47),
                    child: TabBar(
                      labelStyle: TextStyle(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: false,
                      indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          text: 'Repair',
                        ),
                        Tab(
                          text: 'Maintenance',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        backgroundColor: Colors.white,
                        color: Color(0xFF496D47),
                        onRefresh: _refreshRepairVideos,
                        child: FutureBuilder(
                          future: _futureRepairHolder,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Center(child: AutoSizeText(snapshot.error as String));
                                } else {
                                  return VideoList(
                                    key: Key('Repair'),
                                    isPortrait: _isPortrait,
                                    screenSize: _size,
                                    videoList: _rSearchList,
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
                      RefreshIndicator(
                        backgroundColor: Colors.white,
                        color: Color(0xFF496D47),
                        onRefresh: _refreshMaintenanceVideos,
                        child: FutureBuilder(
                          future: _futureMaintenanceHolder,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Center(child: AutoSizeText(snapshot.error as String));
                                } else {
                                  return VideoList(
                                    key: Key('Maintenance'),
                                    isPortrait: _isPortrait,
                                    screenSize: _size,
                                    videoList: _mSearchList,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: !sosEnabled['Repair and Maintenance']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  Future<YoutubeVideos> _loadRepairVideos() async {
    if (_repairVideosList.items!.isEmpty) {
      String oldData = StorageHelper.getString('repairVideos') ?? '';
      if (oldData.isNotEmpty) {
        _repairVideosList.items = YoutubeVideos.fromJson(oldData).items;
      } else {
        await InternetConnectionChecker().hasConnection.then((hasInternet) async {
          if (hasInternet) {
            YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.repair);
            _repairVideosList.items = newData.items;
            StorageHelper.setString('repairVideos', _repairVideosList.toJson());
          } else {
            return Future.error('No Internet!');
          }
        });
      }
    } else if (_repairVideosList.items!.isNotEmpty && _wantToRefreshRepair) {
      await InternetConnectionChecker().hasConnection.then((hasInternet) async {
        if (hasInternet) {
          YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.repair);
          _repairVideosList.items!.clear();
          _repairVideosList.items!.addAll(newData.items!);
          StorageHelper.setString('repairVideos', _repairVideosList.toJson());
        } else {
          CustomToast.showToastSimple(context: context, simpleMessage: 'No Internet');
        }
      });
      _wantToRefreshRepair = false;
    }
    _rSearchList = _repairVideosList.items;
    return _repairVideosList;
  }

  Future<void> _refreshRepairVideos() async {
    _wantToRefreshRepair = true;
    _loadRepairVideos().then((value) => setState(() {}));
  }

  Future<YoutubeVideos> _loadMaintenanceVideos() async {
    if (_maintenanceVideosList.items!.isEmpty) {
      String oldData = StorageHelper.getString('maintenanceVideos') ?? '';
      if (oldData.isNotEmpty) {
        _maintenanceVideosList.items = YoutubeVideos.fromJson(oldData).items;
      } else {
        await InternetConnectionChecker().hasConnection.then((hasInternet) async {
          if (hasInternet) {
            YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.maintenance);
            _maintenanceVideosList.items = newData.items;
            StorageHelper.setString('maintenanceVideos', _maintenanceVideosList.toJson());
          } else {
            return Future.error('No Internet!');
          }
        });
      }
    } else if (_maintenanceVideosList.items!.isNotEmpty && _wantToRefreshMaintenance) {
      await InternetConnectionChecker().hasConnection.then((hasInternet) async {
        if (hasInternet) {
          YoutubeVideos newData = await YoutubeService.getVideosList(playListId: Constants.playlist.maintenance);
          _maintenanceVideosList.items!.clear();
          _maintenanceVideosList.items!.addAll(newData.items!);
          StorageHelper.setString('maintenanceVideos', _maintenanceVideosList.toJson());
        } else {
          CustomToast.showToastSimple(context: context, simpleMessage: 'No Internet');
        }
      });
      _wantToRefreshMaintenance = false;
    }
    _mSearchList = _maintenanceVideosList.items;
    return _maintenanceVideosList;
  }

  Future<void> _refreshMaintenanceVideos() async {
    _wantToRefreshMaintenance = true;
    _loadMaintenanceVideos().then((value) => setState(() {}));
  }
}
