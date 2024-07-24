import 'dart:math';
import 'package:animations/animations.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
part 'bmi_history/bmi_calculator.dart';

class BMIHistory extends StatefulWidget {
  @override
  _BMIHistoryState createState() => _BMIHistoryState();
}

class _BMIHistoryState extends State<BMIHistory> {
  final Box<BMIData> _bmiActivitiesBox =
      Hive.box<BMIData>('${currentUser!.profileNumber}bmiActivities');
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.0);
  List<BMIData> _bmiActivities = [];
  List<BMIData> _selected = [];
  bool _enableJumpBtn = false;
  bool _isAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(() {
        _scrollController.position.isScrollingNotifier
            .addListener(_showJumpToTopButton);
      });
    });
  }

  @override
  void dispose() {
    _bmiActivitiesBox.close();
    if (_scrollController.hasClients) {}
    _scrollController.dispose();
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
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Color(0xFFF15024),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline_rounded),
                color: Colors.grey,
                onPressed: () => showModal(
                    context: context,
                    configuration: FadeScaleTransitionConfiguration(
                        barrierDismissible: true),
                    builder: (_) {
                      return AlertDialog(
                        title: Text('Body Mass Index',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20)),
                        titlePadding: EdgeInsets.all(10),
                        contentPadding: EdgeInsets.all(10),
                        content: Text(
                          'Calculated from your height and weight. BMI is an estimate of body fat and a good gauge of your risk for diseases that can occur with more body fat.\n\nThe higher your BMI, the higher your risk for certain diseases such as heart disease, high blood pressure, type 2 diabetes, gallstones, breathing problems, and certain cancers.',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 15),
                        ),
                        buttonPadding: EdgeInsets.zero,
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(CircleBorder()),
                              textStyle: WidgetStateProperty.all(
                                  TextStyle(fontWeight: FontWeight.w700)),
                              foregroundColor:
                                  WidgetStateProperty.all(Color(0xFFF15024)),
                              overlayColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.pressed)
                                    ? Color(0xFFF15024)
                                        .darken(0.1)
                                        .withOpacity(0.5)
                                    : Colors.transparent,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  BMICalculator(
                    onSavePressed: (result) {
                      _bmiActivitiesBox.add(
                        BMIData(
                          date: DateTime.now(),
                          weightInKg: double.parse(result['weight']),
                          heightInCm: double.parse(result['height']),
                          bmi: double.parse(result['bmi']),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: ValueListenableBuilder<Box<BMIData>>(
                        valueListenable: _bmiActivitiesBox.listenable(),
                        builder: (_, box, __) {
                          if (box.values.isEmpty) {
                            return Center(
                              child: Text(
                                r'No BMI Recorded ¯\_(ツ)_/¯',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          } else {
                            if (_bmiActivities.length != box.values.length) {
                              _bmiActivities = box.values.toList();
                              onSortColumn(_sortColumnIndex, _isAscending);
                            }
                            return SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme:
                                      Theme.of(context).colorScheme.copyWith(
                                            primary: Color(0xFFF15024),
                                            onPrimary: Colors.white,
                                          ),
                                ),
                                child: DataTable(
                                  headingTextStyle: TextStyle(
                                      color: Color(0xFFF15024),
                                      fontWeight: FontWeight.w700),
                                  dataTextStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                  dataRowColor: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                              ? Color(0xFFF15024).brighten(0.3)
                                              : Colors.transparent),
                                  sortAscending: _isAscending,
                                  sortColumnIndex: _sortColumnIndex,
                                  columnSpacing: 10,
                                  showCheckboxColumn: true,
                                  columns: [
                                    DataColumn(
                                      label: Text('Date'),
                                      tooltip: 'Date Recorded.',
                                      onSort: (columnIndex, ascending) {
                                        onSortColumn(columnIndex, ascending);
                                        setState(() {
                                          _isAscending = ascending;
                                          _sortColumnIndex = columnIndex;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('Weight'),
                                      tooltip: 'Weight in kg.',
                                      onSort: (columnIndex, ascending) {
                                        onSortColumn(columnIndex, ascending);
                                        setState(() {
                                          _isAscending = ascending;
                                          _sortColumnIndex = columnIndex;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('Height'),
                                      tooltip: 'Height in cm.',
                                      onSort: (columnIndex, ascending) {
                                        onSortColumn(columnIndex, ascending);
                                        setState(() {
                                          _isAscending = ascending;
                                          _sortColumnIndex = columnIndex;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('BMI'),
                                      tooltip: 'BMI Result.',
                                      onSort: (columnIndex, ascending) {
                                        onSortColumn(columnIndex, ascending);
                                        setState(() {
                                          _isAscending = ascending;
                                          _sortColumnIndex = columnIndex;
                                        });
                                      },
                                    ),
                                  ],
                                  rows: _bmiActivities
                                      .map(
                                        (activity) => DataRow(
                                          selected:
                                              _selected.contains(activity),
                                          onSelectChanged: (val) {
                                            onSelectedRow(val!, activity);
                                          },
                                          cells: [
                                            DataCell(
                                              Text(
                                                DateFormat('MM-dd-y hh:mm a')
                                                    .format(activity.date),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${activity.weightInKg}',
                                                maxLines: 3,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${activity.heightInCm}',
                                                maxLines: 3,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${activity.bmi}',
                                                maxLines: 3,
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
                        }),
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
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (states) => states.contains(WidgetState.disabled)
                                  ? Colors.grey.shade400
                                  : Colors.white,
                            ),
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (states) => states.contains(WidgetState.disabled)
                                  ? Colors.white
                                  : Color(0xFFF15024).brighten(0.05),
                            ),
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (states) => states.contains(WidgetState.pressed)
                                  ? Color(0xFFF15024).darken(0.05)
                                  : Colors.transparent,
                            ),
                            side: WidgetStateProperty.resolveWith<BorderSide>(
                              (states) => states.contains(WidgetState.disabled)
                                  ? BorderSide(
                                      color: Colors.grey.shade400, width: 1.0)
                                  : BorderSide.none,
                            ),
                          ),
                          onPressed: _selected.isEmpty
                              ? null
                              : () {
                                  List<DateTime> selectedDates =
                                      _selected.map((e) => e.date).toList();
                                  List<dynamic> keys = _bmiActivitiesBox
                                      .toMap()
                                      .entries
                                      .where((element) => selectedDates
                                          .contains(element.value.date))
                                      .map((e) => e.key)
                                      .toList();
                                  _deleteSelected(keys);
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: AppBar().preferredSize.height + 200,
                right: 10,
                child: Visibility(
                  visible: _enableJumpBtn,
                  child: ClipOval(
                    child: Material(
                      child: Ink(
                        height: 40,
                        width: 40,
                        color: Color(0xFFF15024).brighten(0.1),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_upward_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _scrollController.animateTo(0.0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
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

  //Update layout when row is selected
  void onSelectedRow(bool selected, BMIData activity) {
    setState(() {
      if (selected) {
        _selected.add(activity);
      } else {
        _selected.remove(activity);
      }
    });
  }

  //Delete Selected BMI Activities
  void _deleteSelected(List<dynamic> keys) {
    if (keys.isNotEmpty) {
      _bmiActivitiesBox.deleteAll(keys);
    }
    setState(() {
      _enableJumpBtn = false;
      _selected.clear();
    });
  }

  ///Sorting the datatable.
  void onSortColumn(int columnIndex, bool ascending) {
    //Date
    if (columnIndex == 0) {
      if (ascending) {
        //Sorts to latest on top
        _bmiActivities.sort((a, b) => b.date.compareTo(a.date));
      } else {
        //Sorts to latest on bottom
        _bmiActivities.sort((a, b) => b.date.compareTo(a.date));
      }
      //Weight
    } else if (columnIndex == 1) {
      if (ascending) {
        _bmiActivities.sort((a, b) => a.weightInKg.compareTo(b.weightInKg));
      } else {
        _bmiActivities.sort((a, b) => b.weightInKg.compareTo(a.weightInKg));
      }
      //Height
    } else if (columnIndex == 2) {
      if (ascending) {
        _bmiActivities.sort((a, b) => a.heightInCm.compareTo(b.heightInCm));
      } else {
        _bmiActivities.sort((a, b) => b.heightInCm.compareTo(a.heightInCm));
      }
      //BMI
    } else if (columnIndex == 3) {
      if (ascending) {
        _bmiActivities.sort((a, b) => a.bmi.compareTo(b.bmi));
      } else {
        _bmiActivities.sort((a, b) => b.bmi.compareTo(a.bmi));
      }
    }
  }
}
