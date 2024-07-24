import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/data/data.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:collection/collection.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class Preparation extends StatefulWidget {
  @override
  _PreparationState createState() => _PreparationState();
}

class _PreparationState extends State<Preparation> {
  List<CheckListItem> _searchList = <CheckListItem>[];
  bool _previewTipVisibility = false;
  final Map<String, bool> _categoryTiles = {
    'Cat1': false,
    'Cat2': false,
    'Cat3': false,
    'Cat4': false,
    'Cat5': false,
    'Cat6': false,
    'Cat7': false,
    'Cat8': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchValues();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    //Call super.dispose before calling any asynchronous method,
    //otherwise it will immediately terminate the async method.
    _saveValues();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? true
            : false;
    Size _size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF496D47),
          statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          key: preparationKey,
          primary: false,
          resizeToAvoidBottomInset: false,
          body: FloatingSearchBar(
            title: const Text(
              'Preparations',
              style: TextStyle(
                color: Color(0xFF496D47),
                fontWeight: FontWeight.w700,
              ),
            ),
            iconColor: Color(0xFF496D47),
            scrollPadding: const EdgeInsets.symmetric(vertical: 10),
            automaticallyImplyBackButton: true,
            automaticallyImplyDrawerHamburger: false,
            transitionCurve: Curves.ease,
            transitionDuration: const Duration(milliseconds: 50),
            transition: CircularFloatingSearchBarTransition(),
            debounceDelay: Duration(milliseconds: 50),
            physics: const BouncingScrollPhysics(),
            axisAlignment: 0.0,
            openAxisAlignment: 0.0,
            width: double.infinity,
            border: BorderSide(width: 1, color: Color(0xFF496D47)),
            actions: [
              FloatingSearchBarAction.searchToClear(
                showIfClosed: true,
              ),
            ],
            clearQueryOnClose: true,
            onSubmitted: (currentText) {
              String searchQuery = currentText.toLowerCase();
              if (searchQuery.length != 0) {
                _searchList = fullList
                    .where(
                        (item) => item.name.toLowerCase().contains(searchQuery))
                    .toList(growable: false);
              } else {
                _searchList = <CheckListItem>[];
              }
              setState(() {});
            },
            builder: (context, transition) {
              return Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _searchList.isNotEmpty ? _searchList.length : 1,
                  itemBuilder: (context, index) {
                    if (_searchList.isEmpty) {
                      return Center(
                        child: Text('No Result'),
                      );
                    } else {
                      return CheckboxListTile(
                        activeColor: Color(0xFF496D47),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _searchList[index].value,
                        onChanged: (value) {
                          setState(() {
                            _searchList[index].value = value!;
                          });
                        },
                        title: AutoSizeText(
                          _searchList[index].name,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      );
                    }
                  },
                ),
              );
            },
            body: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: Color(0xFF496D47),
                ),
                unselectedWidgetColor: Colors.grey,
                dividerColor: Colors.transparent,
              ),
              child: ListTileTheme(
                contentPadding: const EdgeInsets.all(0),
                dense: true,
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    //48 Default floating search bar height
                    //6 = Default padding it applies
                    SizedBox(
                      height: 48.0 + 6.0,
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Center(
                        child: AutoSizeText(
                          'Mountain Biking Checklist',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF496D47),
                          ),
                          textAlign: TextAlign.center,
                          presetFontSizes: [28, 25, 20],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AutoSizeText.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Note: ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text:
                                  'This list is intentionally extensive. Not every rider will carry every item on every trip.',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Visibility(
                      visible: _previewTipVisibility,
                      child: Container(
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: AutoSizeText(
                            "Long press an item to see it's preview.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey1"),
                      //Keep it all false (Default is false).
                      //This causes the heavy load when navigating to this page.
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: const EdgeInsets.only(left: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            AutoSizeText(
                              "The Two Essentials",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              presetFontSizes: [22, 20, 18],
                            ),
                            AutoSizeText(
                              ' *',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                              presetFontSizes: [24, 22, 20],
                            ),
                          ],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat1', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey1'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: theTwoEssentials.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, theTwoEssentials[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: theTwoEssentials[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: theTwoEssentials[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    theTwoEssentials[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  theTwoEssentials[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey2"),
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: EdgeInsets.only(left: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            AutoSizeText(
                              "Core Gear",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              presetFontSizes: [22, 20, 18],
                            ),
                            AutoSizeText(
                              ' *',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                              presetFontSizes: [24, 22, 20],
                            ),
                          ],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat2', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey2'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: coreGear.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, coreGear[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: coreGear[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: coreGear[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    coreGear[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  coreGear[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey3"),
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      //maintainState: true,
                      tilePadding: const EdgeInsets.only(left: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            AutoSizeText(
                              "Core Repair Items",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              presetFontSizes: [22, 20, 18],
                            ),
                            const AutoSizeText(
                              ' *',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                              presetFontSizes: [24, 22, 20],
                            ),
                          ],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat3', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey3'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: coreRepairItems.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, coreRepairItems[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: coreRepairItems[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: coreRepairItems[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    coreRepairItems[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  coreRepairItems[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey4"),
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: EdgeInsets.only(left: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          "Clothing",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          presetFontSizes: [22, 20, 18],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat4', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey4'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: clothing.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, clothing[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: clothing[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: clothing[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    clothing[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  clothing[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey5"),
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: EdgeInsets.only(left: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          "Gear Options",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          presetFontSizes: [22, 20, 18],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat5', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey5'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: gearOptions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, gearOptions[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: gearOptions[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: gearOptions[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    gearOptions[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  gearOptions[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey6"),
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: EdgeInsets.only(left: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          "Repair-kit Options",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          presetFontSizes: [22, 20, 18],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat6', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey6'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: repairKitOptions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, repairKitOptions[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: repairKitOptions[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: repairKitOptions[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    repairKitOptions[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  repairKitOptions[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey7"),
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: EdgeInsets.symmetric(horizontal: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          "Free Riding Gear",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          presetFontSizes: [22, 20, 18],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat7', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey7'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: freeRidingGear.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, freeRidingGear[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: freeRidingGear[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: freeRidingGear[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    freeRidingGear[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  freeRidingGear[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      key: PageStorageKey("expansionTileKey8"),
                      //maintainState: true,
                      textColor: Color(0xFF496D47),
                      iconColor: Color(0xFF496D47),
                      tilePadding: EdgeInsets.symmetric(horizontal: 0),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          "Personal",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          presetFontSizes: [22, 20, 18],
                        ),
                      ),
                      onExpansionChanged: (bool newvalue) {
                        _updateExpansion('Cat8', newvalue);
                      },
                      children: [
                        GridView.builder(
                          key: PageStorageKey('gridViewKey8'),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                _size.height * (_isPortrait ? 0.006 : 0.012),
                            crossAxisCount: _isPortrait ? 2 : 3,
                          ),
                          itemCount: personal.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _showPreview(context, personal[index]);
                              },
                              child: CheckboxListTile(
                                activeColor: Color(0xFF496D47),
                                selected: personal[index].value,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: personal[index].value,
                                onChanged: (value) {
                                  setState(() {
                                    personal[index].value = value!;
                                  });
                                },
                                title: AutoSizeText(
                                  personal[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: !sosEnabled['Preparation']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  void _updateExpansion(String key, bool val) {
    setState(() {
      _categoryTiles[key] = val;
      _previewTipVisibility = _categoryTiles.containsValue(true) ? true : false;
    });
  }

  ///Too lazy to convert it into a widget.
  ///If you did. You have to write [showDialog]/[showModal] with its required parameters in every [GestureDetector]'s onLongPress callback.
  _showPreview(BuildContext context, CheckListItem item) {
    Size _size = MediaQuery.of(context).size;
    return showModal(
      configuration: FadeScaleTransitionConfiguration(
        barrierDismissible: true,
      ),
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          insetPadding: EdgeInsets.all(1),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _size.width * 0.9,
                  maxHeight: _size.height * 0.8,
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: _size.height * 0.75,
                            minWidth: _size.width * 0.80,
                          ),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        DefaultTextStyle(
                          style: TextStyle(color: Colors.grey),
                          child: Text.rich(
                            item.attribution ?? TextSpan(),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.close,
                            color: Color(0xFF496D47),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveValues() {
    theTwoEssentials.forEachIndexed((index, item) => StorageHelper.setBool(
        '${currentUser!.profileNumber}theTwoEssentials$index', item.value));
    coreGear.forEachIndexed((index, item) => StorageHelper.setBool(
        '${currentUser!.profileNumber}coreGear$index', item.value));
    coreRepairItems.forEachIndexed((index, item) => StorageHelper.setBool(
        '${currentUser!.profileNumber}coreRepairItems$index', item.value));
    clothing
      ..forEachIndexed((index, item) => StorageHelper.setBool(
          '${currentUser!.profileNumber}clothing$index', item.value));
    gearOptions
      ..forEachIndexed((index, item) => StorageHelper.setBool(
          '${currentUser!.profileNumber}gearOptions$index', item.value));
    repairKitOptions
      ..forEachIndexed((index, item) => StorageHelper.setBool(
          '${currentUser!.profileNumber}repairKitOptions$index', item.value));
    freeRidingGear
      ..forEachIndexed((index, item) => StorageHelper.setBool(
          '${currentUser!.profileNumber}freeRidingGear$index', item.value));
    personal
      ..forEachIndexed((index, item) => StorageHelper.setBool(
          '${currentUser!.profileNumber}personal$index', item.value));
  }

  void _fetchValues() {
    theTwoEssentials.forEachIndexed((index, item) =>
        theTwoEssentials[index].value = StorageHelper.getBool(
                '${currentUser!.profileNumber}theTwoEssentials$index') ??
            false);
    coreGear.forEachIndexed((index, item) => coreGear[index].value =
        StorageHelper.getBool('${currentUser!.profileNumber}coreGear$index') ??
            false);
    coreRepairItems.forEachIndexed((index, item) => clothing[index].value =
        StorageHelper.getBool(
                '${currentUser!.profileNumber}coreRepairItems$index') ??
            false);
    clothing.forEachIndexed((index, item) => clothing[index].value =
        StorageHelper.getBool('${currentUser!.profileNumber}clothing$index') ??
            false);
    gearOptions.forEachIndexed((index, item) => gearOptions[index].value =
        StorageHelper.getBool(
                '${currentUser!.profileNumber}gearOptions$index') ??
            false);
    repairKitOptions.forEachIndexed((index, item) =>
        repairKitOptions[index].value = StorageHelper.getBool(
                '${currentUser!.profileNumber}repairKitOptions$index') ??
            false);
    freeRidingGear.forEachIndexed((index, item) => freeRidingGear[index].value =
        StorageHelper.getBool(
                '${currentUser!.profileNumber}freeRidingGear$index') ??
            false);
    personal.forEachIndexed((index, item) => personal[index].value =
        StorageHelper.getBool('${currentUser!.profileNumber}personal$index') ??
            false);
  }
}
