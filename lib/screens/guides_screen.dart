import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/pages/body_conditioning.dart';
import 'package:cadence_mtb/pages/organizations.dart';
import 'package:cadence_mtb/pages/preparation.dart';
import 'package:cadence_mtb/pages/repair_and_maintenance.dart';
import 'package:cadence_mtb/pages/tips_and_benefits.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_view_indicators/page_view_indicators.dart';

class GuidesScreen extends StatefulWidget {
  @override
  GuidesScreenState createState() => GuidesScreenState();
}

class GuidesScreenState extends State<GuidesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size _size = MediaQuery.of(context).size;
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    _updateButtonLabel(_isPortrait);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 15,
            child: Ink(
              decoration: BoxDecoration(
                color: Color(0xFF496D47),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).scaffoldBackgroundColor.darken(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: InkWell(
                splashColor: Color(0xFF496D47).darken(0.1).withOpacity(0.8),
                highlightColor: Colors.transparent,
                onTap: () => showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(barrierDismissible: true),
                  builder: (_) => RulesOfTheTrailDialog(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: _isPortrait ? 30 : 60,
                      child: SizedBox.expand(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                          child: SvgPicture.asset(
                            _isPortrait
                                ? 'assets/icons/guides_dashboard/rules_of_the_trail_vertical.svg'
                                : 'assets/icons/guides_dashboard/rules_of_the_trail_horizontal.svg',
                            fit: BoxFit.contain,
                            height: _isPortrait ? 103 : 70,
                            width: _isPortrait ? 224 : 449,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: _isPortrait ? 70 : 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'BillyOhio',
                                fontSize: 20,
                              ),
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  RotateAnimatedText(
                                    '📍Ride On Open Trails Only.',
                                    duration: const Duration(seconds: 3),
                                    alignment: Alignment.centerRight,
                                    transitionHeight: 50,
                                  ),
                                  RotateAnimatedText(
                                    '🚯Leave No Trace.',
                                    duration: const Duration(seconds: 3),
                                    alignment: Alignment.centerRight,
                                    transitionHeight: 50,
                                  ),
                                  RotateAnimatedText(
                                    '🚵Control Your Bicycle.',
                                    duration: const Duration(seconds: 3),
                                    alignment: Alignment.centerRight,
                                    transitionHeight: 50,
                                  ),
                                  RotateAnimatedText(
                                    '🚸Yield To Others.',
                                    duration: const Duration(seconds: 3),
                                    alignment: Alignment.centerRight,
                                    transitionHeight: 50,
                                  ),
                                  RotateAnimatedText(
                                    '🐾Never Scare Animals.',
                                    duration: const Duration(seconds: 3),
                                    alignment: Alignment.centerRight,
                                    transitionHeight: 50,
                                  ),
                                  RotateAnimatedText(
                                    '📋Plan Ahead.',
                                    duration: const Duration(seconds: 3),
                                    alignment: Alignment.centerRight,
                                    transitionHeight: 50,
                                  ),
                                ],
                                onTap: () => showModal(
                                  context: context,
                                  configuration: FadeScaleTransitionConfiguration(barrierDismissible: true),
                                  builder: (_) => RulesOfTheTrailDialog(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 85,
            child: Container(
              padding: EdgeInsets.only(top: _size.height * 0.035),
              child: Column(
                children: List.generate(
                  _guidesItem.length,
                  (index) => GuidesButton(index: index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _updateButtonLabel(bool isPortrait) {
    _guidesItem[1].title = isPortrait ? 'Body\nConditioning' : 'Body Conditioning';
    _guidesItem[2].title = isPortrait ? 'Repair and\nMaintenance' : 'Repair and Maintenance';
  }
}

class RulesOfTheTrailDialog extends StatelessWidget {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.all(1.0),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13.0),
        ),
        height: _size.height * 0.6,
        width: _size.width * 0.9,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: _size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(13.0),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF496D47),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 30,
                          child: FittedBox(
                            child: SvgPicture.asset(
                              'assets/icons/guides_dashboard/imba_logo.svg',
                              color: Colors.white,
                              height: 80,
                              width: 272,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 70,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: AutoSizeText(
                              'Rules of the Trail',
                              wrapWords: true,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(0xFF496D47),
                    width: double.infinity,
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: Container(
                    height: double.maxFinite,
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Center(
                      child: const AutoSizeText(
                        'IMBA developed the "Rules of the Trail" to promote responsible and courteous conduct on shared-use trails.',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Color(0xFF496D47),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 73,
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: _rOTTItem.length + 1,
                    itemBuilder: (BuildContext context, int index) => _buildRottItem(context, index),
                    onPageChanged: (int index) {
                      _currentIndex.value = index;
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: CirclePageIndicator(
                      dotColor: Colors.grey,
                      selectedDotColor: Color(0xFF496D47),
                      itemCount: _rOTTItem.length + 1,
                      currentPageNotifier: _currentIndex,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: const Alignment(1.05, -1.05),
              child: Material(
                clipBehavior: Clip.antiAlias,
                shape: CircleBorder(),
                child: Ink(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF496D47),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRottItem(BuildContext context, int index) {
    final ScrollController _scrollController = ScrollController();
    if (index <= 5) {
      return Container(
        child: Column(
          children: [
            Expanded(
              flex: 30,
              child: Center(
                child: AutoSizeText(
                  _rOTTItem[index].rule,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: Color(0xFF496D47),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 70,
              child: Container(
                child: Scrollbar(
                  isAlwaysShown: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: AutoSizeText(
                          _rOTTItem[index].description,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF496D47),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              flex: 70,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: AutoSizeText(
                    'Keep trails open by setting a good example of environmentally sound and socially responsible off-road cycling.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: Color(0xFF496D47),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 15,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: 'For more information,\n',
                    children: [
                      WidgetSpan(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomRoutes.fadeThrough(
                                page: AppBrowser(
                                  link: 'https://www.imba.com/explore-imba/meet-imba/',
                                ),
                              ),
                            );
                          },
                          child: AutoSizeText(
                            "visit the webpage of IMBA.",
                            maxLines: 1,
                            style: TextStyle(
                              shadows: [const Shadow(color: Color(0xFF496D47), offset: Offset(0, -5))],
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF496D47).darken(0.1),
                              decorationThickness: 2,
                              fontWeight: FontWeight.w700,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF496D47),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class GuidesButton extends StatelessWidget {
  const GuidesButton({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Expanded(
      flex: 10,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, _size.height * 0.035),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Color(0xFF496D47).darken(0.1).withOpacity(0.8),
          onTap: () {
            Navigator.push(context, CustomRoutes.fadeThrough(page: _guidesItem[index].page, duration: Duration(milliseconds: 300)));
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _isPortrait ? 20 : 10,
              ),
              color: Color(0xFF496D47),
            ),
            height: _size.height * 0.10,
            child: index.isOdd
                ? Row(
                    children: [
                      Expanded(
                        flex: 20,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: _isPortrait ? 20.0 : 2.0,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              _guidesItem[index].iconPath,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 74,
                        child: Ink(
                          padding: const EdgeInsets.all(5),
                          height: double.infinity,
                          color: const Color(0xFF496D47).darken(0.1),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Center(
                              child: Text(
                                _guidesItem[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(flex: 6, child: SizedBox())
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(flex: 6, child: SizedBox()),
                      Expanded(
                        flex: 74,
                        child: Ink(
                          padding: const EdgeInsets.all(5),
                          height: double.infinity,
                          color: Color(0xFF496D47).darken(0.1),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Center(
                              child: Text(
                                _guidesItem[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: _isPortrait ? 20.0 : 2.0,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              _guidesItem[index].iconPath,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

List<GuidesList> _guidesItem = [
  GuidesList(
    title: 'Preparations',
    iconPath: 'assets/icons/guides_dashboard/preparations.svg',
    page: Preparation(),
  ),
  GuidesList(
    title: '',
    iconPath: 'assets/icons/guides_dashboard/body_conditioning.svg',
    page: BodyConditioning(),
  ),
  GuidesList(
    title: '',
    iconPath: 'assets/icons/guides_dashboard/repair_and_maintenance.svg',
    page: RepairAndMaintenance(),
  ),
  GuidesList(
    title: 'Tips and Benefits',
    iconPath: 'assets/icons/guides_dashboard/tips_and_benefits.svg',
    page: TipsAndBenefits(),
  ),
  GuidesList(
    title: 'Organizations',
    iconPath: 'assets/icons/guides_dashboard/organizations.svg',
    page: Organizations(),
  ),
];

final List<RulesOfTheTrail> _rOTTItem = [
  RulesOfTheTrail(
    rule: 'Ride on Open Trails Only',
    description:
        'Respect trail and road closures - ask a land manager for clarification if you are uncertain about the status of a trail.\n\nDo not trespass on private land. Obtain permits or other authorization as may be required.\n\nBe aware that bicycles are not permitted in areas protected as state or federal Wilderness.',
  ),
  RulesOfTheTrail(
    rule: 'Leave No Trace',
    description:
        "Be sensitive to the dirt beneath you. Wet and muddy trails are more vulnerable to damage than dry ones.\n\nWhen the trail is soft, consider other riding options. This also means staying on existing trails and not creating new ones.\n\nDon't cut switchbacks. Be sure to pack out at least as much as you pack in.",
  ),
  RulesOfTheTrail(
    rule: 'Control Your Bicycle',
    description:
        'Inattention for even a moment could put yourself and others at risk.\n\nObey all bicycle speed regulations and recommendations, and ride within your limits.',
  ),
  RulesOfTheTrail(
    rule: 'Yield to Others',
    description:
        "Do your utmost to let your fellow trail users know you're coming -- a friendly greeting or bell ring are good methods.\n\nTry to anticipate other trail users as you ride around corners. Bicyclists should yield to all other trail users, unless the trail is clearly signed for bike-only travel.\n\nBicyclists traveling downhill should yield to ones headed uphill, unless the trail is clearly signed for one-way or downhill-only traffic.\n\nStrive to make each pass a safe and courteous one.",
  ),
  RulesOfTheTrail(
    rule: 'Never Scare Animals',
    description:
        'Animals are easily startled by an unannounced approach, a sudden movement or a loud noise. \n\nGive animals enough room and time to adjust to you. When passing horses, use special care and follow directions from the horseback riders (ask if uncertain).\n\nRunning farm animals and disturbing wildlife are serious offenses.',
  ),
  RulesOfTheTrail(
    rule: 'Plan Ahead',
    description:
        'Know your equipment, your ability and the area in which you are riding -- and prepare accordingly.\n\nStrive to be self-sufficient: keep your equipment in good repair and carry necessary supplies for changes in weather or other conditions.\n\nAlways wear a helmet and appropriate safety gear.',
  ),
];
