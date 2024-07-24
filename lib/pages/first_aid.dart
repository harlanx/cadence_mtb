import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/data/data.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/article_viewer.dart';
import 'package:cadence_mtb/pages/bmi_history.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class FirstAid extends StatefulWidget {
  @override
  _FirstAidState createState() => _FirstAidState();
}

class _FirstAidState extends State<FirstAid> {
  int _selectedSort = 1;
  List<ArticleItem> _filteredList = [];
  List<ArticleItem> _queriedList = [];
  final Map<int, List<dynamic>> _sortOptions = {
    1: ['Title(A-Z)', Icons.sort_by_alpha_rounded],
    2: ['Title(Z-A)', Icons.sort_by_alpha_rounded],
  };

  @override
  void initState() {
    super.initState();
    _filteredList = firstAidItems;
    _onSort(_selectedSort);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF15024),
          statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          key: firstAidKey,
          resizeToAvoidBottomInset: false,
          body: FloatingSearchAppBar(
            title: const Text(
              'First Aid',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            elevation: 0,
            liftOnScrollElevation: 0,
            titleStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
            hintStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            color: Color(0xFFF15024),
            colorOnScroll: Color(0xFFF15024),
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
                tooltip: 'Sort',
                color: Color(0xFFF15024),
                icon: Icon(Icons.filter_list_rounded),
                onSelected: (val) {
                  _onSort(val);
                  _selectedSort = val;
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
                                Text(e.value[0],
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ))
                      .toList();
                },
              ),
              IconButton(
                tooltip: 'BMI History',
                //Why the heart icon is named favorite lol
                icon: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await Hive.openBox<BMIData>(
                          '${currentUser!.profileNumber}bmiActivities')
                      .then((_) {
                    Navigator.push(
                      context,
                      CustomRoutes.fadeThrough(
                        page: BMIHistory(),
                      ),
                    );
                  });
                },
              ),
            ],
            clearQueryOnClose: true,
            onFocusChanged: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  _filteredList = firstAidItems;
                });
              }
            },
            onQueryChanged: (currentText) {
              String searchQuery = currentText.toLowerCase();
              if (searchQuery.length != 0) {
                List<ArticleItem> matchingResults = firstAidItems
                    .where((injury) =>
                        injury.title.toLowerCase().contains(searchQuery) ||
                        injury.subtitle.toLowerCase().contains(searchQuery))
                    .toList(growable: false)
                  ..sort((a, b) => a.title.compareTo(b.title));
                if (matchingResults.isNotEmpty) {
                  _queriedList = matchingResults;
                } else {
                  _queriedList = [];
                }
              } else {
                setState(() {
                  _filteredList = firstAidItems;
                });
              }
            },
            onSubmitted: (currentText) {
              setState(() {
                _filteredList = _queriedList;
              });
            },
            body: ListView.separated(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _filteredList.isEmpty ? 1 : _filteredList.length,
              separatorBuilder: (_, __) => Divider(
                thickness: 1.5,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (_filteredList.isEmpty) {
                  return Center(
                    child: Text('No Result'),
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
                        dense: true,
                        onTap: () => action(),
                        leading: Image.asset(
                          _filteredList[index].image,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                        title: AutoSizeText(
                          _filteredList[index].title,
                          maxLines: 1,
                          wrapWords: true,
                        ),
                        subtitle: AutoSizeText(
                          _filteredList[index].subtitle,
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      );
                    },
                    openBuilder: (_, __) {
                      return ArticleViewer(
                        articleItem: _filteredList[index],
                        articleType: 2,
                      );
                    },
                  );
                }
              },
            ),
          ),
          floatingActionButton: !sosEnabled['First Aid']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  void _onSort(int choice) {
    if (choice == 1) {
      _filteredList.sort((a, b) => a.title.compareTo(b.title));
    } else {
      _filteredList.sort((a, b) => b.title.compareTo(a.title));
    }
    setState(() {});
  }
}
