import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/navigate.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
part 'bike_activity_history/activity_chart.dart';
part 'bike_activity_history/ride_session_viewer.dart';

class UserActivityHistory extends StatefulWidget {
  @override
  _UserActivityHistoryState createState() => _UserActivityHistoryState();
}

class _UserActivityHistoryState extends State<UserActivityHistory> {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  final Box<BikeActivity> _bikeActivitiesBox = Hive.box<BikeActivity>('${currentUser!.profileNumber}bikeActivities');
  bool _enableJumpBtn = false, _isAscending = true;
  int _sortColumnIndex = 1;
  //int _addButtonCounter = 0;
  List<BikeActivity> _activitiesData = [], _selected = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(() {
        _scrollController.position.isScrollingNotifier.addListener(_showJumpToTopButton);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        Stack(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 46,
                              ),
                              child: Container(
                                color: Color(0xFF496D47),
                                child: Center(
                                  child: ValueListenableBuilder<Box<BikeActivity>>(
                                    valueListenable: _bikeActivitiesBox.listenable(),
                                    builder: (_, box, __) {
                                      if (box.values.isEmpty) {
                                        return Text('User Activity History', style: TextStyle(color: Colors.white));
                                      } else {
                                        return ActivityChart(box: _bikeActivitiesBox);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder<Box<BikeActivity>>(
                          valueListenable: _bikeActivitiesBox.listenable(),
                          builder: (_, box, __) {
                            if (box.values.isEmpty) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    r'No Ride Session Recorded ¯\_(ツ)_/¯',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Center(
                                    child: OutlinedButton(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.navigation_rounded),
                                          Text('Start Navigating'),
                                        ],
                                      ),
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                          (states) => Color(0xFF3D5164),
                                        ),
                                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                          (states) => Colors.white,
                                        ),
                                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                                          (states) => Color(0xFF3D5164).withOpacity(0.8),
                                        ),
                                        side: MaterialStateProperty.resolveWith<BorderSide>(
                                          (states) => BorderSide(color: Color(0xFF3D5164), width: 1.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(context, CustomRoutes.fadeThrough(page: Navigate(), duration: Duration(milliseconds: 300)));
                                      },
                                    ),
                                  )
                                ],
                              );
                            } else {
                              if (_activitiesData.length != box.values.length) {
                                _activitiesData = box.values.toList();
                                onSortColumn(_sortColumnIndex, _isAscending);
                              }
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme.copyWith(
                                          primary: Color(0xFF496D47),
                                          onPrimary: Colors.white,
                                        ),
                                  ),
                                  child: DataTable(
                                    headingTextStyle: TextStyle(color: Color(0xFF496D47), fontWeight: FontWeight.w700),
                                    dataTextStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600,
                                    ),
                                    dataRowColor: MaterialStateProperty.resolveWith(
                                        (states) => states.contains(MaterialState.selected) ? Color(0xFF496D47).brighten(0.5) : Colors.transparent),
                                    sortAscending: _isAscending,
                                    sortColumnIndex: _sortColumnIndex,
                                    columnSpacing: 20,
                                    showCheckboxColumn: true,
                                    columns: [
                                      DataColumn(
                                        label: Text('Map'),
                                        tooltip: 'Long press to see map.',
                                      ),
                                      DataColumn(
                                        label: Text('Date'),
                                        tooltip: 'The date of the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Start'),
                                        tooltip: 'The starting location of the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('End'),
                                        tooltip: 'The ending location of the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Average\nSpeed'),
                                        tooltip: 'The calculated average speed of the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Calories\nBurned'),
                                        tooltip: 'The total burned calories during the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Distance'),
                                        tooltip: 'The total distance traveled of the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Max\nElevation'),
                                        tooltip: 'The maximum elevation attained in the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Duration'),
                                        tooltip: 'The total duration of the ride session.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: Text('Weather'),
                                        tooltip: 'The weather status when the ride session started.',
                                        onSort: (columnIndex, ascending) {
                                          onSortColumn(columnIndex, ascending);
                                          setState(() {
                                            _isAscending = ascending;
                                            _sortColumnIndex = columnIndex;
                                          });
                                        },
                                      ),
                                    ],
                                    rows: _activitiesData
                                        .map(
                                          (activity) => DataRow(
                                            selected: _selected.contains(activity),
                                            onSelectChanged: (val) {
                                              onSelectedRow(val!, activity);
                                            },
                                            cells: [
                                              DataCell(
                                                Ink(
                                                  width: 30,
                                                  child: InkWell(
                                                    child: Icon(
                                                      Icons.map_outlined,
                                                      color: Color(0xFF496D47),
                                                    ),
                                                    onLongPress: () {
                                                      Navigator.push<Map<String, dynamic>>(
                                                        context,
                                                        CustomRoutes.fadeScale(page: RideSessionViewer(activity: activity)),
                                                      ).then((result) {
                                                        //DELETES THE FILE GENERATED BY SCREENSHOT CONTROLLER.
                                                        if (result!['takenScreenshot'] as bool) {
                                                          FunctionHelper.deleteImage((result['imagePath'] as String));
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  DateFormat('MM-dd-y hh:mm a').format(activity.activityDate!),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 300,
                                                  child: Text(
                                                    activity.startLocation!,
                                                    maxLines: 3,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 300,
                                                  child: Text(
                                                    activity.endLocation!,
                                                    maxLines: 3,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${activity.averageSpeed!.toStringAsFixed(2)} m/s',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${activity.burnedCalories!.toStringAsFixed(2)}',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${activity.distance!.toStringAsFixed(2)} km',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${activity.elevation!.toStringAsFixed(2)} m',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${StopWatchTimer.getDisplayTimeMinute(activity.duration!, hours: false)} min',
                                                ),
                                              ),
                                              DataCell(
                                                Tooltip(
                                                  message: '${activity.weatherData!.weatherDescription}',
                                                  child: Text(
                                                    '${activity.weatherData!.temperature.toString().replaceAll(RegExp(r'Celsius'), '°C')}',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Selected: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                          children: [
                            TextSpan(
                              text: '${_selected.length}',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: OutlinedButton(
                          child: Text('Delete Selected'),
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.disabled) ? Colors.grey.shade400 : Colors.white,
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.disabled) ? Colors.white : Color(0xFF496D47).brighten(0.05),
                            ),
                            overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.pressed) ? Color(0xFF496D47).darken(0.05) : Colors.transparent,
                            ),
                            side: MaterialStateProperty.resolveWith<BorderSide>(
                              (states) =>
                                  states.contains(MaterialState.disabled) ? BorderSide(color: Colors.grey.shade400, width: 1.0) : BorderSide.none,
                            ),
                          ),
                          onPressed: _selected.isEmpty
                              ? null
                              : () {
                                  List<DateTime?> selectedDates = _selected.map((e) => e.activityDate).toList();
                                  List<dynamic> keys = _bikeActivitiesBox
                                      .toMap()
                                      .entries
                                      .where((element) => selectedDates.contains(element.value.activityDate))
                                      .map((e) => e.key)
                                      .toList();
                                  _deleteSelected(keys);
                                },
                        ),
                      ),
                      /* Opacity(
                        opacity: _addButtonCounter < 3 ? 0 : 1.0,
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.grey),
                          onPressed: () {
                            if (_addButtonCounter < 3) {
                              setState(() {
                                _addButtonCounter++;
                              });
                            } else {
                              _addRandom();
                            }
                          },
                        ),
                      ), */
                    ],
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: Visibility(
                  visible: _enableJumpBtn,
                  child: ClipOval(
                    child: Material(
                      child: Ink(
                        height: 40,
                        width: 40,
                        color: Color(0xFF496D47).brighten(0.1),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_upward_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _scrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: !sosEnabled['User Activity']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                ),
        ),
      ),
    );
  }

  void _showJumpToTopButton() {
    if (!_scrollController.position.isScrollingNotifier.value) {
      if (_scrollController.offset.round() >= 200 && !_enableJumpBtn) {
        setState(() {
          _enableJumpBtn = true;
        });
      } else if (_scrollController.offset.round() < 200 && _enableJumpBtn) {
        setState(() {
          _enableJumpBtn = false;
        });
      }
    }
  }

  ///Sorting the datatable.
  void onSortColumn(int columnIndex, bool ascending) {
    //Activity Date
    if (columnIndex == 1) {
      if (ascending) {
        //Sorts to latest on top
        _activitiesData.sort((a, b) => b.activityDate!.compareTo(a.activityDate!));
      } else {
        //Sorts to latest on bottom
        _activitiesData.sort((a, b) => a.activityDate!.compareTo(b.activityDate!));
      }
      //Start Location
    } else if (columnIndex == 2) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.startLocation!.compareTo(b.startLocation!));
      } else {
        _activitiesData.sort((a, b) => b.startLocation!.compareTo(a.startLocation!));
      }
      //End Location
    } else if (columnIndex == 3) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.endLocation!.compareTo(b.endLocation!));
      } else {
        _activitiesData.sort((a, b) => b.endLocation!.compareTo(a.endLocation!));
      }
      //Average Speed
    } else if (columnIndex == 4) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.averageSpeed!.compareTo(b.averageSpeed!));
      } else {
        _activitiesData.sort((a, b) => b.averageSpeed!.compareTo(a.averageSpeed!));
      }
      //Calories Burned
    } else if (columnIndex == 5) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.burnedCalories!.compareTo(b.burnedCalories!));
      } else {
        _activitiesData.sort((a, b) => b.burnedCalories!.compareTo(a.burnedCalories!));
      }
      //Distance
    } else if (columnIndex == 6) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.distance!.compareTo(b.distance!));
      } else {
        _activitiesData.sort((a, b) => b.distance!.compareTo(a.distance!));
      }
      //Max Elevation
    } else if (columnIndex == 7) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.elevation!.compareTo(b.elevation!));
      } else {
        _activitiesData.sort((a, b) => b.elevation!.compareTo(a.elevation!));
      }
      //Duration
    } else if (columnIndex == 8) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.duration!.compareTo(b.duration!));
      } else {
        _activitiesData.sort((a, b) => b.duration!.compareTo(a.duration!));
      }
    } else if (columnIndex == 9) {
      if (ascending) {
        _activitiesData.sort((a, b) => a.weatherData!.temperature!.celsius!.compareTo(b.weatherData!.temperature!.celsius!));
      } else {
        _activitiesData.sort((a, b) => b.weatherData!.temperature!.celsius!.compareTo(a.weatherData!.temperature!.celsius!));
      }
    }
  }

  void onSelectedRow(bool selected, BikeActivity activity) {
    setState(() {
      if (selected) {
        _selected.add(activity);
      } else {
        _selected.remove(activity);
      }
    });
  }

/*   void _addRandom() {
    _bikeActivitiesBox.add(
      BikeActivity(
        startLocation: FunctionHelper.randomLocation(),
        endLocation: FunctionHelper.randomLocation(),
        activityDate: FunctionHelper.randomActivityDate(),
        averageSpeed: FunctionHelper.randomDouble(min: 1.0, max: 8.5),
        burnedCalories: FunctionHelper.randomDouble(min: 130, max: 386),
        distance: FunctionHelper.randomDouble(min: 0.5, max: 30.99),
        elevation: FunctionHelper.randomDouble(min: 2.5, max: 39.99),
        duration: FunctionHelper.randomInt(min: 600000, max: 3840000),
        weatherData: FunctionHelper.sampleWeather(),
        coordinates: FunctionHelper.sampleCoordinates(),
        latLngBounds: FunctionHelper.sampleLatLngBounds(),
      ),
    );
  } */

  void _deleteSelected(List<dynamic> keys) {
    if (keys.isNotEmpty) {
      _bikeActivitiesBox.deleteAll(keys);
    }
    setState(() {
      _enableJumpBtn = false;
      _selected.clear();
    });
  }
}
