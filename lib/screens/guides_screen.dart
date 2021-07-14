import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/data/data.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_view_indicators/page_view_indicators.dart';
part 'guides_screen/rules_of_the_trail_dialog.dart';
part 'guides_screen/guides_button.dart';


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
                  guidesItem.length,
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
    guidesItem[1].title = isPortrait ? 'Body\nConditioning' : 'Body Conditioning';
    guidesItem[2].title = isPortrait ? 'Repair and\nMaintenance' : 'Repair and Maintenance';
  }
}

