import 'dart:math' as math;
import 'package:cadence_mtb/models/bike_build.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Goodluck maintaining this. Looks simple by just looking at the UI but man its coding gave me a headache for days.
class BikeEditor extends StatefulWidget {
  final List<BikeBuild>? projectList;
  //If you provide an index, that means you are just editting an existing project.
  final int? index;

  BikeEditor({this.projectList, this.index});
  @override
  _BikeEditorState createState() => _BikeEditorState();
}

class _BikeEditorState extends State<BikeEditor> {
  List<BikeBuild> bikeProjects = [];
  String projectName = '';
  bool hideLayer = false;
  int activeLayer = 1;
  double currentAngle = 0.0;
  double currentXAxis = 0.0;
  double currentYAxis = 0.0;
  GlobalKey<ScaffoldState> _bikeEditorKey = GlobalKey<ScaffoldState>();
  TransformationController _transformationController = TransformationController();
  //These are the default values
  //Transform.rotate uses -6.28319 to 6.28319 radians value.
  //6.28319 radians = 360 degrees and -1.000000358 radian = -57.2958 degrees
  String brakeClprCode = 'a1a';
  Alignment brakeClprPosFront = Alignment(0.518, 0.255);
  Alignment brakeClprPosRear = Alignment(-0.512, 0.278);
  double brakeClprAngleFront = -20.053;
  double brakeClprAngleRear = 98;

  String cassetteCode = 'b1a';
  Alignment cassettePos = Alignment(-0.63, 0.304);
  double cassetteAngle = 0;

  String cranksetCode = 'c3b';
  Alignment cranksetPos = Alignment(-0.124, 0.5);
  double cranksetAngle = 42.971;

  String frameCode = 'd2b';
  Alignment framePos = Alignment(-0.232, -0.49);
  double frameAngle = 0;

  String frontDlrCode = 'e1a';
  Alignment frontDlrPos = Alignment(-0.215, 0.225);
  double frontDlrAngle = -22.34;

  String frontForkCode = 'f1c';
  Alignment frontForkPos = Alignment(0.492, -0.376);
  double frontForkAngle = -20.053;

  String handlebarCode = 'g2a';
  Alignment handlebarPos = Alignment(0.358, -0.976);
  double handlebarAngle = -21.772;

  String pedalCode = 'h2a';
  Alignment pedalPos = Alignment(-0.018, 0.566);
  double pedalAngle = 0;

  String rearDlrCode = 'i1a';
  Alignment rearDlrPos = Alignment(-0.665, 0.583);
  double rearDlrAngle = 3.151;

  String rimCode = 'k2a';
  Alignment rimPosFront = Alignment(0.888, 0.67);
  Alignment rimPosRear = Alignment(-0.888, 0.67);
  double rimAngleFront = 0;
  double rimAngleRear = 0;

  String saddleCode = 'j1a';
  Alignment saddlePos = Alignment(-0.33, -0.99);
  double saddleAngle = -18.334;

  String tireCode = 'l1b';
  Alignment tirePosFront = Alignment(0.97, 0.89);
  Alignment tirePosRear = Alignment(-0.97, 0.89);
  double tireAngleFront = 0;
  double tireAngleRear = 0;

  String bellCode = 'q1a';
  Alignment bellPos = Alignment(0.355, -0.968);
  double bellAngle = 0;

  String bottleCageCode = 'm1a';
  Alignment bottleCagePos = Alignment(0.0286, -0.23);
  double bottleCageAngle = 36.096;

  String fenderCode = 'n1a';
  Alignment fenderPosFront = Alignment(0.466, -0.336);
  Alignment fenderPosRear = Alignment(-0.428, -0.31);
  double fenderAngleFront = -22.918;
  double fenderAngleRear = 35.523;

  String kickstandCode = 'p1a';
  Alignment kickstandPos = Alignment(-0.48, 0.81);
  double kickstandAngle = -22;

  String lightCode = 'o1b';
  Alignment lightPosFront = Alignment(0.398, -0.954);
  Alignment lightPosRear = Alignment(-0.332, -0.641);
  double lightAngleFront = 0;
  double lightAngleRear = -15.297;

  String phoneHolderCode = 'r1a';
  Alignment phoneHoldePos = Alignment(0.186, -0.858);
  double phoneHoldeAngle = -17.800;

  String chainAdvanced = 'assets/images/bike_project/bike_parts/chain_advanced.png';
  Alignment chainAdvancedPos = Alignment(-0.51, 0.573);
  double chainAdvancedAngle = 1.145;

  String chainBasic = 'assets/images/bike_project/bike_parts/chain_basic.png';
  Alignment chainBasicPos = Alignment(0, 0);
  double chainBasicAngle = 0;

  String brakeDisc = 'assets/images/bike_project/bike_parts/disc.png';
  Alignment brakeDiscPosFront = Alignment(0.65, 0.334);
  Alignment brakeDiscPosRear = Alignment(-0.65, 0.334);
  double brakeDiscAngleFront = 0;
  double brakeDiscAngleRear = 0;

  Map<int, bool> layerVisibility = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: true,
    8: true,
    9: true,
    10: true,
    11: true,
    12: true,
    13: true,
    14: true,
    15: true,
    16: true,
    17: true,
    18: true,
    19: true,
    20: true,
    21: true,
    22: true,
    23: true,
    24: true,
    25: true,
    26: true,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    // Sets the control values when loaded
    getProjectsDetails();
    getLayerValues(activeLayer);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      key: _bikeEditorKey,
      primary: false,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawerEnableOpenDragGesture: false,
      onDrawerChanged: (isOpen){
        if(!isOpen){
          SystemChrome.setEnabledSystemUIOverlays([]);
        }
      },
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFFFF8B02),
          accentColor: Colors.white,
          textTheme: TextTheme(
            subtitle1: TextStyle(
              fontFamily: 'Comfortaa',
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          unselectedWidgetColor: Colors.black,
          dividerColor: Colors.white,
        ),
        child: SizedBox(
          width: _size.width * 0.30,
          child: Drawer(
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Project Name:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextFormField(
                        initialValue: projectName,
                        onChanged: (val) {
                          setState(() {
                            projectName = val;
                          });
                        },
                        decoration: InputDecoration(
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                ExpansionTile(
                  title: Text('Brake Caliper'),
                  children: brakeCaliperItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == brakeClprCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == brakeClprCode
                          ? null
                          : () {
                              if (activeLayer != 2) {
                                activeLayer = 1;
                                getLayerValues(1);
                              }
                              setState(() {
                                brakeClprCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Cassette'),
                  children: cassetteItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.speed,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == cassetteCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == cassetteCode
                          ? null
                          : () {
                              activeLayer = 3;
                              getLayerValues(3);
                              setState(() {
                                cassetteCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Crankset'),
                  children: cranksetItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.speed,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == cranksetCode
                          ? Colors.white.withOpacity(0.2)
                          : frameItems.where((element) => element.code == frameCode).first.frontDerailleurTypes.isEmpty && e.speed != '1 Speed'
                              ? Colors.black.withOpacity(0.8)
                              : Colors.transparent,
                      onTap: e.code == cranksetCode ||
                              (frameItems.where((element) => element.code == frameCode).first.frontDerailleurTypes.isEmpty && e.speed != '1 Speed')
                          ? null
                          : () {
                              activeLayer = 4;
                              getLayerValues(4);
                              setState(() {
                                cranksetCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Frame'),
                  children: frameItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == frameCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == frameCode
                          ? null
                          : () {
                              activeLayer = 5;
                              getLayerValues(5);
                              frameCode = e.code;
                              if (e.frontDerailleurTypes.isEmpty) {
                                if (cranksetCode != 'c1a' || cranksetCode != 'c1b') {
                                  cranksetCode = 'c1a';
                                }
                              }
                              setState(() {});
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Front Derailleur'),
                  children: frontDlrItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == frontDlrCode &&
                              frameItems.where((element) => element.code == frameCode).first.frontDerailleurTypes.contains(e.type)
                          ? Colors.white.withOpacity(0.2)
                          : !frameItems.where((element) => element.code == frameCode).first.frontDerailleurTypes.contains(e.type)
                              ? Colors.black.withOpacity(0.8)
                              : Colors.transparent,
                      onTap: e.code == frontDlrCode ||
                              !frameItems.where((element) => element.code == frameCode).first.frontDerailleurTypes.contains(e.type)
                          ? null
                          : () {
                              activeLayer = 6;
                              getLayerValues(6);
                              setState(() {
                                frontDlrCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Front Fork'),
                  children: frontForkItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.sizeType,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == frontForkCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: () {
                        activeLayer = 7;
                        getLayerValues(7);
                        frontForkCode = e.code;
                        bool isCurrentFork29er = frontForkItems.where((element) => element.code == frontForkCode).first.sizeType == '29er';
                        bool isCurrentRim29er = rimItems.where((element) => element.code == rimCode).first.sizeType == '29er';
                        if (isCurrentRim29er != isCurrentFork29er) {
                          rimCode = 'k1a';
                          if (!isCurrentRim29er) {
                            rimCode = 'k2a';
                          }
                        }
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Handlebar'),
                  children: handlebarItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == handlebarCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == handlebarCode
                          ? null
                          : () {
                              activeLayer = 8;
                              getLayerValues(8);
                              setState(() {
                                handlebarCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Pedal'),
                  children: pedalItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == pedalCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == pedalCode
                          ? null
                          : () {
                              activeLayer = 9;
                              getLayerValues(9);
                              setState(() {
                                pedalCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Rear Derailleur'),
                  children: rearDlrItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == rearDlrCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == rearDlrCode
                          ? null
                          : () {
                              activeLayer = 10;
                              getLayerValues(10);
                              setState(() {
                                rearDlrCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Saddle'),
                  children: saddleItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == saddleCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == saddleCode
                          ? null
                          : () {
                              activeLayer = 11;
                              getLayerValues(11);
                              setState(() {
                                saddleCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Rim'),
                  children: rimItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.sizeType,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == rimCode
                          ? Colors.white.withOpacity(0.2)
                          : e.sizeType != frontForkItems.where((element) => element.code == frontForkCode).first.sizeType
                              ? Colors.black.withOpacity(0.8)
                              : Colors.transparent,
                      onTap: e.code == rimCode || e.sizeType != frontForkItems.where((element) => element.code == frontForkCode).first.sizeType
                          ? null
                          : () {
                              if (activeLayer != 13) {
                                activeLayer = 12;
                                getLayerValues(12);
                              }
                              setState(() {
                                rimCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Tire'),
                  children: tireItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.type,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: AppBrowser(
                                    link: e.link,
                                    purpose: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.blue.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      tileColor: e.code == tireCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == tireCode
                          ? null
                          : () {
                              if (activeLayer != 15) {
                                activeLayer = 14;
                                getLayerValues(14);
                              }
                              setState(() {
                                tireCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                ExpansionTile(
                  title: Text('Bell'),
                  children: bellItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      tileColor: e.code == bellCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == bellCode
                          ? null
                          : () {
                              activeLayer = 16;
                              getLayerValues(16);
                              setState(() {
                                bellCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Bottle Cage'),
                  children: bottleCageItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      tileColor: e.code == bottleCageCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == bottleCageCode
                          ? null
                          : () {
                              activeLayer = 17;
                              getLayerValues(17);
                              setState(() {
                                bottleCageCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Fender'),
                  children: fenderItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      tileColor: e.code == fenderCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == fenderCode
                          ? null
                          : () {
                              if (activeLayer != 19) {
                                activeLayer = 18;
                                getLayerValues(18);
                              }
                              setState(() {
                                fenderCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Kickstand'),
                  children: kickstandItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      tileColor: e.code == kickstandCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == kickstandCode
                          ? null
                          : () {
                              activeLayer = 20;
                              getLayerValues(20);
                              setState(() {
                                kickstandCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Light'),
                  children: lightItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      tileColor: e.code == lightCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == lightCode
                          ? null
                          : () {
                              if (activeLayer != 22) {
                                activeLayer = 21;
                                getLayerValues(21);
                              }
                              setState(() {
                                lightCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Text('Phone Holder'),
                  children: phoneHolderItems.map((e) {
                    return ListTile(
                      leading: Image.asset(
                        brandImage(e.brand),
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        e.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      tileColor: e.code == phoneHolderCode ? Colors.white.withOpacity(0.2) : Colors.transparent,
                      onTap: e.code == phoneHolderCode
                          ? null
                          : () {
                              activeLayer = 23;
                              getLayerValues(23);
                              setState(() {
                                phoneHolderCode = e.code;
                              });
                            },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          //================================================================================================================================
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(50),
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 2.0,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      //Stack arrangment is where bottom is the top most layer which is not similar to photoshop layer arrangement
                      //Kickstand
                      Visibility(
                        visible: layerVisibility[20]!,
                        child: Align(
                          alignment: kickstandPos,
                          child: Transform.rotate(
                            angle: kickstandAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: kickstandItems.where((element) => element.code == kickstandCode).first.sizeFactorFront,
                              child: Image.asset(
                                kickstandItems.where((element) => element.code == kickstandCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Disc
                      Visibility(
                        visible: layerVisibility[25]!,
                        child: Align(
                          alignment: brakeDiscPosRear,
                          child: Transform.rotate(
                            angle: brakeDiscAngleRear * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: 0.094,
                              child: Image.asset(
                                brakeDisc,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Disc
                      Visibility(
                        visible: layerVisibility[24]!,
                        child: Align(
                          alignment: brakeDiscPosFront,
                          child: Transform.rotate(
                            angle: brakeDiscAngleFront * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: 0.094,
                              child: Image.asset(
                                brakeDisc,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Brake Caliper
                      Visibility(
                        visible: layerVisibility[2]!,
                        child: Align(
                          alignment: brakeClprPosRear,
                          child: Transform.rotate(
                            angle: brakeClprAngleRear * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: brakeCaliperItems.where((element) => element.code == brakeClprCode).first.sizeFactor,
                              child: Image.asset(
                                brakeCaliperItems.where((element) => element.code == brakeClprCode).first.rearImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Brake Caliper
                      Visibility(
                        visible: layerVisibility[1]!,
                        child: Align(
                          alignment: brakeClprPosFront,
                          child: Transform.rotate(
                            angle: brakeClprAngleFront * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: brakeCaliperItems.where((element) => element.code == brakeClprCode).first.sizeFactor,
                              child: Image.asset(
                                brakeCaliperItems.where((element) => element.code == brakeClprCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Rim
                      Visibility(
                        visible: layerVisibility[13]!,
                        child: Align(
                          alignment: rimPosRear,
                          child: Transform.rotate(
                            angle: rimAngleRear * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: frontForkItems.where((element) => element.code == frontForkCode).first.sizeType == '29er'
                                  ? rimItems.where((element) => element.code == rimCode).first.sizeFactor
                                  : 0.32,
                              child: Image.asset(
                                rimItems.where((element) => element.code == rimCode).first.rearImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Rim
                      Visibility(
                        visible: layerVisibility[12]!,
                        child: Align(
                          alignment: rimPosFront,
                          child: Transform.rotate(
                            angle: rimAngleFront * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: frontForkItems.where((element) => element.code == frontForkCode).first.sizeType == '29er'
                                  ? rimItems.where((element) => element.code == rimCode).first.sizeFactor
                                  : 0.32,
                              child: Image.asset(
                                rimItems.where((element) => element.code == rimCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Tire
                      Visibility(
                        visible: layerVisibility[15]!,
                        child: Align(
                          alignment: tirePosRear,
                          child: Transform.rotate(
                            angle: tireAngleRear * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: frontForkItems.where((element) => element.code == frontForkCode).first.sizeType == '29er' ? 0.39 : 0.37,
                              child: Image.asset(
                                tireItems.where((element) => element.code == tireCode).first.rearImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Tire
                      Visibility(
                        visible: layerVisibility[14]!,
                        child: Align(
                          alignment: tirePosFront,
                          child: Transform.rotate(
                            angle: tireAngleFront * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: frontForkItems.where((element) => element.code == frontForkCode).first.sizeType == '29er' ? 0.39 : 0.37,
                              child: Image.asset(
                                tireItems.where((element) => element.code == tireCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Cassette
                      Visibility(
                        visible: layerVisibility[3]!,
                        child: Align(
                          alignment: cassettePos,
                          child: Transform.rotate(
                            angle: cassetteAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: cassetteItems.where((element) => element.code == cassetteCode).first.sizeFactor,
                              child: Image.asset(
                                cassetteItems.where((element) => element.code == cassetteCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Fender
                      Visibility(
                        visible: layerVisibility[19]!,
                        child: Align(
                          alignment: fenderPosRear,
                          child: Transform.rotate(
                            angle: fenderAngleRear * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: fenderItems.where((element) => element.code == fenderCode).first.sizeFactorFront,
                              child: Image.asset(
                                fenderItems.where((element) => element.code == fenderCode).first.rearImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Fender
                      Visibility(
                        visible: layerVisibility[18]!,
                        child: Align(
                          alignment: fenderPosFront,
                          child: Transform.rotate(
                            angle: fenderAngleFront * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: fenderItems.where((element) => element.code == fenderCode).first.sizeFactorFront,
                              child: Image.asset(
                                fenderItems.where((element) => element.code == fenderCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Fork/Suspension
                      Visibility(
                        visible: layerVisibility[7]!,
                        child: Align(
                          alignment: frontForkPos,
                          child: Transform.rotate(
                            angle: frontForkAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: frontForkItems.where((element) => element.code == frontForkCode).first.sizeFactor,
                              child: Image.asset(
                                frontForkItems.where((element) => element.code == frontForkCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Saddle
                      Visibility(
                        visible: layerVisibility[11]!,
                        child: Align(
                          alignment: saddlePos,
                          child: Transform.rotate(
                            angle: saddleAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: saddleItems.where((element) => element.code == saddleCode).first.sizeFactor,
                              child: Image.asset(
                                saddleItems.where((element) => element.code == saddleCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Chain
                      Visibility(
                        visible: layerVisibility[26]!,
                        child: Align(
                          alignment: chainAdvancedPos,
                          child: Transform.rotate(
                            angle: chainAdvancedAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: 0.288,
                              child: Image.asset(
                                chainAdvanced,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Frame
                      Visibility(
                        visible: layerVisibility[5]!,
                        child: Align(
                          alignment: framePos,
                          child: Transform.rotate(
                            angle: frameAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: frameItems.where((element) => element.code == frameCode).first.sizeFactor,
                              child: Image.asset(
                                frameItems.where((element) => element.code == frameCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Crankset
                      Visibility(
                        visible: layerVisibility[4]!,
                        child: Align(
                          alignment: cranksetPos,
                          child: Transform.rotate(
                            angle: cranksetAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: cranksetItems.where((element) => element.code == cranksetCode).first.sizeFactor,
                              child: Image.asset(
                                cranksetItems.where((element) => element.code == cranksetCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Pedal
                      Visibility(
                        visible: layerVisibility[9]!,
                        child: Align(
                          alignment: pedalPos,
                          child: Transform.rotate(
                            angle: pedalAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: pedalItems.where((element) => element.code == pedalCode).first.sizeFactor,
                              child: Image.asset(
                                pedalItems.where((element) => element.code == pedalCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Derailleur
                      Visibility(
                        visible: layerVisibility[10]!,
                        child: Align(
                          alignment: rearDlrPos,
                          child: Transform.rotate(
                            angle: rearDlrAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: rearDlrItems.where((element) => element.code == rearDlrCode).first.sizeFactor,
                              child: Image.asset(
                                rearDlrItems.where((element) => element.code == rearDlrCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Derailleur
                      Visibility(
                        visible: layerVisibility[6]!,
                        child: Align(
                          alignment: frontDlrPos,
                          child: Transform.rotate(
                            angle: frontDlrAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: frontDlrItems.where((element) => element.code == frontDlrCode).first.sizeFactor,
                              child: !frameItems
                                      .where((element) => element.code == frameCode)
                                      .first
                                      .frontDerailleurTypes
                                      .contains(frontDlrItems.where((element) => element.code == frontDlrCode).first.type)
                                  ? SizedBox.shrink()
                                  : Image.asset(
                                      frontDlrItems.where((element) => element.code == frontDlrCode).first.image,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      //Bell
                      Visibility(
                        visible: layerVisibility[16]!,
                        child: Align(
                          alignment: bellPos,
                          child: Transform.rotate(
                            angle: bellAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: bellItems.where((element) => element.code == bellCode).first.sizeFactorFront,
                              child: Image.asset(
                                bellItems.where((element) => element.code == bellCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Rear Light
                      Visibility(
                        visible: layerVisibility[22]!,
                        child: Align(
                          alignment: lightPosRear,
                          child: Transform.rotate(
                            angle: lightAngleRear * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: lightItems.where((element) => element.code == lightCode).first.sizeFactorRear,
                              child: Image.asset(
                                lightItems.where((element) => element.code == lightCode).first.rearImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Front Light
                      Visibility(
                        visible: layerVisibility[21]!,
                        child: Align(
                          alignment: lightPosFront,
                          child: Transform.rotate(
                            angle: lightAngleFront * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: lightItems.where((element) => element.code == lightCode).first.sizeFactorFront,
                              child: Image.asset(
                                lightItems.where((element) => element.code == lightCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Handlebar
                      Visibility(
                        visible: layerVisibility[8]!,
                        child: Align(
                          alignment: handlebarPos,
                          child: Transform.rotate(
                            angle: handlebarAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: handlebarItems.where((element) => element.code == handlebarCode).first.sizeFactor,
                              child: Image.asset(
                                handlebarItems.where((element) => element.code == handlebarCode).first.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Bottle Cage
                      Visibility(
                        visible: layerVisibility[17]!,
                        child: Align(
                          alignment: bottleCagePos,
                          child: Transform.rotate(
                            angle: bottleCageAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              heightFactor: bottleCageItems.where((element) => element.code == bottleCageCode).first.sizeFactorFront,
                              child: Image.asset(
                                bottleCageItems.where((element) => element.code == bottleCageCode).first.frontImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //Phone Holder
                      Visibility(
                        visible: layerVisibility[23]!,
                        child: Align(
                          alignment: phoneHoldePos,
                          child: Transform.rotate(
                            angle: phoneHoldeAngle * math.pi / 180,
                            child: FractionallySizedBox(
                              widthFactor: phoneHolderItems.where((element) => element.code == phoneHolderCode).first.sizeFactorFront,
                              child: Image.asset(
                                phoneHolderItems.where((element) => element.code == phoneHolderCode).first.frontImage,
                                fit: BoxFit.contain,
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
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('rotation: ', style: TextStyle(color: Colors.black)),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.white,
                      activeTrackColor: Colors.grey,
                      disabledActiveTrackColor: Colors.grey,
                      inactiveTrackColor: Colors.grey,
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: Colors.transparent,
                      disabledInactiveTrackColor: Colors.transparent,
                      disabledThumbColor: Colors.grey.shade300,
                      trackHeight: 3,
                      trackShape: CustomTrackShape(),
                      thumbShape: BorderedSliderThumbShape(
                        borderWidth: 2,
                        borderColor: Colors.black,
                        disableBorderColor: Colors.grey,
                      ),
                    ),
                    child: RangeSliderButton<double>(
                      value: currentAngle,
                      minValue: -360.0,
                      maxValue: 360.0,
                      buttonSize: 20.0,
                      sliderWidth: 170.0,
                      addingNumber: 1.0,
                      subtractingNumber: 1.0,
                      spacing: 10,
                      onChanged: (val) {
                        currentAngle = val;
                        updateLayerAngle(activeLayer);
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Text('x-axis: ', style: TextStyle(color: Colors.black)),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.white,
                      activeTrackColor: Colors.grey,
                      disabledActiveTrackColor: Colors.grey,
                      inactiveTrackColor: Colors.grey,
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: Colors.transparent,
                      disabledInactiveTrackColor: Colors.transparent,
                      disabledThumbColor: Colors.grey.shade300,
                      trackHeight: 3,
                      trackShape: CustomTrackShape(),
                      thumbShape: BorderedSliderThumbShape(
                        borderWidth: 2,
                        borderColor: Colors.black,
                        disableBorderColor: Colors.grey,
                      ),
                    ),
                    child: RangeSliderButton<double>(
                      value: currentXAxis,
                      minValue: -1.0,
                      maxValue: 1.0,
                      buttonSize: 20,
                      sliderWidth: 170,
                      addingNumber: 0.002,
                      subtractingNumber: 0.002,
                      spacing: 10,
                      onChanged: (val) {
                        currentXAxis = val;
                        updateLayerXAxis(activeLayer);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('y-axis:', style: TextStyle(color: Colors.black)),
                  RotatedBox(
                    quarterTurns: 1,
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.white,
                        activeTrackColor: Colors.grey,
                        disabledActiveTrackColor: Colors.grey,
                        inactiveTrackColor: Colors.grey,
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                        disabledInactiveTrackColor: Colors.transparent,
                        disabledThumbColor: Colors.grey.shade300,
                        trackHeight: 3,
                        trackShape: CustomTrackShape(),
                        thumbShape: BorderedSliderThumbShape(
                          borderWidth: 2,
                          borderColor: Colors.black,
                          disableBorderColor: Colors.grey,
                        ),
                      ),
                      child: RangeSliderButton<double>(
                        value: currentYAxis,
                        minValue: -1.0,
                        maxValue: 1.0,
                        buttonSize: 20,
                        sliderWidth: 170,
                        addingNumber: 0.002,
                        subtractingNumber: 0.002,
                        spacing: 10,
                        onChanged: (val) {
                          currentYAxis = val;
                          updateLayerYAxis(activeLayer);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Reset Zoom',
                  icon: Icon(
                    Icons.center_focus_strong,
                    color: Colors.orange.shade400,
                  ),
                  onPressed: () {
                    _transformationController.value = Matrix4.identity();
                  },
                ),
                IconButton(
                  tooltip: !hideLayer ? 'Hide Layer' : 'Show Layer',
                  icon: Icon(
                    !hideLayer ? Icons.visibility : Icons.visibility_off_rounded,
                    color: Colors.orange.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      layerVisibility[activeLayer] = hideLayer;
                      hideLayer = !hideLayer;
                    });
                  },
                ),
                Text(
                  'Active Layer: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                DropdownButton<int>(
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  value: activeLayer,
                  onChanged: (layer) {
                    setState(() {
                      activeLayer = layer!;
                      getLayerValues(layer);
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Front Brake'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Rear Brake'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('Cassette'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('Crankset'),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text('Frame'),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text('Front Derailleur'),
                    ),
                    DropdownMenuItem(
                      value: 7,
                      child: Text('Front Fork'),
                    ),
                    DropdownMenuItem(
                      value: 8,
                      child: Text('Handlebar'),
                    ),
                    DropdownMenuItem(
                      value: 9,
                      child: Text('Pedal'),
                    ),
                    DropdownMenuItem(
                      value: 10,
                      child: Text('Rear Derailleur'),
                    ),
                    DropdownMenuItem(
                      value: 11,
                      child: Text('Saddle'),
                    ),
                    DropdownMenuItem(
                      value: 12,
                      child: Text('Front Rim'),
                    ),
                    DropdownMenuItem(
                      value: 13,
                      child: Text('Rear Rim'),
                    ),
                    DropdownMenuItem(
                      value: 14,
                      child: Text('Front Tire'),
                    ),
                    DropdownMenuItem(
                      value: 15,
                      child: Text('Rear Tire'),
                    ),
                    DropdownMenuItem(
                      value: 16,
                      child: Text('Bell'),
                    ),
                    DropdownMenuItem(
                      value: 17,
                      child: Text('Bottle Cage'),
                    ),
                    DropdownMenuItem(
                      value: 18,
                      child: Text('Front Fender'),
                    ),
                    DropdownMenuItem(
                      value: 19,
                      child: Text('Rear Fender'),
                    ),
                    DropdownMenuItem(
                      value: 20,
                      child: Text('Kickstand'),
                    ),
                    DropdownMenuItem(
                      value: 21,
                      child: Text('Front Light'),
                    ),
                    DropdownMenuItem(
                      value: 22,
                      child: Text('Rear Light'),
                    ),
                    DropdownMenuItem(
                      value: 23,
                      child: Text('Phone Holder'),
                    ),
                    DropdownMenuItem(
                      value: 24,
                      child: Text('Brake Disc Front'),
                    ),
                    DropdownMenuItem(
                      value: 25,
                      child: Text('Brake Disc Rear'),
                    ),
                    DropdownMenuItem(
                      value: 26,
                      child: Text('Chain'),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Restore Position',
                  icon: Icon(
                    Icons.restore_rounded,
                    color: Colors.orange.shade400,
                  ),
                  onPressed: () {
                    restorePosAngle(activeLayer);
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 5),
              child: TextButton(
                child: Text('Save'),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFF8B02),
                  primary: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  if (widget.index != null) {
                    bikeProjects[widget.index!].name = projectName;
                    bikeProjects[widget.index!].buildDate = DateTime.now();
                    bikeProjects[widget.index!].brakeClprCode = brakeClprCode;
                    bikeProjects[widget.index!].brakeClprPosFront = PartPosition(brakeClprPosFront.x, brakeClprPosFront.y);
                    bikeProjects[widget.index!].brakeClprPosRear = PartPosition(brakeClprPosRear.x, brakeClprPosRear.y);
                    bikeProjects[widget.index!].brakeClprAngleFront = brakeClprAngleFront;
                    bikeProjects[widget.index!].brakeClprAngleRear = brakeClprAngleRear;
                    bikeProjects[widget.index!].cassetteCode = cassetteCode;
                    bikeProjects[widget.index!].cassettePos = PartPosition(cassettePos.x, cassettePos.y);
                    bikeProjects[widget.index!].cassetteAngle = cassetteAngle;
                    bikeProjects[widget.index!].cranksetCode = cranksetCode;
                    bikeProjects[widget.index!].cranksetPos = PartPosition(cranksetPos.x, cranksetPos.y);
                    bikeProjects[widget.index!].cranksetAngle = cranksetAngle;
                    bikeProjects[widget.index!].frameCode = frameCode;
                    bikeProjects[widget.index!].framePos = PartPosition(framePos.x, framePos.y);
                    bikeProjects[widget.index!].frameAngle = frameAngle;
                    bikeProjects[widget.index!].frontDlrCode = frontDlrCode;
                    bikeProjects[widget.index!].frontDlrPos = PartPosition(frontDlrPos.x, frontDlrPos.y);
                    bikeProjects[widget.index!].frontDlrAngle = frontDlrAngle;
                    bikeProjects[widget.index!].frontForkCode = frontForkCode;
                    bikeProjects[widget.index!].frontForkPos = PartPosition(frontForkPos.x, frontForkPos.y);
                    bikeProjects[widget.index!].frontForkAngle = frontForkAngle;
                    bikeProjects[widget.index!].handlebarCode = handlebarCode;
                    bikeProjects[widget.index!].handlebarPos = PartPosition(handlebarPos.x, handlebarPos.y);
                    bikeProjects[widget.index!].handlebarAngle = handlebarAngle;
                    bikeProjects[widget.index!].pedalCode = pedalCode;
                    bikeProjects[widget.index!].pedalPos = PartPosition(pedalPos.x, pedalPos.y);
                    bikeProjects[widget.index!].pedalAngle = pedalAngle;
                    bikeProjects[widget.index!].rearDlrCode = rearDlrCode;
                    bikeProjects[widget.index!].rearDlrPos = PartPosition(rearDlrPos.x, rearDlrPos.y);
                    bikeProjects[widget.index!].rearDlrAngle = rearDlrAngle;
                    bikeProjects[widget.index!].rimCode = rimCode;
                    bikeProjects[widget.index!].rimPosFront = PartPosition(rimPosFront.x, rimPosFront.y);
                    bikeProjects[widget.index!].rimPosRear = PartPosition(rimPosRear.x, rimPosRear.y);
                    bikeProjects[widget.index!].rimAngleFront = rimAngleFront;
                    bikeProjects[widget.index!].rimAngleRear = rimAngleRear;
                    bikeProjects[widget.index!].saddleCode = saddleCode;
                    bikeProjects[widget.index!].saddlePos = PartPosition(saddlePos.x, saddlePos.y);
                    bikeProjects[widget.index!].saddleAngle = saddleAngle;
                    bikeProjects[widget.index!].tireCode = tireCode;
                    bikeProjects[widget.index!].tirePosFront = PartPosition(tirePosFront.x, tirePosFront.y);
                    bikeProjects[widget.index!].tirePosRear = PartPosition(tirePosRear.x, tirePosRear.y);
                    bikeProjects[widget.index!].tireAngleFront = tireAngleFront;
                    bikeProjects[widget.index!].tireAngleRear = tireAngleRear;
                    bikeProjects[widget.index!].bellCode = bellCode;
                    bikeProjects[widget.index!].bellPos = PartPosition(bellPos.x, bellPos.y);
                    bikeProjects[widget.index!].bellAngle = bellAngle;
                    bikeProjects[widget.index!].bottleCageCode = bottleCageCode;
                    bikeProjects[widget.index!].bottleCagePos = PartPosition(bottleCagePos.x, bottleCagePos.y);
                    bikeProjects[widget.index!].bottleCageAngle = bottleCageAngle;
                    bikeProjects[widget.index!].fenderCode = fenderCode;
                    bikeProjects[widget.index!].fenderPosFront = PartPosition(fenderPosFront.x, fenderPosFront.y);
                    bikeProjects[widget.index!].fenderPosRear = PartPosition(fenderPosRear.x, fenderPosRear.y);
                    bikeProjects[widget.index!].fenderAngleFront = fenderAngleFront;
                    bikeProjects[widget.index!].fenderAngleRear = fenderAngleRear;
                    bikeProjects[widget.index!].kickstandCode = kickstandCode;
                    bikeProjects[widget.index!].kickstandPos = PartPosition(kickstandPos.x, kickstandPos.y);
                    bikeProjects[widget.index!].kickstandAngle = kickstandAngle;
                    bikeProjects[widget.index!].lightCode = lightCode;
                    bikeProjects[widget.index!].lightPosFront = PartPosition(lightPosFront.x, lightPosFront.y);
                    bikeProjects[widget.index!].lightPosRear = PartPosition(lightPosRear.x, lightPosRear.y);
                    bikeProjects[widget.index!].lightAngleFront = lightAngleFront;
                    bikeProjects[widget.index!].lightAngleRear = lightAngleRear;
                    bikeProjects[widget.index!].phoneHolderCode = phoneHolderCode;
                    bikeProjects[widget.index!].phoneHoldePos = PartPosition(phoneHoldePos.x, phoneHoldePos.y);
                    bikeProjects[widget.index!].phoneHoldeAngle = phoneHoldeAngle;
                    bikeProjects[widget.index!].chainAdvancedPos = PartPosition(chainAdvancedPos.x, chainAdvancedPos.y);
                    bikeProjects[widget.index!].chainAdvancedAngle = chainAdvancedAngle;
                    bikeProjects[widget.index!].brakeDiscPosFront = PartPosition(brakeDiscPosFront.x, brakeDiscPosFront.y);
                    bikeProjects[widget.index!].brakeDiscPosRear = PartPosition(brakeDiscPosRear.x, brakeDiscPosRear.y);
                    bikeProjects[widget.index!].brakeDiscAngleFront = brakeDiscAngleFront;
                    bikeProjects[widget.index!].brakeDiscAngleRear = brakeDiscAngleRear;
                  } else {
                    bikeProjects.add(
                      BikeBuild(
                        name: projectName,
                        buildDate: DateTime.now(),
                        brakeClprCode: brakeClprCode,
                        brakeClprPosFront: PartPosition(brakeClprPosFront.x, brakeClprPosFront.y),
                        brakeClprPosRear: PartPosition(brakeClprPosRear.x, brakeClprPosRear.y),
                        brakeClprAngleFront: brakeClprAngleFront,
                        brakeClprAngleRear: brakeClprAngleRear,
                        cassetteCode: cassetteCode,
                        cassettePos: PartPosition(cassettePos.x, cassettePos.y),
                        cassetteAngle: cassetteAngle,
                        cranksetCode: cranksetCode,
                        cranksetPos: PartPosition(cranksetPos.x, cranksetPos.y),
                        cranksetAngle: cranksetAngle,
                        frameCode: frameCode,
                        framePos: PartPosition(framePos.x, framePos.y),
                        frameAngle: frameAngle,
                        frontDlrCode: frontDlrCode,
                        frontDlrPos: PartPosition(frontDlrPos.x, frontDlrPos.y),
                        frontDlrAngle: frontDlrAngle,
                        frontForkCode: frontForkCode,
                        frontForkPos: PartPosition(frontForkPos.x, frontForkPos.y),
                        frontForkAngle: frontForkAngle,
                        handlebarCode: handlebarCode,
                        handlebarPos: PartPosition(handlebarPos.x, handlebarPos.y),
                        handlebarAngle: handlebarAngle,
                        pedalCode: pedalCode,
                        pedalPos: PartPosition(pedalPos.x, pedalPos.y),
                        pedalAngle: pedalAngle,
                        rearDlrCode: rearDlrCode,
                        rearDlrPos: PartPosition(rearDlrPos.x, rearDlrPos.y),
                        rearDlrAngle: rearDlrAngle,
                        rimCode: rimCode,
                        rimPosFront: PartPosition(rimPosFront.x, rimPosFront.y),
                        rimPosRear: PartPosition(rimPosRear.x, rimPosRear.y),
                        rimAngleFront: rimAngleFront,
                        rimAngleRear: rimAngleRear,
                        saddleCode: saddleCode,
                        saddlePos: PartPosition(saddlePos.x, saddlePos.y),
                        saddleAngle: saddleAngle,
                        tireCode: tireCode,
                        tirePosFront: PartPosition(tirePosFront.x, tirePosFront.y),
                        tirePosRear: PartPosition(tirePosRear.x, tirePosRear.y),
                        tireAngleFront: tireAngleFront,
                        tireAngleRear: tireAngleRear,
                        bellCode: bellCode,
                        bellPos: PartPosition(bellPos.x, bellPos.y),
                        bellAngle: bellAngle,
                        bottleCageCode: bottleCageCode,
                        bottleCagePos: PartPosition(bottleCagePos.x, bottleCagePos.y),
                        bottleCageAngle: bottleCageAngle,
                        fenderCode: fenderCode,
                        fenderPosFront: PartPosition(fenderPosFront.x, fenderPosFront.y),
                        fenderPosRear: PartPosition(fenderPosRear.x, fenderPosRear.y),
                        fenderAngleFront: fenderAngleFront,
                        fenderAngleRear: fenderAngleRear,
                        kickstandCode: kickstandCode,
                        kickstandPos: PartPosition(kickstandPos.x, kickstandPos.y),
                        kickstandAngle: kickstandAngle,
                        lightCode: lightCode,
                        lightPosFront: PartPosition(lightPosFront.x, lightPosFront.y),
                        lightPosRear: PartPosition(lightPosRear.x, lightPosRear.y),
                        lightAngleFront: lightAngleFront,
                        lightAngleRear: lightAngleRear,
                        phoneHolderCode: phoneHolderCode,
                        phoneHoldePos: PartPosition(phoneHoldePos.x, phoneHoldePos.y),
                        phoneHoldeAngle: phoneHoldeAngle,
                        chainAdvancedPos: PartPosition(chainAdvancedPos.x, chainAdvancedPos.y),
                        chainAdvancedAngle: chainAdvancedAngle,
                        brakeDiscPosFront: PartPosition(brakeDiscPosFront.x, brakeDiscPosFront.y),
                        brakeDiscPosRear: PartPosition(brakeDiscPosRear.x, brakeDiscPosRear.y),
                        brakeDiscAngleFront: brakeDiscAngleFront,
                        brakeDiscAngleRear: brakeDiscAngleRear,
                      ),
                    );
                  }
                  List<String> jsonString = bikeProjects.map((e) => e.toJson()).toList();
                  StorageHelper.setStringList('${currentUser!.profileNumber}bikeProjects', jsonString);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
              color: Color(0xFFFF8B02),
              child: Ink(
                height: 50,
                width: 50,
                child: InkWell(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onTap: () {
                    _bikeEditorKey.currentState!.openDrawer();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Fetch brand image used for a bike part
  String brandImage(String brand) {
    String imagePath;
    if (brand == 'Fox') {
      imagePath = 'assets/images/bike_project/brands/fox.png';
    } else if (brand == 'Giant') {
      imagePath = 'assets/images/bike_project/brands/giant.png';
    } else if (brand == 'Scott') {
      imagePath = 'assets/images/bike_project/brands/scott.png';
    } else if (brand == 'Shimano') {
      imagePath = 'assets/images/bike_project/brands/shimano.png';
    } else if (brand == 'Specialized') {
      imagePath = 'assets/images/bike_project/brands/specialized.png';
    } else if (brand == 'SRAM') {
      imagePath = 'assets/images/bike_project/brands/sram.png';
    } else if (brand == 'Trek') {
      imagePath = 'assets/images/bike_project/brands/trek.png';
    } else if (brand == 'Yeti') {
      imagePath = 'assets/images/bike_project/brands/yeti.png';
    } else if (brand == 'Rockbros') {
      imagePath = 'assets/images/bike_project/brands/rockbros.png';
    } else {
      imagePath = 'assets/images/bike_project/brands/generic.png';
    }
    return imagePath;
  }

  //Get the project details, checks if the project is new or just being editted
  void getProjectsDetails() {
    bikeProjects = widget.projectList ?? [];
    if (widget.index == null) {
      if (bikeProjects.isNotEmpty) {
        int incrementName = bikeProjects.length;
        while (bikeProjects.map((e) => e.name).toList().contains('BikeProject$incrementName')) {
          incrementName += 1;
        }
        projectName = 'BikeProject$incrementName';
      } else {
        projectName = 'BikeProject1';
      }
    } else {
      BikeBuild currentBike = bikeProjects[widget.index!];
      projectName = currentBike.name;
      brakeClprCode = currentBike.brakeClprCode;
      brakeClprPosFront = Alignment(currentBike.brakeClprPosFront.x, currentBike.brakeClprPosFront.y);
      brakeClprPosRear = Alignment(currentBike.brakeClprPosRear.x, currentBike.brakeClprPosRear.y);
      brakeClprAngleFront = currentBike.brakeClprAngleFront;
      brakeClprAngleRear = currentBike.brakeClprAngleRear;
      cassetteCode = currentBike.cassetteCode;
      cassettePos = Alignment(currentBike.cassettePos.x, currentBike.cassettePos.y);
      cassetteAngle = currentBike.cassetteAngle;
      cranksetCode = currentBike.cranksetCode;
      cranksetPos = Alignment(currentBike.cranksetPos.x, currentBike.cranksetPos.y);
      cranksetAngle = currentBike.cranksetAngle;
      frameCode = currentBike.frameCode;
      framePos = Alignment(currentBike.framePos.x, currentBike.framePos.y);
      frameAngle = currentBike.frameAngle;
      frontDlrCode = currentBike.frontDlrCode;
      frontDlrPos = Alignment(currentBike.frontDlrPos.x, currentBike.frontDlrPos.y);
      frontDlrAngle = currentBike.frontDlrAngle;
      frontForkCode = currentBike.frontForkCode;
      frontForkPos = Alignment(currentBike.frontForkPos.x, currentBike.frontForkPos.y);
      frontForkAngle = currentBike.frontForkAngle;
      handlebarCode = currentBike.handlebarCode;
      handlebarPos = Alignment(currentBike.handlebarPos.x, currentBike.handlebarPos.y);
      handlebarAngle = currentBike.handlebarAngle;
      pedalCode = currentBike.pedalCode;
      pedalPos = Alignment(currentBike.pedalPos.x, currentBike.pedalPos.y);
      pedalAngle = currentBike.pedalAngle;
      rearDlrCode = currentBike.rearDlrCode;
      rearDlrPos = Alignment(currentBike.rearDlrPos.x, currentBike.rearDlrPos.y);
      rearDlrAngle = currentBike.rearDlrAngle;
      rimCode = currentBike.rimCode;
      rimPosFront = Alignment(currentBike.rimPosFront.x, currentBike.rimPosFront.y);
      rimPosRear = Alignment(currentBike.rimPosRear.x, currentBike.rimPosRear.y);
      rimAngleFront = currentBike.rimAngleFront;
      rimAngleRear = currentBike.rimAngleRear;
      saddleCode = currentBike.saddleCode;
      saddlePos = Alignment(currentBike.saddlePos.x, currentBike.saddlePos.y);
      saddleAngle = currentBike.saddleAngle;
      tireCode = currentBike.tireCode;
      tirePosFront = Alignment(currentBike.tirePosFront.x, currentBike.tirePosFront.y);
      tirePosRear = Alignment(currentBike.tirePosRear.x, currentBike.tirePosRear.y);
      tireAngleFront = currentBike.tireAngleFront;
      tireAngleRear = currentBike.tireAngleRear;
      bellCode = currentBike.bellCode;
      bellPos = Alignment(currentBike.bellPos.x, currentBike.bellPos.y);
      bellAngle = currentBike.bellAngle;
      bottleCageCode = currentBike.bottleCageCode;
      bottleCagePos = Alignment(currentBike.bottleCagePos.x, currentBike.bottleCagePos.y);
      bottleCageAngle = currentBike.bottleCageAngle;
      fenderCode = currentBike.fenderCode;
      fenderPosFront = Alignment(currentBike.fenderPosFront.x, currentBike.fenderPosFront.y);
      fenderPosRear = Alignment(currentBike.fenderPosRear.x, currentBike.fenderPosRear.y);
      fenderAngleFront = currentBike.fenderAngleFront;
      fenderAngleRear = currentBike.fenderAngleRear;
      kickstandCode = currentBike.kickstandCode;
      kickstandPos = Alignment(currentBike.kickstandPos.x, currentBike.kickstandPos.y);
      kickstandAngle = currentBike.kickstandAngle;
      lightCode = currentBike.lightCode;
      lightPosFront = Alignment(currentBike.lightPosFront.x, currentBike.lightPosFront.y);
      lightPosRear = Alignment(currentBike.lightPosRear.x, currentBike.lightPosRear.y);
      lightAngleFront = currentBike.lightAngleFront;
      lightAngleRear = currentBike.lightAngleRear;
      phoneHolderCode = currentBike.phoneHolderCode;
      phoneHoldePos = Alignment(currentBike.phoneHoldePos.x, currentBike.phoneHoldePos.y);
      phoneHoldeAngle = currentBike.phoneHoldeAngle;
      chainAdvancedPos = Alignment(currentBike.chainAdvancedPos.x, currentBike.chainAdvancedPos.y);
      chainAdvancedAngle = currentBike.chainAdvancedAngle;
      brakeDiscPosFront = Alignment(currentBike.brakeDiscPosFront.x, currentBike.brakeDiscPosFront.y);
      brakeDiscPosRear = Alignment(currentBike.brakeDiscPosRear.x, currentBike.brakeDiscPosRear.y);
      brakeDiscAngleFront = currentBike.brakeDiscAngleFront;
      brakeDiscAngleRear = currentBike.brakeDiscAngleRear;
    }
  }

  //Get Active Layer Values
  void getLayerValues(int layer) {
    hideLayer = !layerVisibility[layer]!;
    if (layer == 1) {
      currentAngle = brakeClprAngleFront;
      currentXAxis = brakeClprPosFront.x;
      currentYAxis = brakeClprPosFront.y;
    } else if (layer == 2) {
      currentAngle = brakeClprAngleRear;
      currentXAxis = brakeClprPosRear.x;
      currentYAxis = brakeClprPosRear.y;
    } else if (layer == 3) {
      currentAngle = cassetteAngle;
      currentXAxis = cassettePos.x;
      currentYAxis = cassettePos.y;
    } else if (layer == 4) {
      currentAngle = cranksetAngle;
      currentXAxis = cranksetPos.x;
      currentYAxis = cranksetPos.y;
    } else if (layer == 5) {
      currentAngle = frameAngle;
      currentXAxis = framePos.x;
      currentYAxis = framePos.y;
    } else if (layer == 6) {
      currentAngle = frontDlrAngle;
      currentXAxis = frontDlrPos.x;
      currentYAxis = frontDlrPos.y;
    } else if (layer == 7) {
      currentAngle = frontForkAngle;
      currentXAxis = frontForkPos.x;
      currentYAxis = frontForkPos.y;
    } else if (layer == 8) {
      currentAngle = handlebarAngle;
      currentXAxis = handlebarPos.x;
      currentYAxis = handlebarPos.y;
    } else if (layer == 9) {
      currentAngle = pedalAngle;
      currentXAxis = pedalPos.x;
      currentYAxis = pedalPos.y;
    } else if (layer == 10) {
      currentAngle = rearDlrAngle;
      currentXAxis = rearDlrPos.x;
      currentYAxis = rearDlrPos.y;
    } else if (layer == 11) {
      currentAngle = saddleAngle;
      currentXAxis = saddlePos.x;
      currentYAxis = saddlePos.y;
    } else if (layer == 12) {
      currentAngle = rimAngleFront;
      currentXAxis = rimPosFront.x;
      currentYAxis = rimPosFront.y;
    } else if (layer == 13) {
      currentAngle = rimAngleRear;
      currentXAxis = rimPosRear.x;
      currentYAxis = rimPosRear.y;
    } else if (layer == 14) {
      currentAngle = tireAngleFront;
      currentXAxis = tirePosFront.x;
      currentYAxis = tirePosFront.y;
    } else if (layer == 15) {
      currentAngle = tireAngleRear;
      currentXAxis = tirePosRear.x;
      currentYAxis = tirePosRear.y;
    } else if (layer == 16) {
      currentAngle = bellAngle;
      currentXAxis = bellPos.x;
      currentYAxis = bellPos.y;
    } else if (layer == 17) {
      currentAngle = bottleCageAngle;
      currentXAxis = bottleCagePos.x;
      currentYAxis = bottleCagePos.y;
    } else if (layer == 18) {
      currentAngle = fenderAngleFront;
      currentXAxis = fenderPosFront.x;
      currentYAxis = fenderPosFront.y;
    } else if (layer == 19) {
      currentAngle = fenderAngleRear;
      currentXAxis = fenderPosRear.x;
      currentYAxis = fenderPosRear.y;
    } else if (layer == 20) {
      currentAngle = kickstandAngle;
      currentXAxis = kickstandPos.x;
      currentYAxis = kickstandPos.y;
    } else if (layer == 21) {
      currentAngle = lightAngleFront;
      currentXAxis = lightPosFront.x;
      currentYAxis = lightPosFront.y;
    } else if (layer == 22) {
      currentAngle = lightAngleRear;
      currentXAxis = lightPosRear.x;
      currentYAxis = lightPosRear.y;
    } else if (layer == 23) {
      currentAngle = phoneHoldeAngle;
      currentXAxis = phoneHoldePos.x;
      currentYAxis = phoneHoldePos.y;
    } else if (layer == 24) {
      currentAngle = brakeDiscAngleFront;
      currentXAxis = brakeDiscPosFront.x;
      currentYAxis = brakeDiscPosFront.y;
    } else if (layer == 25) {
      currentAngle = brakeDiscAngleRear;
      currentXAxis = brakeDiscPosRear.x;
      currentYAxis = brakeDiscPosRear.y;
    } else if (layer == 26) {
      currentAngle = chainAdvancedAngle;
      currentXAxis = chainAdvancedPos.x;
      currentYAxis = chainAdvancedPos.y;
    } else {
      currentAngle = 0.0;
      currentXAxis = 0.0;
      currentYAxis = 0.0;
    }
    setState(() {});
  }

  //Restore Active Layer Values
  void restorePosAngle(int layer) {
    if (widget.index != null) {
      BikeBuild currentBike = bikeProjects[widget.index!];
      if (layer == 1) {
        currentAngle = currentBike.brakeClprAngleFront;
        currentXAxis = currentBike.brakeClprPosFront.x;
        currentYAxis = currentBike.brakeClprPosFront.y;
      } else if (layer == 2) {
        currentAngle = currentBike.brakeClprAngleRear;
        currentXAxis = currentBike.brakeClprPosRear.x;
        currentYAxis = currentBike.brakeClprPosRear.y;
      } else if (layer == 3) {
        currentAngle = currentBike.cassetteAngle;
        currentXAxis = currentBike.cassettePos.x;
        currentYAxis = currentBike.cassettePos.y;
      } else if (layer == 4) {
        currentAngle = currentBike.cranksetAngle;
        currentXAxis = currentBike.cranksetPos.x;
        currentYAxis = currentBike.cranksetPos.y;
      } else if (layer == 5) {
        currentAngle = currentBike.frameAngle;
        currentXAxis = currentBike.framePos.x;
        currentYAxis = currentBike.framePos.y;
      } else if (layer == 6) {
        currentAngle = currentBike.frontDlrAngle;
        currentXAxis = currentBike.frontDlrPos.x;
        currentYAxis = currentBike.frontDlrPos.y;
      } else if (layer == 7) {
        currentAngle = currentBike.frontForkAngle;
        currentXAxis = currentBike.frontForkPos.x;
        currentYAxis = currentBike.frontForkPos.y;
      } else if (layer == 8) {
        currentAngle = currentBike.handlebarAngle;
        currentXAxis = currentBike.handlebarPos.x;
        currentYAxis = currentBike.handlebarPos.y;
      } else if (layer == 9) {
        currentAngle = currentBike.pedalAngle;
        currentXAxis = currentBike.pedalPos.x;
        currentYAxis = currentBike.pedalPos.y;
      } else if (layer == 10) {
        currentAngle = currentBike.rearDlrAngle;
        currentXAxis = currentBike.rearDlrPos.x;
        currentYAxis = currentBike.rearDlrPos.y;
      } else if (layer == 11) {
        currentAngle = currentBike.saddleAngle;
        currentXAxis = currentBike.saddlePos.x;
        currentYAxis = currentBike.saddlePos.y;
      } else if (layer == 12) {
        currentAngle = currentBike.rimAngleFront;
        currentXAxis = currentBike.rimPosFront.x;
        currentYAxis = currentBike.rimPosFront.y;
      } else if (layer == 13) {
        currentAngle = currentBike.rimAngleRear;
        currentXAxis = currentBike.rimPosRear.x;
        currentYAxis = currentBike.rimPosRear.y;
      } else if (layer == 14) {
        currentAngle = currentBike.tireAngleFront;
        currentXAxis = currentBike.tirePosFront.x;
        currentYAxis = currentBike.tirePosFront.y;
      } else if (layer == 15) {
        currentAngle = currentBike.tireAngleRear;
        currentXAxis = currentBike.tirePosRear.x;
        currentYAxis = currentBike.tirePosRear.y;
      } else if (layer == 16) {
        currentAngle = currentBike.bellAngle;
        currentXAxis = currentBike.bellPos.x;
        currentYAxis = currentBike.bellPos.y;
      } else if (layer == 17) {
        currentAngle = currentBike.bottleCageAngle;
        currentXAxis = currentBike.bottleCagePos.x;
        currentYAxis = currentBike.bottleCagePos.y;
      } else if (layer == 18) {
        currentAngle = currentBike.fenderAngleFront;
        currentXAxis = currentBike.fenderPosFront.x;
        currentYAxis = currentBike.fenderPosFront.y;
      } else if (layer == 19) {
        currentAngle = currentBike.fenderAngleRear;
        currentXAxis = currentBike.fenderPosRear.x;
        currentYAxis = currentBike.fenderPosRear.y;
      } else if (layer == 20) {
        currentAngle = currentBike.kickstandAngle;
        currentXAxis = currentBike.kickstandPos.x;
        currentYAxis = currentBike.kickstandPos.y;
      } else if (layer == 21) {
        currentAngle = currentBike.lightAngleFront;
        currentXAxis = currentBike.lightPosFront.x;
        currentYAxis = currentBike.lightPosFront.y;
      } else if (layer == 22) {
        currentAngle = currentBike.lightAngleRear;
        currentXAxis = currentBike.lightPosRear.x;
        currentYAxis = currentBike.lightPosRear.y;
      } else if (layer == 23) {
        currentAngle = currentBike.phoneHoldeAngle;
        currentXAxis = currentBike.phoneHoldePos.x;
        currentYAxis = currentBike.phoneHoldePos.y;
      } else if (layer == 24) {
        currentAngle = currentBike.brakeDiscAngleFront;
        currentXAxis = currentBike.brakeDiscPosFront.x;
        currentYAxis = currentBike.brakeDiscPosFront.y;
      } else if (layer == 25) {
        currentAngle = currentBike.brakeDiscAngleRear;
        currentXAxis = currentBike.brakeDiscPosRear.x;
        currentYAxis = currentBike.brakeDiscPosRear.y;
      } else if (layer == 26) {
        currentAngle = currentBike.chainAdvancedAngle;
        currentXAxis = currentBike.chainAdvancedPos.x;
        currentYAxis = currentBike.chainAdvancedPos.y;
      } else {
        currentAngle = 0.0;
        currentXAxis = 0.0;
        currentYAxis = 0.0;
      }
    } else {
      if (layer == 1) {
        currentAngle = -20.053;
        currentXAxis = 0.518;
        currentYAxis = 0.255;
      } else if (layer == 2) {
        currentAngle = 98;
        currentXAxis = -0.512;
        currentYAxis = 0.278;
      } else if (layer == 3) {
        currentAngle = 0;
        currentXAxis = -0.63;
        currentYAxis = 0.304;
      } else if (layer == 4) {
        currentAngle = 42.971;
        currentXAxis = -0.124;
        currentYAxis = 0.5;
      } else if (layer == 5) {
        currentAngle = 0;
        currentXAxis = -0.232;
        currentYAxis = -0.49;
      } else if (layer == 6) {
        currentAngle = -22.34;
        currentXAxis = -0.215;
        currentYAxis = 0.225;
      } else if (layer == 7) {
        currentAngle = -20.053;
        currentXAxis = 0.492;
        currentYAxis = -0.376;
      } else if (layer == 8) {
        currentAngle = -21.772;
        currentXAxis = 0.358;
        currentYAxis = -0.976;
      } else if (layer == 9) {
        currentAngle = 0;
        currentXAxis = -0.018;
        currentYAxis = 0.566;
      } else if (layer == 10) {
        currentAngle = 3.151;
        currentXAxis = -0.665;
        currentYAxis = 0.583;
      } else if (layer == 11) {
        currentAngle = -18.334;
        currentXAxis = -0.33;
        currentYAxis = -0.99;
      } else if (layer == 12) {
        currentAngle = 0;
        currentXAxis = 0.888;
        currentYAxis = 0.67;
      } else if (layer == 13) {
        currentAngle = 0;
        currentXAxis = -0.888;
        currentYAxis = 0.67;
      } else if (layer == 14) {
        currentAngle = 0;
        currentXAxis = 0.97;
        currentYAxis = 0.89;
      } else if (layer == 15) {
        currentAngle = 0;
        currentXAxis = -0.97;
        currentYAxis = 0.89;
      } else if (layer == 16) {
        currentAngle = 0;
        currentXAxis = 0.355;
        currentYAxis = -0.968;
      } else if (layer == 17) {
        currentAngle = 36.096;
        currentXAxis = 0.0286;
        currentYAxis = -0.23;
      } else if (layer == 18) {
        currentAngle = -22.918;
        currentXAxis = 0.466;
        currentYAxis = -0.336;
      } else if (layer == 19) {
        currentAngle = 35.523;
        currentXAxis = -0.428;
        currentYAxis = -0.31;
      } else if (layer == 20) {
        currentAngle = -22;
        currentXAxis = -0.48;
        currentYAxis = 0.81;
      } else if (layer == 21) {
        currentAngle = 0;
        currentXAxis = 0.398;
        currentYAxis = -0.954;
      } else if (layer == 22) {
        currentAngle = -15.297;
        currentXAxis = -0.332;
        currentYAxis = -0.641;
      } else if (layer == 23) {
        currentAngle = -17.800;
        currentXAxis = 0.186;
        currentYAxis = -0.858;
      } else if (layer == 24) {
        currentAngle = 0;
        currentXAxis = 0.65;
        currentYAxis = 0.334;
      } else if (layer == 25) {
        currentAngle = 0;
        currentXAxis = -0.65;
        currentYAxis = 0.334;
      } else if (layer == 26) {
        currentAngle = 1.145;
        currentXAxis = -0.51;
        currentYAxis = 0.573;
      } else {
        currentAngle = 0.0;
        currentXAxis = 0.0;
        currentYAxis = 0.0;
      }
    }
    updateLayerAngle(layer);
    updateLayerXAxis(layer);
    updateLayerYAxis(layer);
  }

  //Updates Active Layer Angle
  void updateLayerAngle(int layer) {
    if (layer == 1) {
      brakeClprAngleFront = currentAngle;
    } else if (layer == 2) {
      brakeClprAngleRear = currentAngle;
    } else if (layer == 3) {
      cassetteAngle = currentAngle;
    } else if (layer == 4) {
      cranksetAngle = currentAngle;
    } else if (layer == 5) {
      frameAngle = currentAngle;
    } else if (layer == 6) {
      frontDlrAngle = currentAngle;
    } else if (layer == 7) {
      frontForkAngle = currentAngle;
    } else if (layer == 8) {
      handlebarAngle = currentAngle;
    } else if (layer == 9) {
      pedalAngle = currentAngle;
    } else if (layer == 10) {
      rearDlrAngle = currentAngle;
    } else if (layer == 11) {
      saddleAngle = currentAngle;
    } else if (layer == 12) {
      rimAngleFront = currentAngle;
    } else if (layer == 13) {
      rimAngleRear = currentAngle;
    } else if (layer == 14) {
      tireAngleFront = currentAngle;
    } else if (layer == 15) {
      tireAngleRear = currentAngle;
    } else if (layer == 16) {
      bellAngle = currentAngle;
    } else if (layer == 17) {
      bottleCageAngle = currentAngle;
    } else if (layer == 18) {
      fenderAngleFront = currentAngle;
    } else if (layer == 19) {
      fenderAngleRear = currentAngle;
    } else if (layer == 20) {
      kickstandAngle = currentAngle;
    } else if (layer == 21) {
      lightAngleFront = currentAngle;
    } else if (layer == 22) {
      lightAngleRear = currentAngle;
    } else if (layer == 23) {
      phoneHoldeAngle = currentAngle;
    } else if (layer == 24) {
      brakeDiscAngleFront = currentAngle;
    } else if (layer == 25) {
      brakeDiscAngleRear = currentAngle;
    } else if (layer == 26) {
      chainAdvancedAngle = currentAngle;
    }
    setState(() {});
  }

  //Updates Active Layer X Axis (Horizontal)
  //You can combine the X and Y Axis in the Alignment but I think separating it would be easier to manage;
  void updateLayerXAxis(int layer) {
    if (layer == 1) {
      brakeClprPosFront = Alignment(currentXAxis, brakeClprPosFront.y);
    } else if (layer == 2) {
      brakeClprPosRear = Alignment(currentXAxis, brakeClprPosRear.y);
    } else if (layer == 3) {
      cassettePos = Alignment(currentXAxis, cassettePos.y);
    } else if (layer == 4) {
      cranksetPos = Alignment(currentXAxis, cranksetPos.y);
    } else if (layer == 5) {
      framePos = Alignment(currentXAxis, framePos.y);
    } else if (layer == 6) {
      frontDlrPos = Alignment(currentXAxis, frontDlrPos.y);
    } else if (layer == 7) {
      frontForkPos = Alignment(currentXAxis, frontForkPos.y);
    } else if (layer == 8) {
      handlebarPos = Alignment(currentXAxis, handlebarPos.y);
    } else if (layer == 9) {
      pedalPos = Alignment(currentXAxis, pedalPos.y);
    } else if (layer == 10) {
      rearDlrPos = Alignment(currentXAxis, rearDlrPos.y);
    } else if (layer == 11) {
      saddlePos = Alignment(currentXAxis, saddlePos.y);
    } else if (layer == 12) {
      rimPosFront = Alignment(currentXAxis, rimPosFront.y);
    } else if (layer == 13) {
      rimPosRear = Alignment(currentXAxis, rimPosRear.y);
    } else if (layer == 14) {
      tirePosFront = Alignment(currentXAxis, tirePosFront.y);
    } else if (layer == 15) {
      tirePosRear = Alignment(currentXAxis, tirePosRear.y);
    } else if (layer == 16) {
      bellPos = Alignment(currentXAxis, bellPos.y);
    } else if (layer == 17) {
      bottleCagePos = Alignment(currentXAxis, bottleCagePos.y);
    } else if (layer == 18) {
      fenderPosFront = Alignment(currentXAxis, fenderPosFront.y);
    } else if (layer == 19) {
      fenderPosRear = Alignment(currentXAxis, fenderPosRear.y);
    } else if (layer == 20) {
      kickstandPos = Alignment(currentXAxis, kickstandPos.y);
    } else if (layer == 21) {
      lightPosFront = Alignment(currentXAxis, lightPosFront.y);
    } else if (layer == 22) {
      lightPosRear = Alignment(currentXAxis, lightPosRear.y);
    } else if (layer == 23) {
      phoneHoldePos = Alignment(currentXAxis, phoneHoldePos.y);
    } else if (layer == 24) {
      brakeDiscPosFront = Alignment(currentXAxis, brakeDiscPosFront.y);
    } else if (layer == 25) {
      brakeDiscPosRear = Alignment(currentXAxis, brakeDiscPosRear.y);
    } else if (layer == 26) {
      chainAdvancedPos = Alignment(currentXAxis, chainAdvancedPos.y);
    }
    setState(() {});
  }

  //Updates Active Layer X Axis (Vertical)
  void updateLayerYAxis(int layer) {
    if (layer == 1) {
      brakeClprPosFront = Alignment(brakeClprPosFront.x, currentYAxis);
    } else if (layer == 2) {
      brakeClprPosRear = Alignment(brakeClprPosRear.x, currentYAxis);
    } else if (layer == 3) {
      cassettePos = Alignment(cassettePos.x, currentYAxis);
    } else if (layer == 4) {
      cranksetPos = Alignment(cranksetPos.x, currentYAxis);
    } else if (layer == 5) {
      framePos = Alignment(framePos.x, currentYAxis);
    } else if (layer == 6) {
      frontDlrPos = Alignment(frontDlrPos.x, currentYAxis);
    } else if (layer == 7) {
      frontForkPos = Alignment(frontForkPos.x, currentYAxis);
    } else if (layer == 8) {
      handlebarPos = Alignment(handlebarPos.x, currentYAxis);
    } else if (layer == 9) {
      pedalPos = Alignment(pedalPos.x, currentYAxis);
    } else if (layer == 10) {
      rearDlrPos = Alignment(rearDlrPos.x, currentYAxis);
    } else if (layer == 11) {
      saddlePos = Alignment(saddlePos.x, currentYAxis);
    } else if (layer == 12) {
      rimPosFront = Alignment(rimPosFront.x, currentYAxis);
    } else if (layer == 13) {
      rimPosRear = Alignment(rimPosRear.x, currentYAxis);
    } else if (layer == 14) {
      tirePosFront = Alignment(tirePosFront.x, currentYAxis);
    } else if (layer == 15) {
      tirePosRear = Alignment(tirePosRear.x, currentYAxis);
    } else if (layer == 16) {
      bellPos = Alignment(bellPos.x, currentYAxis);
    } else if (layer == 17) {
      bottleCagePos = Alignment(bottleCagePos.x, currentYAxis);
    } else if (layer == 18) {
      fenderPosFront = Alignment(fenderPosFront.x, currentYAxis);
    } else if (layer == 19) {
      fenderPosRear = Alignment(fenderPosRear.x, currentYAxis);
    } else if (layer == 20) {
      kickstandPos = Alignment(kickstandPos.x, currentYAxis);
    } else if (layer == 21) {
      lightPosFront = Alignment(lightPosFront.x, currentYAxis);
    } else if (layer == 22) {
      lightPosRear = Alignment(lightPosRear.x, currentYAxis);
    } else if (layer == 23) {
      phoneHoldePos = Alignment(phoneHoldePos.x, currentYAxis);
    } else if (layer == 24) {
      brakeDiscPosFront = Alignment(brakeDiscPosFront.x, currentYAxis);
    } else if (layer == 25) {
      brakeDiscPosRear = Alignment(brakeDiscPosRear.x, currentYAxis);
    } else if (layer == 26) {
      chainAdvancedPos = Alignment(chainAdvancedPos.x, currentYAxis);
    }
    setState(() {});
  }
}

final List<BrakeCaliper> brakeCaliperItems = [
  BrakeCaliper(
    brand: 'Shimano',
    code: 'a1a',
    frontImage: 'assets/images/bike_project/bike_parts/brake_caliper/a1a.png',
    link: 'https://bike.shimano.com/en-AU/product/component/deore-m6100/BR-M6120.html',
    name: 'BR-M6120',
    price: 3943,
    rearImage: 'assets/images/bike_project/bike_parts/brake_caliper/a1a.png',
    sizeFactor: 0.086,
    type: 'Disc Brake',
  ),
  BrakeCaliper(
    brand: 'Shimano',
    code: 'a1b',
    frontImage: 'assets/images/bike_project/bike_parts/brake_caliper/a1b_front.png',
    link: 'https://bike.shimano.com/en-EU/product/component/tourney-tx800/BR-TX805.html',
    name: 'BR-TX805',
    price: 1450,
    rearImage: 'assets/images/bike_project/bike_parts/brake_caliper/a1b_rear.png',
    sizeFactor: 0.086,
    type: 'Disc Brake',
  ),
  BrakeCaliper(
    brand: 'Shimano',
    code: 'a1c',
    frontImage: 'assets/images/bike_project/bike_parts/brake_caliper/a1c.png',
    link: 'https://bike.shimano.com/en-US/product/component/shimano/BR-MT420.html',
    name: 'BR-MT420',
    price: 5476.05,
    rearImage: 'assets/images/bike_project/bike_parts/brake_caliper/a1c.png',
    sizeFactor: 0.086,
    type: 'Disc Brake',
  ),
];
final List<Cassette> cassetteItems = [
  Cassette(
    brand: 'SRAM',
    code: 'b1a',
    image: 'assets/images/bike_project/bike_parts/casette/7_speed/b1a.png',
    link: 'https://www.sram.com/en/sram/models/cs-pg-720-a1',
    name: 'CS-PG-720-A1',
    price: 1499.86,
    sizeFactor: 0.062,
    speed: '7 Speed',
  ),
  Cassette(
    brand: 'SRAM',
    code: 'b1b',
    image: 'assets/images/bike_project/bike_parts/casette/7_speed/b1b.png',
    link: 'https://www.sram.com/en/sram/models/cs-pg-730-a1',
    name: 'CS-PG-730-A1',
    price: 822.5,
    sizeFactor: 0.062,
    speed: '7 Speed',
  ),
  Cassette(
    brand: 'Shimano',
    code: 'b2a',
    image: 'assets/images/bike_project/bike_parts/casette/8_speed/b2a.png',
    link: 'https://bike.shimano.com/en-US/product/component/tourney-tx800/CS-HG200-8.html',
    name: 'CS-HG200-8',
    price: 579,
    sizeFactor: 0.062,
    speed: '8 Speed',
  ),
  Cassette(
    brand: 'Shimano',
    code: 'b2b',
    image: 'assets/images/bike_project/bike_parts/casette/8_speed/b2b.png',
    link: 'https://www.sram.com/en/sram/models/cs-pg-830-a1',
    name: 'CS-PG-830-A1',
    price: 967.65,
    sizeFactor: 0.062,
    speed: '8 Speed',
  ),
  Cassette(
    brand: 'Shimano',
    code: 'b3a',
    image: 'assets/images/bike_project/bike_parts/casette/9_speed/b3a.png',
    link: 'https://bike.shimano.com/en-US/product/component/alivio-m4000/CS-HG400-9.html',
    name: 'CS-HG400-9',
    price: 2031.58,
    sizeFactor: 0.062,
    speed: '9 Speed',
  ),
  Cassette(
    brand: 'SRAM',
    code: 'b3b',
    image: 'assets/images/bike_project/bike_parts/casette/9_speed/b3b.png',
    link: 'https://www.sram.com/en/sram/models/cs-pg-920-a1',
    name: 'CS-PG-920-A1',
    price: 1644.52,
    sizeFactor: 0.062,
    speed: '9 Speed',
  ),
  Cassette(
    brand: 'Shimano',
    code: 'b4a',
    image: 'assets/images/bike_project/bike_parts/casette/10_speed/b4a.png',
    link: 'https://bike.shimano.com/en-US/product/component/slx-m7000/CS-HG81-10.html',
    name: 'CS-HG81-10',
    price: 2549,
    sizeFactor: 0.062,
    speed: '10 Speed',
  ),
  Cassette(
    brand: 'Shimano',
    code: 'b4b',
    image: 'assets/images/bike_project/bike_parts/casette/10_speed/b4b.png',
    link: 'https://bike.shimano.com/en-US/product/component/deore-m4100/CS-M4100-10.html',
    name: 'CS-M4100-10',
    price: 1680,
    sizeFactor: 0.062,
    speed: '10 Speed',
  ),
];
final List<Crankset> cranksetItems = [
  Crankset(
    brand: 'Trek',
    code: 'c1a',
    image: 'assets/images/bike_project/bike_parts/crankset/1_speed/c1a.png',
    link: 'https://www.trekbikes.com/us/en_US/equipment/cycling-components/bike-cranks-chainrings/sram-red-axs-dub-1x-crankset/p/29046/',
    name: 'Red AXS Dub 1x',
    price: 33383.93,
    sizeFactor: 0.138,
    speed: '1 Speed',
  ),
  Crankset(
    brand: 'Trek',
    code: 'c1b',
    image: 'assets/images/bike_project/bike_parts/crankset/1_speed/c1b.png',
    link:
        'https://www.trekbikes.com/us/en_US/equipment/cycling-components/bike-cranks-chainrings/road-bike-cranks/sram-rival-axs-dub-wide-1x-crankset/p/36554/',
    name: 'Rival ACS Dub Wide 1x',
    price: 6289.73,
    sizeFactor: 0.138,
    speed: '1 Speed',
  ),
  Crankset(
    brand: 'Shimano',
    code: 'c2a',
    image: 'assets/images/bike_project/bike_parts/crankset/2_speed/c2a.png',
    link: 'https://bike.shimano.com/en-US/product/component/tiagra-4700/FC-4700.html',
    name: 'FC-4700',
    price: 3400,
    sizeFactor: 0.138,
    speed: '2 Speed',
  ),
  Crankset(
    brand: 'Shimano',
    code: 'c2b',
    image: 'assets/images/bike_project/bike_parts/crankset/2_speed/c2b.png',
    link: 'https://bike.shimano.com/en-US/product/component/tiagra-4600/FC-RS400.html',
    name: 'FC-RS400',
    price: 3580.31,
    sizeFactor: 0.138,
    speed: '2 Speed',
  ),
  Crankset(
    brand: 'Shimano',
    code: 'c3a',
    image: 'assets/images/bike_project/bike_parts/crankset/3_speed/c3a.png',
    link: 'https://bike.shimano.com/en-US/product/component/tiagra-4700/FC-4703.html',
    name: 'FC-4703',
    price: 8143.27,
    sizeFactor: 0.138,
    speed: '3 Speed',
  ),
  Crankset(
    brand: 'Shimano',
    code: 'c3b',
    image: 'assets/images/bike_project/bike_parts/crankset/3_speed/c3b.png',
    link: 'https://bike.shimano.com/en-US/product/component/sora-r3000/FC-R3030.html',
    name: 'FC-R3030',
    price: 5893.92,
    sizeFactor: 0.138,
    speed: '3 Speed',
  ),
];
final List<Frame> frameItems = [
  Frame(
    brand: 'Specialized',
    code: 'd1a',
    image: 'assets/images/bike_project/bike_parts/frame/full/d1a.png',
    link: 'https://specialized.com.ph/collections/s-works-bikes-1/products/s-works-epic-frameset-154348',
    name: 'S-Works Epic',
    price: 214195,
    sizeFactor: 0.504,
    type: 'Full Suspension',
    frontDerailleurTypes: [],
  ),
  Frame(
    brand: 'Yeti',
    code: 'd1b',
    image: 'assets/images/bike_project/bike_parts/frame/full/d1b.png',
    link: 'https://yeticycles.com/bikes/sb150',
    name: 'SB150',
    price: 188672,
    sizeFactor: 0.504,
    type: 'Full Suspension',
    frontDerailleurTypes: [],
  ),
  Frame(
    brand: 'Trek',
    code: 'd1c',
    image: 'assets/images/bike_project/bike_parts/frame/full/d1c.png',
    link: 'https://www.trekbikes.com/us/en_US/bikes/mountain-bikes/trail-mountain-bikes/slash/slash-al-frameset/p/24335/',
    name: 'Slash AL',
    price: 100547.35,
    sizeFactor: 0.504,
    type: 'Full Suspension',
    frontDerailleurTypes: [],
  ),
  Frame(
    brand: 'Yeti',
    code: 'd2a',
    image: 'assets/images/bike_project/bike_parts/frame/hard_trail/d2a.png',
    link: 'https://yeticycles.com/bikes/arc',
    name: 'Arc',
    price: 91642.7,
    sizeFactor: 0.504,
    type: 'Hard Tail',
    frontDerailleurTypes: [],
  ),
  Frame(
      brand: 'Specialized',
      code: 'd2b',
      image: 'assets/images/bike_project/bike_parts/frame/hard_trail/d2b.png',
      link: 'https://www.specialized.com/us/en/s-works-epic-hardtail-frameset/p/154339',
      name: 'S-Works Epic Hard Tail',
      price: 120575,
      sizeFactor: 0.504,
      type: 'Hard Tail',
      frontDerailleurTypes: ['Clamp On', 'Direct Mount']),
  Frame(
    brand: 'Trek',
    code: 'd2c',
    image: 'assets/images/bike_project/bike_parts/frame/hard_trail/d2c.png',
    link: 'https://www.trekbikes.com/us/en_US/bikes/mountain-bikes/cross-country-mountain-bikes/x-caliber/x-caliber-frameset/p/21578/',
    name: 'X Caliber',
    price: 28716.06,
    sizeFactor: 0.504,
    type: 'Hard Tail',
    frontDerailleurTypes: ['Clamp On', 'E Type'],
  ),
];
final List<FrontDerailleur> frontDlrItems = [
  FrontDerailleur(
    brand: 'Shimano',
    code: 'e1a',
    image: 'assets/images/bike_project/bike_parts/front_deraileur/clamp_on/e1a.png',
    link: 'https://bike.shimano.com/en-EU/product/component/tourney/FD-TY300-DS6.html',
    name: 'FD-TY300-DS6',
    price: 346,
    sizeFactor: 0.1,
    type: 'Clamp On',
  ),
  FrontDerailleur(
    brand: 'Shimano',
    code: 'e1b',
    image: 'assets/images/bike_project/bike_parts/front_deraileur/clamp_on/e1b.png',
    link: 'https://bike.shimano.com/en-EU/product/component/alivio-m4000/FD-M4000-DS3.html',
    name: 'FD-M4000-DS3',
    price: 1457,
    sizeFactor: 0.1,
    type: 'Clamp On',
  ),
  FrontDerailleur(
    brand: 'Shimano',
    code: 'e2a',
    image: 'assets/images/bike_project/bike_parts/front_deraileur/direct_mount/e2a.png',
    link: 'https://bike.shimano.com/en-EU/product/component/deore-m6000/FD-M6000-D.html',
    name: 'FD-M6000-D',
    price: 1290,
    sizeFactor: 0.1,
    type: 'Direct Mount',
  ),
  FrontDerailleur(
    brand: 'Shimano',
    code: 'e2b',
    image: 'assets/images/bike_project/bike_parts/front_deraileur/direct_mount/e2b.png',
    link: 'https://bike.shimano.com/en-EU/product/component/deore-m610/FD-M611-D.html',
    name: 'FD-M611-D',
    price: 1090.76,
    sizeFactor: 0.1,
    type: 'Direct Mount',
  ),
  FrontDerailleur(
    brand: 'Shimano',
    code: 'e3a',
    image: 'assets/images/bike_project/bike_parts/front_deraileur/e_type/e3a.png',
    link: 'https://bike.shimano.com/en-EU/product/component/deore-m610/FD-M610-E.html',
    name: 'FD-M610-E',
    price: 1114.41,
    sizeFactor: 0.055,
    type: 'E Type',
  ),
  FrontDerailleur(
    brand: 'Shimano',
    code: 'e3b',
    image: 'assets/images/bike_project/bike_parts/front_deraileur/e_type/e3b.png',
    link: 'https://bike.shimano.com/en-EU/product/component/slx-m7000/FD-M7005-10-E.html',
    name: 'FD-M7005-10-E',
    price: 1309.38,
    sizeFactor: 0.055,
    type: 'E Type',
  ),
];
final List<FrontFork> frontForkItems = [
  FrontFork(
    brand: 'SRAM',
    code: 'f1a',
    image: 'assets/images/bike_project/bike_parts/front_fork/suspension/f1a.png',
    link: 'https://www.sram.com/en/rockshox/models/fs-pike-sel-b4',
    name: 'FS-PIKE-SEL-B4',
    price: 33719,
    sizeFactor: 0.54,
    sizeType: '27.5',
  ),
  FrontFork(
    brand: 'Fox',
    code: 'f1b',
    image: 'assets/images/bike_project/bike_parts/front_fork/suspension/f1b.png',
    link: 'https://www.ridefox.com/family.php?m=bike&family=36',
    name: '36 Factory',
    price: 54945.13,
    sizeFactor: 0.54,
    sizeType: '27.5',
  ),
  FrontFork(
    brand: 'SRAM',
    code: 'f1c',
    image: 'assets/images/bike_project/bike_parts/front_fork/suspension/f1c.png',
    link: 'https://www.sram.com/en/rockshox/models/fs-sids-bse-c1',
    name: 'FS-SIDS-BSE-C1',
    price: 37703.99,
    sizeFactor: 0.54,
    sizeType: '29er',
  ),
  FrontFork(
    brand: 'Fox',
    code: 'f1d',
    image: 'assets/images/bike_project/bike_parts/front_fork/suspension/f1d.png',
    link: 'https://www.ridefox.com/family.php?m=bike&family=32s',
    name: '32 Performance',
    price: 37096.41,
    sizeFactor: 0.54,
    sizeType: '29er',
  ),
];
final List<Handlebar> handlebarItems = [
  Handlebar(
    brand: 'Specialized',
    code: 'g1a',
    image: 'assets/images/bike_project/bike_parts/handlebar/flat_bar/g1a.png',
    link: 'https://www.specialized.com/us/en/alloy-mini-rise-handlebars/p/156572',
    name: 'Alloy Mini Rise',
    price: 2162.84,
    sizeFactor: 0.075,
    type: 'Flat',
  ),
  Handlebar(
    brand: 'Giant',
    code: 'g1b',
    image: 'assets/images/bike_project/bike_parts/handlebar/flat_bar/g1b.png',
    link: 'https://www.giant-bicycles.com/us/contact-sl-xc-flat-handlebar-31dot8x720mm',
    name: 'CONTACT SL XC',
    price: 2784.03,
    sizeFactor: 0.068,
    type: 'Flat',
  ),
  Handlebar(
    brand: 'Giant',
    code: 'g2a',
    image: 'assets/images/bike_project/bike_parts/handlebar/riser_bar/g2a.png',
    link: 'https://www.giant-bicycles.com/int/contact-sl-tr-35-handlebar',
    name: 'CONTACT SL TR',
    price: 3366.2,
    sizeFactor: 0.058,
    type: 'Riser',
  ),
  Handlebar(
    brand: 'Trek',
    code: 'g2b',
    image: 'assets/images/bike_project/bike_parts/handlebar/riser_bar/g2b.png',
    link:
        'https://www.trekbikes.com/us/en_US/equipment/cycling-components/bike-handlebars-accessories/bike-handlebars/mountain-bike-handlebars/bontrager-line-35-mtb-handlebar/p/24154/',
    name: 'Bontrager Line',
    price: 3840.76,
    sizeFactor: 0.06,
    type: 'Riser',
  ),
];
final List<Pedal> pedalItems = [
  Pedal(
    brand: 'Shimano',
    code: 'h1a',
    image: 'assets/images/bike_project/bike_parts/pedal/clipless/h1a.png',
    link: 'https://bike.shimano.com/en-US/product/component/deorext-m8000/PD-M8020.html',
    name: 'PD-M8020',
    price: 2966,
    sizeFactor: 0.05,
    type: 'Clipless',
  ),
  Pedal(
    brand: 'Shimano',
    code: 'h1b',
    image: 'assets/images/bike_project/bike_parts/pedal/clipless/h1b.png',
    link: 'https://bike.shimano.com/en-EU/product/component/deore-m6000/PD-M530.html',
    name: 'PD-M530',
    price: 1999,
    sizeFactor: 0.05,
    type: 'Clipless',
  ),
  Pedal(
    brand: 'Shimano',
    code: 'h2a',
    image: 'assets/images/bike_project/bike_parts/pedal/flat/h2a.png',
    link: 'https://bike.shimano.com/en-US/product/component/deore-xt-m8100/PD-M8140.html',
    name: 'PD-M8140',
    price: 4885,
    sizeFactor: 0.055,
    type: 'Flat',
  ),
  Pedal(
    brand: 'Shimano',
    code: 'h2b',
    image: 'assets/images/bike_project/bike_parts/pedal/flat/h2b.png',
    link: 'https://bike.shimano.com/en-US/product/component/deorext-m8000/PD-M8040.html',
    name: 'PD-M8040',
    price: 4510,
    sizeFactor: 0.055,
    type: 'Flat',
  ),
];
final List<RearDerailleur> rearDlrItems = [
  RearDerailleur(
    brand: 'Shimano',
    code: 'i1a',
    image: 'assets/images/bike_project/bike_parts/rear_deraileur/long_cage/i1a.png',
    link: 'https://bike.shimano.com/en-US/product/component/deore-m6000/RD-M6000-SGS.html',
    name: 'RD-M6000-SGS',
    price: 3279,
    sizeFactor: 0.186,
    type: 'Long Cage',
  ),
  RearDerailleur(
    brand: 'SRAM',
    code: 'i1b',
    image: 'assets/images/bike_project/bike_parts/rear_deraileur/long_cage/i1b.png',
    link: 'https://www.sram.com/en/sram/models/rd-gx-t21-a1',
    name: 'RD-GX-T21-A1',
    price: 3170,
    sizeFactor: 0.186,
    type: 'Long Cage',
  ),
];
final List<Rim> rimItems = [
  Rim(
    brand: 'Trek',
    code: 'k1a',
    frontImage: 'assets/images/bike_project/bike_parts/rim/27.5in/k1a_front.png',
    link:
        'https://www.trekbikes.com/us/en_US/equipment/cycling-components/bike-wheels/mountain-bike-wheels/bontrager-line-comp-30-tlr-boost-27-5-disc-mtb-wheel/p/21833/',
    name: 'Line Comp 30 TLR Boost',
    price: 14317.41,
    rearImage: 'assets/images/bike_project/bike_parts/rim/27.5in/k1a_rear.png',
    sizeFactor: 0.31,
    sizeType: '27.5',
  ),
  Rim(
    brand: 'Shimano',
    code: 'k1b',
    frontImage: 'assets/images/bike_project/bike_parts/rim/27.5in/k1b_front.png',
    link: 'https://bike.shimano.com/en-US/product/component/shimano/WH-MT601-TL-F15-275.html',
    name: 'WH-MT601-TL-F15-275',
    price: 10011.14,
    rearImage: 'assets/images/bike_project/bike_parts/rim/27.5in/k1b_rear.png',
    sizeFactor: 0.31,
    sizeType: '27.5',
  ),
  Rim(
    brand: 'Specialized',
    code: 'k2a',
    frontImage: 'assets/images/bike_project/bike_parts/rim/29in/k2a_front.png',
    link: 'https://www.specialized.com/us/en/stout-xc-sl-29-front/p/160077',
    name: 'Stout XC SL',
    price: 12251.48,
    rearImage: 'assets/images/bike_project/bike_parts/rim/29in/k2a_rear.png',
    sizeFactor: 0.335,
    sizeType: '29er',
  ),
  Rim(
    brand: 'Shimano',
    code: 'k2b',
    frontImage: 'assets/images/bike_project/bike_parts/rim/29in/k2b_front.png',
    link: 'https://bike.shimano.com/en-EU/product/component/shimano/WH-MT620-TL-F15-B-29.html',
    name: 'WH-MT620-TL-F15-B-29',
    price: 13293.09,
    rearImage: 'assets/images/bike_project/bike_parts/rim/29in/k2b_rear.png',
    sizeFactor: 0.335,
    sizeType: '29er',
  ),
];

final List<Saddle> saddleItems = [
  Saddle(
    brand: 'Specialized',
    code: 'j1a',
    image: 'assets/images/bike_project/bike_parts/saddle/cutaway/j1a.png',
    link: 'https://www.specialized.com/hn/en/henge-comp/p/155702',
    name: 'Henge Comp',
    price: 2966,
    sizeFactor: 0.34,
    type: 'Cutaway',
  ),
  Saddle(
    brand: 'Giant',
    code: 'j1b',
    image: 'assets/images/bike_project/bike_parts/saddle/cutaway/j1b.png',
    link: 'https://www.giant-bicycles.com/int/fleet-sl',
    name: 'Fleet SL',
    price: 1999,
    sizeFactor: 0.34,
    type: 'Cutaway',
  ),
  Saddle(
    brand: 'Specialized',
    code: 'j2a',
    image: 'assets/images/bike_project/bike_parts/saddle/racing/j2a.png',
    link: 'https://specialized.com.ph/collections/saddles/products/romin-evo-expert-gel-132805',
    name: 'Evo Expert Gel',
    price: 4885,
    sizeFactor: 0.34,
    type: 'Racing',
  ),
  Saddle(
    brand: 'Giant',
    code: 'j2b',
    image: 'assets/images/bike_project/bike_parts/saddle/racing/j2b.png',
    link: 'https://www.giant-bicycles.com/int/contact-comfort-forward-giant-2018',
    name: 'Contact Comfort Forward',
    price: 4510,
    sizeFactor: 0.34,
    type: 'Racing',
  ),
];

final List<Tire> tireItems = [
  Tire(
    brand: 'Specialized',
    code: 'l1a',
    frontImage: 'assets/images/bike_project/bike_parts/tire/all_mountain/l1a.png',
    link: 'https://www.specialized.com/us/en/ground-control-sport/p/157364',
    name: 'Ground Control Sport',
    price: 1441.35,
    rearImage: 'assets/images/bike_project/bike_parts/tire/all_mountain/l1a.png',
    type: 'All Mountain',
  ),
  Tire(
    brand: 'Specialized',
    code: 'l1b',
    frontImage: 'assets/images/bike_project/bike_parts/tire/all_mountain/l1b.png',
    link: 'https://www.specialized.com/us/en/ground-control-control-2bliss-ready/p/173636',
    name: 'Ground Control Control',
    price: 2882.7,
    rearImage: 'assets/images/bike_project/bike_parts/tire/all_mountain/l1b.png',
    type: 'All Mountain',
  ),
  Tire(
    brand: 'Specialized',
    code: 'l2a',
    frontImage: 'assets/images/bike_project/bike_parts/tire/cross_country/l2a.png',
    link: 'https://www.specialized.com/us/en/fast-trak-grid-2bliss-ready/p/155276',
    name: 'Fast Trak Grid',
    price: 1729.14,
    rearImage: 'assets/images/bike_project/bike_parts/tire/cross_country/l2a.png',
    type: 'Cross Country',
  ),
  Tire(
    brand: 'Specialized',
    code: 'l2b',
    frontImage: 'assets/images/bike_project/bike_parts/tire/cross_country/l2b.png',
    link: 'https://www.specialized.com/us/en/fast-trak-control-2bliss-ready/p/173635',
    name: 'Fast Trak Control',
    price: 2882.7,
    rearImage: 'assets/images/bike_project/bike_parts/tire/cross_country/l2b.png',
    type: 'Cross Country',
  ),
  Tire(
    brand: 'Specialized',
    code: 'l3a',
    frontImage: 'assets/images/bike_project/bike_parts/tire/trail_riding/l3a.png',
    link: 'https://www.specialized.com/us/en/butcher-grid-trail-2bliss-ready-t9/p/187347',
    name: 'Butcher Grid Trail',
    price: 2882.7,
    rearImage: 'assets/images/bike_project/bike_parts/tire/trail_riding/l3a.png',
    type: 'Trail Riding',
  ),
  Tire(
    brand: 'Specialized',
    code: 'l3b',
    frontImage: 'assets/images/bike_project/bike_parts/tire/trail_riding/l3b.png',
    link: 'https://www.specialized.com/us/en/eliminator-grid-2bliss-ready-t7/p/187435',
    name: 'Eliminator Grid',
    price: 2882.7,
    rearImage: 'assets/images/bike_project/bike_parts/tire/trail_riding/l3b.png',
    type: 'Trail Riding',
  ),
];

final List<Accessory> bellItems = [
  Accessory(
    brand: 'Giant',
    code: 'q1a',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/bell/q1a.png',
    link: 'https://www.giant-bicycles.com/int/ding-a-ling-slim-bell',
    name: 'Ding-a-Ling Slim',
    price: 434.16,
    rearImage: '',
    sizeFactorFront: 0.045,
  ),
  Accessory(
    brand: 'Trek',
    code: 'q1b',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/bell/q1b.png',
    link:
        'https://www.trekbikes.com/us/en_US/equipment/bike-accessories/bike-mirrors-bells-horns/bike-bells-horns/mirrycle-incredibell-clever-lever-bike-bell/p/04743/',
    name: 'Incredibell Clever',
    price: 578.4,
    rearImage: '',
    sizeFactorFront: 0.025,
  ),
];

final List<Accessory> bottleCageItems = [
  Accessory(
    brand: 'Specialized',
    code: 'm1a',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/bottle_cage/m1a.png',
    link: 'https://specialized.com.ph/collections/bottle-cages/products/zee-cage-ii-left-171461',
    name: 'Zee Cage 2',
    price: 1595,
    rearImage: '',
    sizeFactorFront: 0.208,
  ),
  Accessory(
    brand: 'Scott',
    code: 'm1b',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/bottle_cage/m1b.png',
    link: 'https://www.scott-sports.com/global/en/product/syncros-coupe-cage-1-0-bottle-cage',
    name: 'Syncros Coupe Cage 1.0',
    price: 1119.04,
    rearImage: '',
    sizeFactorFront: 0.208,
  ),
];
final List<Accessory> fenderItems = [
  Accessory(
    brand: 'Fox',
    code: 'n1a',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/fender/n1a.png',
    link: 'https://www.foxracing.com/mud-guard-%5Bblk%2Fblk%5D-os/25665-021-OS.html',
    name: 'Mud Guard',
    price: 624.71,
    rearImage: 'assets/images/bike_project/bike_parts/accessories/fender/n1a.png',
    sizeFactorFront: 0.12,
    sizeFactorRear: 0.12,
  ),
  Accessory(
    brand: 'Scott',
    code: 'n1b',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/fender/n1b.png',
    link: 'https://www.scott-sports.com/global/en/product/syncros-trail-fender',
    name: 'Syncros Trail Fender',
    price: 932.44,
    rearImage: 'assets/images/bike_project/bike_parts/accessories/fender/n1b.png',
    sizeFactorFront: 0.1,
    sizeFactorRear: 0.1,
  ),
];
final List<Accessory> kickstandItems = [
  Accessory(
    brand: 'Trek',
    code: 'p1a',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/kickstand/p1a.png',
    link:
        'https://www.trekbikes.com/us/en_US/equipment/cycling-components/bike-kickstands/bontrager-adjustable-integrated-rear-mount-kickstand/p/22619/',
    name: 'Bontrager Adjustable Integrated Rear Mount',
    price: 723.11,
    rearImage: '',
    sizeFactorFront: 0.32,
  ),
  Accessory(
    brand: 'Scott',
    code: 'p1b',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/kickstand/p1b.png',
    link: 'https://www.scott-sports.com/global/en/product/syncros-2-bolts-direct-mount-kickstand',
    name: 'Syncros 2 Bolts Direct Mount',
    price: 964.31,
    rearImage: '',
    sizeFactorFront: 0.32,
  ),
];
final List<Accessory> lightItems = [
  Accessory(
    brand: 'Generic',
    code: 'o1a',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/light/o1a_front.png',
    link:
        'https://shopee.ph/%E3%80%90AC%EF%BC%86Available%E3%80%91Bicycle-Front-Rear-Plsatic-Reflective-Lens-MTB-Road-Bike-Night-Safe-Warning-i.206467060.4616162725',
    name: 'Reflective Lens',
    price: 50,
    rearImage: 'assets/images/bike_project/bike_parts/accessories/light/o1a_rear.png',
    sizeFactorFront: 0.022,
    sizeFactorRear: 0.035,
  ),
  Accessory(
    brand: 'Trek',
    code: 'o1b',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/light/o1b_front.png',
    link: 'https://www.trekbikes.com/us/en_US/equipment/bike-accessories/bike-lights/bike-light-sets/bontrager-ion-120/flare-1-light-set/p/32356/',
    name: 'Bontrager Ion 120/Flare 1 Light Set',
    price: 1929.11,
    rearImage: 'assets/images/bike_project/bike_parts/accessories/light/o1b_rear.png',
    sizeFactorFront: 0.058,
    sizeFactorRear: 0.053,
  ),
  Accessory(
    brand: 'Specialized',
    code: 'o1c',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/light/o1c_front.png',
    link: 'https://specialized.com.ph/collections/lights/products/stix-switch-headlight-taillight-173324',
    name: 'Stix Switch Headlight/Taillight',
    price: 1895,
    rearImage: 'assets/images/bike_project/bike_parts/accessories/light/o1c_rear.png',
    sizeFactorFront: 0.02,
    sizeFactorRear: 0.058,
  ),
];
final List<Accessory> phoneHolderItems = [
  Accessory(
    brand: 'Rockbros',
    code: 'r1a',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/phone_holder/r1a.png',
    link: 'https://shopee.ph/ROCKBROS-017-2BK-Bicycle-Bag-Waterproof-Touch-Screen-Cycling-Bag-Top-Tube-i.172104743.4173747481',
    name: '017-2BK',
    price: 650,
    rearImage: '',
    sizeFactorFront: 0.098,
  ),
  Accessory(
    brand: 'Rockbros',
    code: 'r1b',
    frontImage: 'assets/images/bike_project/bike_parts/accessories/phone_holder/r1b.png',
    link: 'https://shopee.ph/ROCKBROS-Below-6.8-Inch-Phone-Bicycle-Bags-Waterproof-1.7L-Top-Tube-Handlebar-i.66842532.7054110058',
    name: 'B68',
    price: 618,
    rearImage: '',
    sizeFactorFront: 0.098,
  ),
];