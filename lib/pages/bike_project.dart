import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/bike_build.dart';
import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/pages/bike_editor.dart';
import 'package:cadence_mtb/pages/bike_summary.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BikeProject extends StatefulWidget {
  @override
  _BikeProjectState createState() => _BikeProjectState();
}

class _BikeProjectState extends State<BikeProject> {
  List<BikeBuild> bikeProjects = [];

  @override
  void initState() {
    super.initState();
    getBikeProjects();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFFFF8B02), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: AutoSizeText(
              'Bike Project',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              maxLines: 1,
            ),
            backgroundColor: Color(0xFFFF8B02),
            elevation: 5,
          ),
          body: Container(
            child: ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(10),
              children: [
                AutoSizeText(
                  'Projects',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w700),
                  minFontSize: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  height: _size.height * (_isPortrait ? 0.08 : 0.13),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bikeProjects.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.all(2.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomRoutes.fadeThrough(
                                  page: BikeEditor(
                                    projectList: bikeProjects,
                                  ),
                                  duration: Duration(milliseconds: 300),
                                ),
                              ).then((value) {
                                getBikeProjects();
                                setState(() {});
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade600,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return PopupMenuButton<int>(
                          onSelected: (value) {
                            switch (value) {
                              case 1:
                                Navigator.push(
                                  context,
                                  CustomRoutes.fadeThrough(
                                    page: BikeSummary(
                                      project: bikeProjects[index - 1],
                                    ),
                                    duration: Duration(milliseconds: 300),
                                  ),
                                );
                                break;
                              case 2:
                                Navigator.push(
                                  context,
                                  CustomRoutes.fadeThrough(
                                    page: BikeEditor(
                                      projectList: bikeProjects,
                                      index: index - 1,
                                    ),
                                    duration: Duration(milliseconds: 300),
                                  ),
                                ).then((value) {
                                  getBikeProjects();
                                  setState(() {});
                                });
                                break;
                              case 3:
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        content: Text('Delete Project?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                bikeProjects.removeAt(index - 1);
                                              });
                                              List<String> decreasedList = bikeProjects.map((e) => e.toJson()).toList();
                                              StorageHelper.setStringList('${currentUser!.profileNumber}bikeProjects', decreasedList);
                                              Navigator.pop(context);
                                            },
                                            child: Text('Yes'),
                                            style: TextButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('No'),
                                            style: TextButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                          ),
                                        ],
                                      );
                                    });

                                break;
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 3.0),
                            child: Chip(
                              backgroundColor: Colors.grey.shade600,
                              label: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text(
                                  bikeProjects[index - 1].name,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                            PopupMenuItem(
                              height: 40,
                              value: 1,
                              child: Text('View Summary'),
                            ),
                            PopupMenuItem(
                              height: 40,
                              value: 2,
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              height: 40,
                              value: 3,
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                AutoSizeText(
                  'Bike Parts',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                  minFontSize: 25,
                ),
                Text.rich(
                  TextSpan(
                    style: TextStyle(),
                    children: [
                      WidgetSpan(
                        child: Image.asset(
                          'assets/images/bike_project/brands/fox.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          scale: 3,
                        ),
                      ),
                      WidgetSpan(
                        child: Image.asset(
                          'assets/images/bike_project/brands/giant.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          scale: 2,
                        ),
                      ),
                      WidgetSpan(
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.2,
                              child: Image.asset(
                                'assets/images/bike_project/brands/scott.png',
                                color: Colors.white,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                scale: 2.6,
                              ),
                            ),
                            ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                                child: Image.asset(
                                  'assets/images/bike_project/brands/scott.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  scale: 2.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      WidgetSpan(
                        child: Image.asset(
                          'assets/images/bike_project/brands/shimano.png',
                          fit: BoxFit.contain,
                          scale: 2.5,
                        ),
                      ),
                      WidgetSpan(
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.2,
                              child: Image.asset(
                                'assets/images/bike_project/brands/specialized.png',
                                color: Colors.white,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                scale: 2,
                              ),
                            ),
                            ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                                child: Image.asset(
                                  'assets/images/bike_project/brands/specialized.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  scale: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      WidgetSpan(
                        child: Image.asset(
                          'assets/images/bike_project/brands/sram.png',
                          fit: BoxFit.contain,
                          scale: 2.8,
                        ),
                      ),
                      WidgetSpan(
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.2,
                              child: Image.asset(
                                'assets/images/bike_project/brands/trek.png',
                                color: Colors.white,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                scale: 3.0,
                              ),
                            ),
                            ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                                child: Image.asset(
                                  'assets/images/bike_project/brands/trek.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  scale: 3.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      WidgetSpan(
                        child: Image.asset(
                          'assets/images/bike_project/brands/yeti.png',
                          fit: BoxFit.contain,
                          scale: 3,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Theme(
                  data: Theme.of(context).copyWith(cardColor: Colors.transparent),
                  child: ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.zero,
                    elevation: 0,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _bikeParts[index].isExpanded = !isExpanded;
                      });
                    },
                    children: List.generate(
                      _bikeParts.length,
                      (partIndex) => ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _bikeParts[partIndex].isExpanded,
                        headerBuilder: (BuildContext context, bool isExpanded) => Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            _bikeParts[partIndex].part,
                            style: TextStyle(fontWeight: FontWeight.w700),
                            minFontSize: 20,
                          ),
                        ),
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _bikeParts[partIndex].types.length,
                            (typeIndex) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: AutoSizeText(
                                    '• ' + _bikeParts[partIndex].types[typeIndex],
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                if (_bikeParts[partIndex].subtypes != null)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      _bikeParts[partIndex].subtypes!.length,
                                      (subTypeIndex) => Container(
                                        padding: EdgeInsets.only(left: 35.0),
                                        width: double.maxFinite,
                                        child: AutoSizeText(
                                          '-' + _bikeParts[partIndex].subtypes![typeIndex][subTypeIndex],
                                          textAlign: TextAlign.left,
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
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: !sosEnabled['Bike Project']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  void getBikeProjects() {
    List<String> jsonProjects = StorageHelper.getStringList('${currentUser!.profileNumber}bikeProjects') ?? [];
    if (jsonProjects.isNotEmpty) {
      bikeProjects = jsonProjects.map((e) => BikeBuild.fromJson(e)).toList();
    }
  }
}

final List<BikeProjectItem> _bikeParts = [
  BikeProjectItem(
    part: 'Brake Caliper',
    types: ['Disc Brake Caliper'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Cassette',
    types: [
      '7 Speed',
      '8 Speed',
      '9 Speed',
      '10 Speed',
    ],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Crankset',
    types: ['1 Speed', '2 Speed', '3 Speed'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Frame Types and Rear Suspension',
    types: ['Full Suspension', 'Hard Tail'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Front Derailleur',
    types: ['Clamp On', 'Direct Mount', 'E Type', 'None'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Front Fork',
    types: ['Suspension'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Handlebars',
    types: ['Flat Bar', 'Riser Bar'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Pedal',
    types: ['Flat', 'Clipless'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Rear Derailleur',
    types: ['Long Cage'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Saddle',
    types: ['Racing', 'Cutaway'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Wheel',
    types: ['Rim', 'Tire'],
    subtypes: [
      ['27.5"', '29"'],
      ['All Mountain', 'Cross Country', 'Trail Riding']
    ],
    //preview: '',
  ),
];
