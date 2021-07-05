import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/bike_activity.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/pages/navigate.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

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
                                                      showModal<Map<String, dynamic>>(
                                                        context: (context),
                                                        configuration: FadeScaleTransitionConfiguration(barrierDismissible: true),
                                                        builder: (_) => MapDialog(activity: activity),
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

class ActivityChart extends StatefulWidget {
  final Box<BikeActivity> box;
  ActivityChart({required this.box});

  @override
  _ActivityChartState createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  //Months
  double _minX = 1;
  double _maxX = 12;
  //Data (default lowest and highest)
  double _minY = 1;
  double _maxY = 5;
  //Interval for the data labels
  double _interval = 0;
  //Data to show in the graph
  String _dataToShow = 'Calories';
  //Unit symbol for the data shown in the graph
  String _dataUnitSymbol = '';
  //List for the activities with the same year as the current.
  List<BikeActivity> _latestList = [];
  //List for the data spots to show in the graph.
  List<FlSpot> _dataSpots = [];

  @override
  void initState() {
    super.initState();
    _dataSpots = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              tooltip: 'Refresh the chart',
              onPressed: () {
                setState(() {
                  _dataSpots = _getData();
                });
              },
            ),
            Listener(
              onPointerDown: (_) => FocusScope.of(context).unfocus(),
              child: DropdownButton<String>(
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                iconEnabledColor: Colors.white,
                dropdownColor: Color(0xFF496D47),
                underline: SizedBox.shrink(),
                value: _dataToShow,
                items: [
                  DropdownMenuItem(child: Text('Speed'), value: 'Speed'),
                  DropdownMenuItem(child: Text('Calories'), value: 'Calories'),
                  DropdownMenuItem(child: Text('Distance'), value: 'Distance'),
                  DropdownMenuItem(child: Text('Duration'), value: 'Duration'),
                  DropdownMenuItem(child: Text('Elevation'), value: 'Elevation'),
                  DropdownMenuItem(child: Text('Weather'), value: 'Weather'),
                ],
                onChanged: (value) {
                  setState(() {
                    _dataToShow = value!;
                    _dataSpots = _getData();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                _dataUnitSymbol,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Container(
          height: 200,
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: EdgeInsets.all(3),
                      getTooltipItems: (data) {
                        if (_dataToShow == 'Duration') {
                          return data.map((e) {
                            int hour = e.y.toInt();
                            double minute = int.tryParse(e.y.toStringAsFixed(2).split('.')[1])! / 100;
                            return LineTooltipItem('${hour.toString().padLeft(2, '0')}:${(minute * 60).toInt().toString().padLeft(2, '0')}',
                                TextStyle(color: Color(0xFF496D47)));
                          }).toList();
                        } else {
                          return data.map<LineTooltipItem>((e) => LineTooltipItem('${e.y}', TextStyle(color: Color(0xFF496D47)))).toList();
                        }
                      })),
              clipData: FlClipData.none(),
              gridData: FlGridData(
                show: true,
                horizontalInterval: _interval,
                drawHorizontalLine: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (val) {
                  return FlLine(strokeWidth: 0.5, color: Colors.white.withOpacity(0.7));
                },
                getDrawingVerticalLine: (val) {
                  return FlLine(strokeWidth: 0.5, color: Colors.white.withOpacity(0.7));
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white, width: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  interval: _interval,
                  margin: 5,
                  reservedSize: 13,
                  showTitles: true,
                  getTextStyles: (value) => TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400),
                  getTitles: (val) {
                    if (_maxY >= 10000) {
                      return (val / 10000).toString();
                    } else if (_maxY >= 1000) {
                      return (val / 1000).toString();
                    } else {
                      return val.round().toString();
                    }
                  },
                ),
                bottomTitles: SideTitles(
                  margin: 5,
                  reservedSize: 13,
                  showTitles: true,
                  //rotateAngle: 90,
                  getTextStyles: (value) => TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400),
                  getTitles: (val) {
                    switch (val.round()) {
                      case 1:
                        return 'Jan';
                      case 2:
                        return 'Feb';
                      case 3:
                        return 'Mar';
                      case 4:
                        return 'Apr';
                      case 5:
                        return 'May';
                      case 6:
                        return 'Jun';
                      case 7:
                        return 'Jul';
                      case 8:
                        return 'Aug';
                      case 9:
                        return 'Sep';
                      case 10:
                        return 'Oct';
                      case 11:
                        return 'Nov';
                      case 12:
                        return 'Dec';
                      default:
                        return '';
                    }
                  },
                ),
              ),
              minX: _minX,
              maxX: _maxX,
              minY: double.parse(_minY.toStringAsFixed(2)),
              maxY: double.parse(_maxY.toStringAsFixed(2)),
              lineBarsData: [
                LineChartBarData(
                  colors: [Colors.white],
                  spots: _dataSpots,
                  isCurved: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      color: Colors.white,
                      strokeColor: Colors.grey,
                      strokeWidth: 1.5,
                    ),
                  ),
                  barWidth: 1,
                  belowBarData: BarAreaData(
                    colors: [Colors.white.withOpacity(0.5)],
                    show: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getData() {
    //List where each month data for the graph is added.
    List<FlSpot> result = [];
    //List where each activity in a month is converted into total average.
    List<double> specificList = [];
    _latestList.clear();
    //Add all the activities with the same year as the current.
    _latestList.addAll(widget.box.values.toList().where((element) => DateTime.now().year == element.activityDate!.year).toList());
    _latestList.sort((a, b) => b.activityDate!.compareTo(a.activityDate!));
    //Distinct months available.
    Set distinctConst = _latestList.map((e) => e.activityDate!.month).toSet();
    //Lowest month available (Jan-Dec)
    _minX = _latestList.map((e) => e.activityDate!.month).toList().getMin.toDouble();
    //Highest month available (Jan-Dec)
    _maxX = _latestList.map((e) => e.activityDate!.month).toList().getMax.toDouble();
    double constant = 10;
    //Calculating the average or total for each month base on the selected data to show.
    switch (_dataToShow) {
      case 'Speed':
        _dataUnitSymbol = 'm/s';
        distinctConst.forEach((month) {
          List<double?> values = _latestList.where((acitivity) => acitivity.activityDate!.month == month).map((e) => e.averageSpeed).toList();
          double average = values.reduce((a, b) => a! + b!)! / values.length;
          specificList.add(average);
          result.add(FlSpot(month.toDouble(), double.parse(average.toStringAsFixed(2))));
        });
        break;
      case 'Calories':
        _dataUnitSymbol = 'kcal';
        distinctConst.forEach((month) {
          List<double?> values = _latestList.where((acitivity) => acitivity.activityDate!.month == month).map((e) => e.burnedCalories).toList();
          double total = values.fold(0, (previousValue, element) => previousValue + element!);
          specificList.add(total);
          result.add(FlSpot(month.toDouble(), double.parse(total.toStringAsFixed(2))));
        });
        break;
      case 'Distance':
        _dataUnitSymbol = 'km';
        distinctConst.forEach((month) {
          List<double?> values = _latestList.where((acitivity) => acitivity.activityDate!.month == month).map((e) => e.distance).toList();
          double total = values.fold(0, (previousValue, element) => previousValue + element!);
          specificList.add(total);
          result.add(FlSpot(month.toDouble(), double.parse(total.toStringAsFixed(2))));
        });
        break;
      case 'Duration':
        _dataUnitSymbol = 'hrs';
        distinctConst.forEach((month) {
          List<double> values = _latestList
              .where((acitivity) => acitivity.activityDate!.month == month)
              .map((e) => StopWatchTimer.getRawMinute(e.duration!).toDouble())
              .toList();
          double total = values.fold(0, (dynamic previousValue, element) => previousValue + element) / 60;
          specificList.add(total);
          result.add(FlSpot(month.toDouble(), double.parse(total.toStringAsFixed(2))));
        });
        break;
      case 'Elevation':
        _dataUnitSymbol = 'm';
        distinctConst.forEach((month) {
          List<double?> values = _latestList.where((acitivity) => acitivity.activityDate!.month == month).map((e) => e.elevation).toList();
          double average = values.reduce((a, b) => a! + b!)! / values.length;
          specificList.add(average);
          result.add(FlSpot(month.toDouble(), double.parse(average.toStringAsFixed(2))));
        });
        break;
      case 'Weather':
        _dataUnitSymbol = '°C';
        distinctConst.forEach((month) {
          List<double?> values =
              _latestList.where((acitivity) => acitivity.activityDate!.month == month).map((e) => e.weatherData!.temperature!.celsius).toList();
          double average = values.reduce((a, b) => a! + b!)! / values.length;
          specificList.add(average);
          result.add(FlSpot(month.toDouble(), double.parse(average.toStringAsFixed(2))));
        });
        break;
    }
    //Round the minY and maxY into ones,tens or hundreds and above based on the highest value available.
    double highest = specificList.getMax as double;
    if (highest >= 5001) {
      _interval = 1000;
      constant = 1000;
    } else if (highest >= 1001 && highest <= 5000) {
      _interval = 500;
      constant = 500;
    } else if (highest >= 501 && highest <= 1000) {
      _interval = 100;
      constant = 100;
    } else if (highest >= 101 && highest <= 500) {
      _interval = 50;
      constant = 50;
    } else if (highest >= 10 && highest <= 100) {
      _interval = 10;
      constant = 10;
    } else {
      _interval = 1;
      constant = 1;
    }
    _minY = ((specificList.getMin / constant).floor() * constant).toDouble();
    _maxY = ((specificList.getMax / constant).ceil() * constant).toDouble();
    return result;
  }
}

class MapDialog extends StatefulWidget {
  final BikeActivity activity;
  MapDialog({Key? key, required this.activity}) : super(key: key);

  @override
  _MapDialogDialogState createState() => _MapDialogDialogState();
}

class _MapDialogDialogState extends State<MapDialog> {
  late BikeActivity _userActivity;
  Completer<GoogleMapController> _sessionMapCompleter = Completer();
  Uint8List? _mapScreenshotBytes;
  bool _showMapScreenshot = false, _takenScreensot = false;
  ScreenshotController _screenshotController = ScreenshotController();
  late Future<List<BitmapDescriptor>> _futureMarkerIcons;
  String _startLocation = '', _endLocation = '', _imagePath = '';
  Set<Marker> _sessionMarkers = {};
  Set<Polyline> _sessionLines = {};

  @override
  void initState() {
    super.initState();
    _userActivity = widget.activity;
    _startLocation = widget.activity.startLocation!;
    _endLocation = widget.activity.endLocation!;
    _futureMarkerIcons = _initializeIcons();
    _sessionLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Expanded(
              flex: 90,
              child: Material(
                color: Color(0xFF496D47),
                child: Screenshot(
                  controller: _screenshotController,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Container(
                          color: Color(0xFF496D47),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 15,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                  child: SvgPicture.asset('assets/images/navigate/app_logo.svg', height: 24, width: 24, fit: BoxFit.contain),
                                ),
                              ),
                              Expanded(
                                flex: 60,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text(
                                    'Cadence MTB',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'LexendGiga',
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 25, child: SizedBox.expand()),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 60,
                        child: Stack(
                          children: [
                            FutureBuilder<List<BitmapDescriptor>>(
                              future: _futureMarkerIcons,
                              builder: (_, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    return GoogleMap(
                                      liteModeEnabled: true,
                                      mapType: MapType.normal,
                                      compassEnabled: false,
                                      buildingsEnabled: false,
                                      mapToolbarEnabled: false,
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                      markers: _sessionMarkers,
                                      polylines: _sessionLines,
                                      initialCameraPosition: CameraPosition(
                                        //DEFAULT CAMERA POSITION (IT IS A REQUIRED PARAMETER SO WE JUST USED MIDDLE OF COORDINATES)
                                        target: _userActivity.coordinates![0]!,
                                        zoom: 18,
                                      ),
                                      onMapCreated: (controller) {
                                        //When the map is created(mounted) we have to quickly update map to focus on the LatLng Bounds.
                                        if (mounted) {
                                          _sessionMapCompleter.complete(controller);
                                          Future.delayed(Duration(milliseconds: 300), () {
                                            controller.moveCamera(CameraUpdate.newLatLngBounds(_userActivity.latLngBounds!, 8.0));
                                            setState(() {
                                              _setMarkersAndPolyline(snapshot.data![0], snapshot.data![1]);
                                            });
                                          });
                                        }
                                      },
                                    );
                                  default:
                                    return SizedBox.expand();
                                }
                              },
                            ),
                            Visibility(
                              visible: _showMapScreenshot,
                              child: _mapScreenshotBytes != null
                                  ? Image.memory(
                                      _mapScreenshotBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 32,
                        child: DefaultTextStyle(
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          child: Container(
                            color: Color(0xFF496D47),
                            width: double.maxFinite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 46,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'Start: ',
                                              children: [
                                                TextSpan(
                                                  text: _startLocation,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 4,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'End: ',
                                              children: [
                                                TextSpan(
                                                  text: _endLocation,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 4,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 18,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 3, 5, 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'Duration: ',
                                              children: [
                                                TextSpan(
                                                  text: StopWatchTimer.getDisplayTime(
                                                        _userActivity.duration!,
                                                        hours: true,
                                                        hoursRightBreak: 'h',
                                                        minute: true,
                                                        minuteRightBreak: 'm',
                                                        second: true,
                                                        milliSecond: false,
                                                      ) +
                                                      's',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'Distance: ',
                                              children: [
                                                TextSpan(
                                                  text: '${_userActivity.distance} km',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 18,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'Max Elevation: ',
                                              children: [
                                                TextSpan(
                                                  text: '${_userActivity.elevation} m',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'Avg. Speed: ',
                                              children: [
                                                TextSpan(
                                                  text: '${_userActivity.averageSpeed} m/s',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 18,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 3, 5, 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 50,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: AutoSizeText.rich(
                                                  TextSpan(
                                                    text: 'Weather: ',
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${_userActivity.weatherData!.temperature.toString().replaceAll(RegExp(r'Celsius'), '°C')}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w300,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  softWrap: true,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 50,
                                          child: AutoSizeText.rich(
                                            TextSpan(
                                              text: 'Calories Burned: ',
                                              children: [
                                                TextSpan(
                                                  text: '${_userActivity.burnedCalories}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
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
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      child: Text('Close'),
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        primary: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pop(context, {'takenScreenshot': _takenScreensot, 'directory': _imagePath});
                      },
                    ),
                    ElevatedButton(
                      child: Text('Share'),
                      style: ElevatedButton.styleFrom(onPrimary: Colors.white, primary: Colors.blue.shade400),
                      onPressed: () async {
                        _takenScreensot = true;
                        GoogleMapController _mapController = await _sessionMapCompleter.future;
                        _mapController.takeSnapshot().then((value) async {
                          setState(() {
                            _mapScreenshotBytes = value;
                            _showMapScreenshot = true;
                          });
                          Directory _tempDir = await getTemporaryDirectory();
                          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
                          await _screenshotController
                              .captureAndSave(_tempDir.path, fileName: fileName, delay: Duration(seconds: 1), pixelRatio: 2.0)
                              .then((image) async {
                            _imagePath = image!;
                            Share.shareFiles([image], subject: 'Session Result', text: 'Check out my ride session result!', mimeTypes: ['image/png']);
                            setState(() {
                              _showMapScreenshot = false;
                            });
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setMarkersAndPolyline(BitmapDescriptor startIcon, BitmapDescriptor endIcon) {
    //Add the session markers after session end
    int _borderWidth = StorageHelper.getInt('${currentUser!.profileNumber}borderWidth') ?? 6;
    int _lineWidth = StorageHelper.getInt('${currentUser!.profileNumber}lineWidth') ?? 4;

    _sessionLines.add(
      Polyline(
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        jointType: JointType.round,
        color: Color(0xFF6A8B00),
        width: _borderWidth,
        visible: true,
        zIndex: 0,
        polylineId: PolylineId('border'),
        points: _userActivity.coordinates as List<LatLng>,
      ),
    );
    _sessionLines.add(
      Polyline(
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        jointType: JointType.round,
        color: Color(0xFF9CCC03),
        width: _lineWidth,
        visible: true,
        zIndex: 1,
        polylineId: PolylineId('line'),
        points: _userActivity.coordinates as List<LatLng>,
      ),
    );
    _sessionMarkers.add(
      Marker(
        markerId: MarkerId('startMarker'),
        zIndex: 3,
        flat: true,
        draggable: false,
        anchor: Offset(0.5, 0.5),
        position: _userActivity.coordinates!.first!,
        icon: startIcon,
      ),
    );
    _sessionMarkers.add(
      Marker(
        markerId: MarkerId('endMarker'),
        zIndex: 3,
        flat: true,
        draggable: false,
        anchor: Offset(0.5, 0.5),
        position: _userActivity.coordinates!.last!,
        icon: endIcon,
      ),
    );
  }

  Future<List<BitmapDescriptor>> _initializeIcons() async {
    //Loads the icons to be used as markers later
    final _startIconMarker =
        BitmapDescriptor.fromBytes(await FunctionHelper.getBytesFromAsset('assets/images/navigate/starting_point_icon_v4.png', 50));
    final _endIconMarker = BitmapDescriptor.fromBytes(await FunctionHelper.getBytesFromAsset('assets/images/navigate/end_point_icon_v4.png', 50));
    return [_startIconMarker, _endIconMarker];
  }

  void _sessionLocations() async {
    if (_startLocation.isEmpty) {
      await GeocodingPlatform.instance
          .placemarkFromCoordinates(_userActivity.coordinates!.first!.latitude, _userActivity.coordinates!.first!.longitude,
              localeIdentifier: 'en_PH')
          .then((startPoint) {
        _startLocation =
            '${startPoint[0].street}, ${startPoint[1].street}. ${startPoint[0].locality}, ${startPoint[0].subAdministrativeArea}, ${startPoint[0].administrativeArea}.';
      }).catchError((e) {});
    }
    if (_endLocation.isEmpty) {
      await GeocodingPlatform.instance
          .placemarkFromCoordinates(_userActivity.coordinates!.last!.latitude, _userActivity.coordinates!.last!.longitude, localeIdentifier: 'en_PH')
          .then((endPoint) {
        _endLocation =
            '${endPoint[0].street}, ${endPoint[1].street}, ${endPoint[0].locality}, ${endPoint[0].subAdministrativeArea}, ${endPoint[0].administrativeArea}.';
      }).catchError((e) {});
    }
  }
}
