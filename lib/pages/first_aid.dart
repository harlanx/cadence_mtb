import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/bmi_data.dart';
import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/pages/article_viewer.dart';
import 'package:cadence_mtb/pages/bmi_history.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

GlobalKey<ScaffoldState> firstAidKey = GlobalKey<ScaffoldState>();

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
    _filteredList = _firstAidItems;
    _onSort(_selectedSort);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFFF15024), statusBarIconBrightness: Brightness.light),
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
            titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
            hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
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
                                Text(e.value[0], style: TextStyle(color: Colors.white)),
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
                  await Hive.openBox<BMIData>('${currentUser!.profileNumber}bmiActivities').then((_) {
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
                  _filteredList = _firstAidItems;
                });
              }
            },
            onQueryChanged: (currentText) {
              String searchQuery = currentText.toLowerCase();
              if (searchQuery.length != 0) {
                List<ArticleItem> matchingResults = _firstAidItems
                    .where((injury) => injury.title.toLowerCase().contains(searchQuery) || injury.subtitle.toLowerCase().contains(searchQuery))
                    .toList(growable: false)
                      ..sort((a, b) => a.title.compareTo(b.title));
                if (matchingResults.isNotEmpty) {
                  _queriedList = matchingResults;
                } else {
                  _queriedList = [];
                }
              } else {
                setState(() {
                  _filteredList = _firstAidItems;
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

//Switch to Flutter Markdown in the Future!
//If you continue this kind of format I think it will be harder to maintain.
final List<ArticleItem> _firstAidItems = [
  ArticleItem(
    //BLEEDING
    image: 'assets/images/first_aid_previews/bleeding/injury.jpg',
    title: 'Bleeding',
    subtitle:
        'Bleeding, also called hemorrhage, is the name used to describe blood loss. It can refer to blood loss inside the body, called internal bleeding, or to blood loss outside of the body, called external bleeding.',
    widget: ListView(
      children: [
        Image.asset(
          'assets/images/first_aid_previews/bleeding/injury.jpg',
          height: 300,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'PrPom',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Bleeding_03.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons / Blood desaturated from original',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Bleeding, also called hemorrhage, is the name used to describe blood loss. It can refer to blood loss inside the body, called internal bleeding, or to blood loss outside of the body, called external bleeding.\n\nBlood loss can occur in almost any area of the body. Internal bleeding occurs when blood leaks out through a damaged blood vessel or organ. External bleeding happens when blood exits through a break in the skin.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/bleeding/treatment.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'PrPom',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Bleeding_01.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons / Blood desaturated from original',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'It’s possible to treat external traumatic bleeding. Seek emergency help if the person is having any of the emergency signs listed above and if you need help to stop the bleeding.\n\nThe person who’s bleeding should try to remain calm to keep their heart rate and blood pressure controlled. Either heart rate or blood pressure being too high will increase the speed of bleeding.\n\nLay the person down as soon as possible to reduce the risk of fainting, and try to elevate the area that’s bleeding.\n\nRemove loose debris and foreign particles from the wound. Leave large items such as knives, arrows, or weapons where they are. Removing these objects can cause further harm and will likely increase the bleeding. In this case, use bandages and pads to keep the object in place and absorb the bleeding.\n\nUse the following to put pressure onto the wound:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'a clean cloth',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'bandages',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'clothing',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'your hands (after applying protective gloves)\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Maintain medium pressure until the bleeding has slowed and stops.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Do not:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'remove the cloth when bleeding stops. Use an adhesive tape or clothing to wrap around the dressing and hold it in place. Then place a cold pack over the wound.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'look at the wound to see if bleeding has stopped. This can disturb the wound and cause it to begin bleeding again.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'remove the cloth from the wound, even if blood seeps through the material. Add more material on top, and continue the pressure.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'move anyone with an injury to the head, neck, back, or leg',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'apply pressure to an eye injury\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Use tourniquets only as a last resort. An experienced person should apply the tourniquet. To apply a tourniquet, follow these steps:\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '1. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Identify where to place the tourniquet. Apply it to a limb between the heart and the bleeding.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '2. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Make the tourniquet using bandages, if possible. Wrap them around the limb and tie a half knot. Ensure there is enough room to tie another knot with the loose ends.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '3. ',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Place a stick or rod between the two knots.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '4. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Twist the stick to tighten the bandage.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '5. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Secure the tourniquet in place with tape or cloth.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '6. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Check the tourniquet at least every 10 minutes. If the bleeding slows enough to be controlled with pressure, release the tourniquet and apply direct pressure instead.\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/bleeding/prevention.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Bigstones',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Mtb_knee_pads_and_elbow_pads.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 3.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/3.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons / Labels added from original',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'To prevent bleeding, avoid dangerous activities and interactions with sharp or coarse surfaces. Wear clothing to protect your arms, legs, and core, and be aware of your environment. If you do get a cut or scratch, clean and treat it immediately to prevent infection.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    //BRUISES AND FRACTURES
    image: 'assets/images/first_aid_previews/bruises_and_fractures/injury_2.jpg',
    title: 'Bruises and Fractures',
    subtitle:
        'A bruise is a common skin injury that results in a discoloration of the skin. Blood from damaged blood cells deep beneath the skin collects near the surface of the skin, resulting in what we think of as a black and blue mark. A fracture is a broken bone.',
    widget: ListView(
      children: [
        Row(
          children: [
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/bruises_and_fractures/injury_2.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/bruises_and_fractures/injury.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Sul6aN',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://en.wikipedia.org/wiki/File:Bruises.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 3.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/3.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Left)\n',
                ),
                TextSpan(
                    text: 'Wellcome Library',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:X-ray_of_a_broken_lower_leg_Wellcome_V0030072.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Right)',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'A bruise is a common skin injury that results in a discoloration of the skin. Blood from damaged blood cells deep beneath the skin collects near the surface of the skin, resulting in what we think of as a black and blue mark. A fracture is a broken bone. It can range from a thin crack to a complete break. Bone can fracture crosswise, lengthwise, in several places, or into many pieces. Most fractures happen when a bone is impacted by more force or pressure than it can support.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/bruises_and_fractures/treatment.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/bruises_and_fractures/treatment_2.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Injurymap',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:RICE_medicine.svg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Left)\n',
                ),
                TextSpan(
                    text: 'DataBase Center for Life Science (DBCLS)',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:202007_A_patient_undergoing_fracture_treatment.svg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Right)',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Doctors have no special treatment for bruises other than the techniques described above: ice packs and later heat, over-the-counter medications for pain, and elevation of the bruised area, if possible.\n\nIf you’re diagnosed with a fracture, the treatment plan will depend on its type and location.\n\nIn general, your doctor will try to put the broken bone pieces back into their proper positions and stabilize them as they heal. It’s important to keep pieces of broken bone immobile until they’re mended. During the healing process, new bone will form around the edges of the broken pieces. If they’re properly aligned and stabilized, the new bone will eventually connect the pieces.\n\nYour doctor may use a cast to stabilize your broken bone. Your cast will likely be made from plaster or fiberglass. It will help keep the injured area stabilized and prevent broken bone pieces from moving while they heal.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'To prevent a bruise:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'No matter how careful you are, you\'ll probably still get them from time to time. Wear protective gear like helmets and pads when playing contact sports, bicycling or riding a motorcycle.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'To prevent a fracture:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'You can’t prevent all fractures. But you can work to keep your bones strong so they’ll be less susceptible to damage. To maintain your bone strength, consume a nutritious diet, including foods that are rich in calcium and vitamin D. It’s also important to exercise regularly. Weight-bearing exercises are particularly helpful for building and maintaining bone strength. Examples include walking, hiking, running, dancing, and weight training.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    //CONCUSSION
    title: 'Concussion',
    subtitle:
        'Crashes happen. Sometimes, the only evidence is a few scrapes and bruises, but other times, the injuries are unfortunately much worse. If your head hit the ground on impact—and especially if you crack your helmet—you could have a concussion.',
    image: 'assets/images/first_aid_previews/concussion/injury.jpg',
    widget: ListView(
      children: [
        Image.asset(
          'assets/images/first_aid_previews/concussion/injury.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Scientific Animations',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Coup_injury.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Crashes happen. Sometimes, the only evidence is a few scrapes and bruises, but other times, the injuries are unfortunately much worse. If your head hit the ground on impact—and especially if you crack your helmet—you could have a concussion.\n\nA concussion is a traumatic brain injury that affects your brain function. Effects are usually temporary but can include headaches and problems with concentration, memory, balance and coordination.\n\nConcussions are usually caused by a blow to the head. Violently shaking of the head and upper body also can cause concussions.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Physical signs and symptoms of a concussion may include:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Headache',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Ringing in the ears',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Nausea',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Vomiting',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Fatigue or drowsiness',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Blurry vision\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Other signs and symptoms of a concussion include:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Confusion or feeling as if in a fog',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Amnesia surrounding the traumatic event',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Dizziness or "seeing stars"\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'A witness may observe these signs and symptoms in the concussed person:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Temporary loss of consciousness (though this doesn\'t always occur)',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Slurred speech',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Delayed response to questions',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Dazed appearance',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Forgetfulness, such as repeatedly asking the same question\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'After a crash, it’s common to experience some level of shock or even demand that you’re OK. But if you’re experiencing any of the symptoms above, it’s best not to get back on your bike and keep riding. Instead, figure out how to get out of the situation safely, whether it be calling for a ride home or heading to the hospital. Reaction time, balance, and thinking can be impaired, and you could have a higher risk to crash again.\n\nContact a medical provider immediately when possible.\n\nIf you are riding with someone who suffers a head injury and loses consciousness, here are a few precautions to take to ensure their safety until emergency medical services arrive:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Don’t move the injured person or leave them unattended.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Keep the helmet on and the head still to avoid further injury.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Take note of your location details to help EMS arrive faster.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Administer any first-aid treatment you feel comfortable with, including applying pressure to lacerations.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Be aware of common concussion symptoms and try not to overreact, which can cause panic and anxiety in the injured person.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Keep the person as calm as possible and answer any questions they may have calmly.\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'You also should avoid physical activities that increase any of your symptoms and only after you’ve been cleared by professional or a doctor should you resume any high-risk activities such as mountain biking.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/concussion/prevention.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Photo by Bicanski',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://pixnio.com/media/brake-equipment-helmet-mountain-bike-professional',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/publicdomain/zero/1.0/',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'on Pixnio',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Plain and simple, wearing a helmet is the number one, most important way to prevent a Traumatic Brain Injury. Make sure the equipment fits properly, is well maintained and is worn correctly. Doing so, can lower your risk of having a head injury. While helmets can’t always prevent a concussion, they do protect against more severe injuries like brain bleeds.\n\nYou can also educate others like your riding friends or family about concussions to help spread awareness.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    //CUTS AND SCRAPES
    title: 'Cuts and Scrapes (Abrasion)',
    subtitle:
        'Cuts and scrapes are areas of damage on the surface of the skin. A cut is a line of damage that can go through the skin and into the muscle tissues below, whereas a scratch is surface damage that does not penetrate the lower tissues.',
    image: 'assets/images/first_aid_previews/cuts_and_scrapes/injury.jpg',
    widget: ListView(
      children: [
        Row(
          children: [
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/cuts_and_scrapes/injury.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/cuts_and_scrapes/injury_2.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'ClockFace',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Laceration,_leg.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 3.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'http://creativecommons.org/licenses/by-sa/3.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Left)\n',
                ),
                TextSpan(
                    text: 'Zoe from Seattle, USA',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Road_rash_on_shoulder.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY 2.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by/2.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Right) / Blood desaturated from original',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Abrasions are common injuries among road athletes, typically caused by a fall or crash onto a hard surface. Cyclists will often refer to minor abrasions as "road rash," "friction burns," or "strawberries." In these scrapes, only the outermost layer of skin, called the epidermis, is affected. While there may be raw tissue and some minor bleeding, these injuries can often be treated sensibly with first aid.\n\nCuts and scratches are areas of damage on the surface of the skin. A cut is a line of damage that can go through the skin and into the muscle tissues below, whereas a scratch is surface damage that does not penetrate the lower tissues. Cuts and scratches may bleed or turn red, become infected, and leave scars.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'When to Seek Treatment',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'There is often a fine line between an injury that you can treat on your own and those you should have tended to by a doctor. Oftentimes, in the midst of a race or training, we make the wrong judgment and try to push through the pain, only to find ourselves dealing with a serious infection later. Generally speaking, you should seek medical attention if:\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'There is severe pain.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'It hurts to move the affected body part.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'There is a cut on the face larger than 1/4 inch.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'There is a cut on the body larger than 1/2 inch.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Bleeding is difficult to stop, whatever the size of the wound.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'A gaping wound remains open when relaxed.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'You see fat globules in the exposed tissues.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'You have a head injury, were unconscious, or are experiencing confusion, a lack of coordination, or memory loss.\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/cuts_and_scrapes/treatment.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Image by HeungSoon',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://pixabay.com/photos/bandage-gauze-treatment-medical-2671511',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ' from '),
                TextSpan(
                    text: 'Pixabay',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://pixabay.com/service/license',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'As a rule, any open wound should be treated within six hours of the injury.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Many road injuries are treatable at the site of the accident and, afterward, at home. If the wound doesn\'t require medical care, you can treat it as follows:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '1. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Stop the bleeding. Road rash tends to ooze rather than actively bleed. Apply pressure with a bandage until the bleeding stops.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '2. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Wash your hands with soap and water. Do this prior to treating the wound. This reduces the risk of infection.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '3. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Rinse the wound. Place it under a stream of cold water to flush out debris. If needed, use a pair of tweezers to remove embedded grit. Take care not to leave any debris in the wound.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '4. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Wash the skin around the wound with soap and water. Do your best to keep soap away from the wound as it can cause irritation. Dab lightly to dry with sterile gauze. Avoid hydrogen peroxide, which doctors advise against for open wounds.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '5. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Use a topical antibiotic. Options include bacitracin and neomycin, available at drugstores. While triple antibiotic ointments like Neosporin may be used, they can cause allergy in some people. You may also consider using sterilized honey, which has considerable evidence for wound care. Use medical-grade honey available over the counter and online, since there is a risk supermarket honey will contain bacterial spores.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '6. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Bandage the wound. You can do so with sterile gauze and some dressing tape. Alternately, you can use a semipermeable dressing such to cover the wound.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '7. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Change the dressing daily. The goal is to keep the wound clean but slightly moist. This not only prevents infection, but improves tissue formation and reduces the risk of scarring.\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/cuts_and_scrapes/prevention.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Andy Armstrong',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Mountain-biker-climbs.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 2.5',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/2.5',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'To prevent cuts and scratches, avoid dangerous activities and interactions with sharp or coarse surfaces. Wear clothing to protect your arms, legs, and core, and be aware of your environment. If you do get a cut or scratch, clean and treat it immediately to prevent infection.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    //DEHYDRATION
    title: 'Dehydration',
    subtitle:
        'Dehydration occurs when you use or lose more fluid than you take in, and your body doesn\'t have enough water and other fluids to carry out its normal functions. If you don\'t replace lost fluids, you will get dehydrated.',
    image: 'assets/images/first_aid_previews/dehydration/injury.jpg',
    widget: ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 15.0,
          ),
          child: Image.asset(
            'assets/images/first_aid_previews/dehydration/injury.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: AutoSizeText(
            'Dehydration occurs when you use or lose more fluid than you take in, and your body doesn\'t have enough water and other fluids to carry out its normal functions. If you don\'t replace lost fluids, you will get dehydrated.\n\nDehydration can occur in any age group if you don\'t drink enough water during hot weather — especially if you are doing an activity vigorously.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'There are 5 signs you are dehydrated:\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: AutoSizeText.rich(
                  TextSpan(
                    text: '• Elevated Heart Rate - ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'If you’re dehydrated on a ride, you might notice your heart rate spiking. Dehydration causes a decrease in blood volume, which results in the thickening of the blood and a decrease in the heart’s ability to supply fuel to our muscles.\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: AutoSizeText.rich(
                  TextSpan(
                    text: '• Feeling Lightheadedness or Dizzy - ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'The brain is 80% water, so even small changes in your body’s hydration levels can cause this symptom.  Additionally, it occurs when there’s not enough blood getting to your brain because without enough fluids in your body, the volume of your blood goes down and lowers your blood pressure.\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: AutoSizeText.rich(
                  TextSpan(
                    text: '• Headache - ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Your brain is encased within a fluid sack, a little like an internal helmet to protect it from bumping into the skull. If this watery helmet is shrinks, your brain can push up against the skull and cause some painful pressure.\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: AutoSizeText.rich(
                  TextSpan(
                    text: '• Dry and Stiff Skin - ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Since sweat production decreases during dehydration in an effort to retain fluid, body temperature rises. That can cause your skin to appear dry or less elastic (if you pinch yourself, the skin won’t snap back into place) as your body tries to direct water content to the vital organs versus less vital areas.\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: AutoSizeText.rich(
                  TextSpan(
                    text: '• Alarming Urine Color and Smell - ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'The color and smell of urine come from the filtered waste products of the kidneys. As the body becomes dehydrated, and there’s less water to dilute the waste products, the urine excreted gradually becomes more concentrated and thus darker.\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/dehydration/treatment.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Videoplasty.com',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Man_Drinking_Water_Cartoon.svg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons / Background added and eyes closed from original.',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Dehydration must be treated by replenishing the fluid level in the body. This can be done by consuming clear fluids such as water, clear broths, frozen water or ice pops, or sports drinks (such as Gatorade). People who are dehydrated should avoid drinks containing caffeine such as coffee, tea, and sodas.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/dehydration/prevention.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by RzlBrz007700',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        firstAidKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/mountain-bike-water-bottle-detail-1073424',
                            purpose: 3,
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        firstAidKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                            purpose: 3,
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' / Bottle label removed'),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'People should be cautious about doing activities during extreme heat or the hottest part of the day, and anyone who is exercising should make replenishing fluids a priority. Bring a water bottle, keep it nearby and take a drink whenever thirst strikes. Try to drink water regularly throughout the day so you never reach that level.  In addition to drinking regularly on the bike, you can combat dehydration through pre-hydration. Before you start your next ride, down two cups of fluid in the 15 minutes before you head out.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    //INSECT BITES
    title: 'Insect Bites',
    subtitle:
        'Most reactions to insect bites and stings are mild, causing little more than redness, itching, stinging or minor swelling. Often, they are not serious and will get better within a few hours or days.',
    image: 'assets/images/first_aid_previews/insect_bites/injury.jpg',
    widget: ListView(
      children: [
        Row(
          children: [
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/insect_bites/injury.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/insect_bites/injury_2.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'NiaPol',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link:
                                  'https://commons.wikimedia.org/wiki/File:Bites_of_a_blood-sucking_insect_(Tabanidae)_on_the_shins_of_an_adult._003.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Left)\n',
                ),
                TextSpan(
                    text: 'Enochlau',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Rash.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 3.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'http://creativecommons.org/licenses/by-sa/3.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Right)',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Most reactions to insect bites and stings are mild, causing little more than redness, itching, stinging or minor swelling. Often, they are not serious and will get better within a few hours or days. Rarely, insect bites and stings, such as from a bee, a wasp, a hornet, a fire ant or a scorpion, can result in severe allergic reactions or spread serious illnesses.\n\nSometimes, it may be hard to tell which type of insect has caused the skin injury, as many insect reactions are similar. Flying insects tend to bite any exposed skin areas, while bugs such as fleas tend to bite the lower legs and around the waist and often have several bites grouped together.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Seek emergency care if you or the injured person experiences:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Difficulty breathing',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Swelling of the lips, eyelids or throat',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Dizziness, faintness or confusion',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Rapid heartbeat',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Hives (Rash)',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Nausea, cramps or vomiting',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'A scorpion sting and is a child\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 15.0,
          ),
          child: Image.asset(
            'assets/images/first_aid_previews/insect_bites/treatment.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: AutoSizeText(
            'To take care of an insect bite or sting that causes a mild reaction:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Move to a safe area to avoid more bites or stings.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'If needed, remove the stinger.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Wash the area with soap and water.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Apply a cool compress. Use a cloth dampened with cold water or filled with ice. This helps reduce pain and swelling. If the injury is on an arm or leg, elevate it.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Apply 0.5 or 1 percent hydrocortisone cream, calamine lotion or a baking soda paste to the bite or sting several times daily until your symptoms go away.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Take an antihistamine (Benadryl, others) to reduce itching.\n',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Usually, the signs and symptoms of a bite or sting disappear in a day or two. If you\'re concerned — even if your reaction is minor — call your doctor.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 15.0,
          ),
          child: Image.asset(
            'assets/images/first_aid_previews/insect_bites/prevention.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: AutoSizeText(
            'To help prevent bug bites, dermatologists recommend the following tips: Use insect repellent. To protect against mosquitoes, ticks and other bugs, use insect repellent that contains 20 to 30 percent DEET on exposed skin and clothing. Wear appropriate clothing if you are going through a woody area, preferably long sleeve and lastly, pay attention to outbreaks.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    //SPRAIN
    title: 'Sprain',
    subtitle:
        'A sprain is a stretching injury to ligaments (the bands of tough tissue that control which direction joints can bend). A minor sprain may swell slightly, but does not significantly interfere with using the injured part.',
    image: 'assets/images/first_aid_previews/sprain/injury.jpg',
    widget: ListView(
      children: [
        Row(
          children: [
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/sprain/injury.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/images/first_aid_previews/sprain/injury_2.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Laboratoires Servier',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Ankle_sprain_--_Smart-Servier.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 3.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/3.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Left)\n',
                ),
                TextSpan(
                    text: 'Thomas Steiner',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Baenderriss.jpg',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 2.5',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/2.5',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons (Right)',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'A sprain is a stretching injury to ligaments (the bands of tough tissue that control which direction joints can bend). A minor sprain may swell slightly, but does not significantly interfere with using the injured part. Bruising in the area of the sprain indicates tearing of ligament tissue. Sprains can be serious if the ligament is ruptured.\n\nMost ankle sprains occur, not while crashing, but when stepping off the bike or walking alongside the bike. In adults, the sprain occurs when the foot lands on a log or rock, and the foot tips inward.\n\nIn children, ankle sprains occur when riding a bike that\'s too big. As the child tries to step off, the bike must tilt far to the side before the foot can touch down. (The child\'s body also travels sideways as the bike tips.) This lateral motion causes the ankle to pull under when the foot touches the road.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Treatment',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/sprain/treatment.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'BruceBlaus',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Foot_Care_Ankle_Wrap.png',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'As soon as possible after an injury, such as a knee or ankle sprain, you can relieve pain and swelling and promote healing and flexibility with "R.I.C.E." Rest, Ice, Compress, and Elevate. Immediately elevate the injured part and apply an ice bag.\n',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText.rich(
                      TextSpan(
                        text: 'Rest - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Avoid activities that cause pain, swelling or discomfort.',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText.rich(
                      TextSpan(
                        text: 'Ice - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Use an ice pack or ice slush bath immediately for 15 to 20 minutes and repeat every two to three hours while you\'re awake. If you have vascular disease, diabetes or decreased sensation, talk with your doctor before applying ice.',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText.rich(
                      TextSpan(
                        text: 'Compression - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'To help stop swelling, compress the ankle with an elastic bandage until the swelling stops. Don\'t hinder circulation by wrapping too tightly. Begin wrapping at the end farthest from your heart.',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText.rich(
                      TextSpan(
                        text: 'Elevation - ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'To reduce swelling, elevate your ankle above the level of your heart, especially at night. Gravity helps reduce swelling by draining excess fluid.\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(
            'Prevention',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Image.asset(
          'assets/images/first_aid_previews/sprain/prevention.jpg',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'BruceBlaus',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Exercise_Ankle_Rotation.png',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          firstAidKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                              purpose: 3,
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'via Wikimedia Commons',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'It is possible to prevent many sprains from occurring.\n\nThe following suggestions can help to reduce one\'s injury risk:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Stretch before and after you ride.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Always wear properly fitting shoes.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Warm up before any sports activity, including practice.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Use or wear protective equipment appropriate for mountain biking.',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: AutoSizeText(
                      'Do not ride if overly tired or in pain.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
];
