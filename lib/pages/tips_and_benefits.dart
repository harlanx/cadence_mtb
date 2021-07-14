import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/data/data.dart';
import 'package:cadence_mtb/pages/article_viewer.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class TipsAndBenefits extends StatefulWidget {
  @override
  _TipsAndBenefitsState createState() => _TipsAndBenefitsState();
}

class _TipsAndBenefitsState extends State<TipsAndBenefits> with SingleTickerProviderStateMixin {
  FloatingSearchBarController _fSBController = FloatingSearchBarController();
  late TabController _tabController;
  late List<ArticleItem> _tSearchList;
  late List<ArticleItem> _bSearchList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    tipsItems.sort((a, b) => a.title.compareTo(b.title));
    _tSearchList = tipsItems;
    benefitsItems.sort((a, b) => a.title.compareTo(b.title));
    _bSearchList = benefitsItems;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fSBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          key: tabKey,
          resizeToAvoidBottomInset: false,
          body: FloatingSearchAppBar(
            controller: _fSBController,
            title: const Text(
              'Tips and Benefits',
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
              if (_tabController.index == 0) {
                if (searchQuery.length != 0) {
                  _tSearchList = tipsItems
                      .where((item) => item.title.toLowerCase().contains(searchQuery) || item.subtitle.toLowerCase().contains(searchQuery))
                      .toList(growable: false)
                        ..sort((a, b) => a.title.compareTo(b.title));
                } else {
                  _tSearchList = tipsItems;
                }
              } else {
                if (searchQuery.length != 0) {
                  _bSearchList = benefitsItems
                      .where((item) => item.title.toLowerCase().contains(searchQuery) || item.subtitle.toLowerCase().contains(searchQuery))
                      .toList(growable: false)
                        ..sort((a, b) => a.title.compareTo(b.title));
                } else {
                  _bSearchList = benefitsItems;
                }
              }
            },
            onSubmitted: (currentText) {
              setState(() {});
            },
            onFocusChanged: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  _tSearchList = tipsItems;
                  _bSearchList = benefitsItems;
                });
              }
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
                      isScrollable: false,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          text: 'Tips',
                        ),
                        Tab(
                          text: 'Benefits',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView.separated(
                        //Tips
                        physics: BouncingScrollPhysics(),
                        itemCount: _tSearchList.isEmpty ? 1 : _tSearchList.length,
                        separatorBuilder: (BuildContext context, int index) => Divider(
                          thickness: 1.5,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          if (_tSearchList.isEmpty) {
                            return Center(
                              child: Text('No Result'),
                            );
                          }
                          return OpenContainer(
                            closedElevation: 0,
                            openElevation: 0,
                            closedColor: Colors.transparent,
                            openColor: Colors.transparent,
                            closedBuilder: (_, onTap) {
                              return ListTile(
                                dense: true,
                                leading: Image.asset(
                                  _tSearchList[index].image,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                title: AutoSizeText(
                                  _tSearchList[index].title,
                                  maxLines: 1,
                                  wrapWords: true,
                                ),
                                subtitle: Text(
                                  _tSearchList[index].subtitle,
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                ),
                                onTap: onTap,
                              );
                            },
                            openBuilder: (_, __) => ArticleViewer(
                              articleItem: _tSearchList[index],
                              articleType: 1,
                            ),
                          );
                        },
                      ),
                      ListView.separated(
                        //Benefits
                        physics: BouncingScrollPhysics(),
                        itemCount: _bSearchList.isEmpty ? 1 : _bSearchList.length,
                        separatorBuilder: (BuildContext context, int index) => Divider(
                          thickness: 1.5,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          if (_bSearchList.isEmpty) {
                            return Center(
                              child: Text('No Result'),
                            );
                          }
                          return OpenContainer(
                            closedElevation: 0,
                            openElevation: 0,
                            closedColor: Colors.transparent,
                            openColor: Colors.transparent,
                            closedBuilder: (_, onTap) {
                              return ListTile(
                                dense: true,
                                leading: Image.asset(
                                  _bSearchList[index].image,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                                title: AutoSizeText(
                                  _bSearchList[index].title,
                                  maxLines: 1,
                                  wrapWords: true,
                                ),
                                subtitle: Text(_bSearchList[index].subtitle),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                ),
                                onTap: onTap,
                              );
                            },
                            openBuilder: (_, __) => ArticleViewer(
                              articleItem: _bSearchList[index],
                              articleType: 1,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: !sosEnabled['Tips and Benefits']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }
}

