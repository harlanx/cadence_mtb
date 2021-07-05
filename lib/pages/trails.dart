import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/pages/trails_item_viewer.dart';
import 'package:cadence_mtb/services/supabase_manager.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class Trails extends StatefulWidget {
  @override
  _TrailsState createState() => _TrailsState();
}

class _TrailsState extends State<Trails> {
  int _selectedView = 1;
  List<TrailsItem> _filteredList = [];
  List<TrailsItem> _queriedList = [];
  List<TrailsItem> _trailList = [];
  late Future<List<TrailsItem>> _futureHolder;
  bool _wantToRefresh = false;
  final Map<int, List<dynamic>> _viewOptions = {
    1: ['Cards', Icons.call_to_action_rounded],
    2: ['Tiles', Icons.list],
  };
  final Map<int, List<dynamic>> _sortOptions = {
    1: ['Name(A-Z)', Icons.sort_by_alpha_rounded],
    2: ['Name(Z-A)', Icons.sort_by_alpha_rounded],
    3: ['Rating(Low)', Icons.star_rate_outlined],
    4: ['Rating(High)', Icons.star_border],
  };

  @override
  void initState() {
    super.initState();
    _futureHolder = _fetchTrails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Size _size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFFB8784B), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: FloatingSearchAppBar(
            title: const Text(
              'Trails',
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
            color: Color(0xFFB8784B),
            colorOnScroll: Color(0xFFB8784B),
            iconColor: Colors.white,
            automaticallyImplyBackButton: true,
            automaticallyImplyDrawerHamburger: false,
            transitionCurve: Curves.ease,
            transitionDuration: const Duration(milliseconds: 50),
            actions: [
              FloatingSearchBarAction.searchToClear(
                color: Colors.white,
              ),
              PopupMenuButton<int>(
                tooltip: 'View',
                color: Color(0xFFB8784B),
                icon: Icon(Icons.view_list),
                onSelected: (val) {
                  setState(() {
                    _selectedView = val;
                  });
                },
                itemBuilder: (_) {
                  return _viewOptions.entries
                      .map<PopupMenuItem<int>>((e) => PopupMenuItem(
                          value: e.key,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(e.value[1]),
                              SizedBox(
                                width: 3,
                              ),
                              Text(e.value[0], style: TextStyle(color: Colors.white)),
                            ],
                          )))
                      .toList();
                },
              ),
              PopupMenuButton<int>(
                tooltip: 'Sort',
                color: Color(0xFFB8784B),
                icon: Icon(Icons.filter_list_rounded),
                onSelected: (val) {
                  _onSort(val);
                },
                itemBuilder: (_) {
                  return _sortOptions.entries
                      .map<PopupMenuItem<int>>((e) => PopupMenuItem(
                            value: e.key,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(e.value[1]),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(e.value[0], style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ))
                      .toList();
                },
              ),
            ],
            clearQueryOnClose: true,
            onFocusChanged: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  _filteredList = _trailList;
                });
              }
            },
            onQueryChanged: (currentText) {
              String searchQuery = currentText.toLowerCase();
              if (searchQuery.length != 0) {
                List<TrailsItem> matchingResults = _trailList
                    .where((trail) => trail.trailName.toLowerCase().contains(searchQuery) || trail.location.toLowerCase().contains(searchQuery))
                    .toList(growable: false)
                      ..sort((a, b) => a.trailName.compareTo(b.trailName));
                if (matchingResults.isNotEmpty) {
                  _queriedList = matchingResults;
                } else {
                  _queriedList = [];
                }
              } else {
                setState(() {
                  _filteredList = _trailList;
                });
              }
            },
            onSubmitted: (currentText) {
              setState(() {
                _filteredList = _queriedList;
              });
            },
            body: RefreshIndicator(
              backgroundColor: Colors.white,
              color: Color(0xFF496D47),
              onRefresh: _refreshTrails,
              child: FutureBuilder<List<TrailsItem>>(
                future: _futureHolder,
                builder: (_, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            snapshot.error as String,
                          ),
                        );
                      } else {
                        return ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: _isPortrait && _selectedView == 1 ? 15 : 0, vertical: 0),
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: _selectedView == 2
                              ? Axis.vertical
                              : _isPortrait
                                  ? Axis.vertical
                                  : Axis.horizontal,
                          itemCount: _filteredList.isEmpty ? 1 : _filteredList.length,
                          separatorBuilder: (_, __) => SizedBox(
                            width: _isPortrait ? 0 : 10,
                            height: _isPortrait ? 10 : 0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            if (_filteredList.isEmpty) {
                              return Center(
                                child: Text('No Result'),
                              );
                            } else {
                              if (_selectedView == 1) {
                                return SingleChildScrollView(
                                  child: Container(
                                    color: Colors.transparent,
                                    width: _isPortrait ? double.infinity : _size.width * 0.5,
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                      elevation: 2,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              CustomRoutes.fadeThrough(
                                                page: TrailsItemViewer(
                                                  item: _filteredList[index],
                                                ),
                                              ),
                                            ),
                                            child: Container(
                                              height: _isPortrait ? _size.height * 0.3 : _size.height * 0.5,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: CachedNetworkImageProvider(_filteredList[index].previews[0]),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: ClipRect(
                                                      clipBehavior: Clip.hardEdge,
                                                      child: Container(
                                                        padding: EdgeInsets.all(10.0),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                            colors: [Colors.transparent, Colors.black],
                                                          ),
                                                        ),
                                                        width: double.infinity,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              _filteredList[index].trailName,
                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                style: TextStyle(color: Colors.white),
                                                                children: [
                                                                  WidgetSpan(
                                                                    child: Icon(
                                                                      Icons.star,
                                                                      color: Colors.yellow.shade600,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                  TextSpan(text: '${_filteredList[index].rating}'),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ExpansionTile(
                                            childrenPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                            tilePadding: EdgeInsets.symmetric(horizontal: 10.0),
                                            textColor: Color(0xFFB8784B),
                                            iconColor: Color(0xFFB8784B),
                                            title: AutoSizeText(
                                              _filteredList[index].location,
                                              maxLines: 2,
                                            ),
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  _filteredList[index].description,
                                                  presetFontSizes: [12, 10],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  CustomRoutes.fadeThrough(
                                                    page: TrailsItemViewer(
                                                      item: _filteredList[index],
                                                    ),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                  child: Text(
                                                    'Show More',
                                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 13),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return OpenContainer(
                                  closedElevation: 0,
                                  openElevation: 0,
                                  closedColor: Colors.transparent,
                                  openColor: Colors.transparent,
                                  transitionType: ContainerTransitionType.fade,
                                  closedBuilder: (_, action) {
                                    return ListTile(
                                      onTap: () => action(),
                                      dense: true,
                                      leading: Container(
                                        width: 60,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(_filteredList[index].previews[0]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.star,
                                                color: Colors.yellow.shade600,
                                                size: 18,
                                              ),
                                            ),
                                            TextSpan(text: '${_filteredList[index].rating} '),
                                            TextSpan(
                                              text: _filteredList[index].trailName,
                                            )
                                          ],
                                        ),
                                        maxLines: 1,
                                      ),
                                      subtitle: AutoSizeText(
                                        _filteredList[index].description,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_right),
                                    );
                                  },
                                  openBuilder: (_, __) {
                                    return TrailsItemViewer(
                                      item: _filteredList[index],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        );
                      }

                    default:
                      return SpinKitChasingDots(
                        color: Color(0xFFB8784B),
                      );
                  }
                },
              ),
            ),
          ),
          floatingActionButton: !sosEnabled['Trails']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  Future<List<TrailsItem>> _fetchTrails() async {
    if (_trailList.isEmpty) {
      List<String> oldData = StorageHelper.getStringList('trailsContent') ?? <String>[];
      if (oldData.isNotEmpty) {
        _trailList = oldData.map((e) => TrailsItem.fromJson(e)).toList();
      } else {
        await InternetConnectionChecker().hasConnection.then((hasInternet) async {
          if (hasInternet) {
            _trailList = await SupabaseManager.getTrailsList();
            StorageHelper.setStringList('trailsContent', _trailList.map((e) => e.toJson()).toList());
          } else {
            return Future.error('No Internet');
          }
        });
      }
    } else if (_trailList.isNotEmpty && _wantToRefresh) {
      await InternetConnectionChecker().hasConnection.then((hasInternet) async {
        if (hasInternet) {
          _trailList.clear();
          _trailList.addAll(await SupabaseManager.getTrailsList());
          StorageHelper.setStringList('trailsContent', _trailList.map((e) => e.toJson()).toList());
        } else {
          CustomToast.showToastSimple(context: context, simpleMessage: 'No Internet');
        }
      });
      _wantToRefresh = false;
    }
    _filteredList = _trailList;
    return _trailList;
  }

  Future<void> _refreshTrails() async {
    _wantToRefresh = true;
    _fetchTrails().then((value) => setState(() {}));
  }

  void _onSort(int choice) {
    if (choice == 1) {
      _filteredList.sort((a, b) => a.trailName.compareTo(b.trailName));
    } else if (choice == 2) {
      _filteredList.sort((a, b) => b.trailName.compareTo(a.trailName));
    } else if (choice == 3) {
      _filteredList.sort((a, b) => a.rating.compareTo(b.rating));
    } else {
      _filteredList.sort((a, b) => b.rating.compareTo(a.rating));
    }
    setState(() {});
  }
}
