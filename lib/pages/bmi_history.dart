import 'dart:math';
import 'package:animations/animations.dart';
import 'package:cadence_mtb/models/bmi_data.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';

class BMIHistory extends StatefulWidget {
  @override
  _BMIHistoryState createState() => _BMIHistoryState();
}

class _BMIHistoryState extends State<BMIHistory> {
  final Box<BMIData> _bmiActivitiesBox = Hive.box<BMIData>('${currentUser!.profileNumber}bmiActivities');
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  List<BMIData> _bmiActivities = [];
  List<BMIData> _selected = [];
  bool _enableJumpBtn = false;
  bool _isAscending = true;
  int _sortColumnIndex = 0;

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
    _bmiActivitiesBox.close();
    if (_scrollController.hasClients) {}
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFFF15024), statusBarIconBrightness: Brightness.light),
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
                    configuration: FadeScaleTransitionConfiguration(barrierDismissible: true),
                    builder: (_) {
                      return AlertDialog(
                        title: Text('Body Mass Index', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                        titlePadding: EdgeInsets.all(10),
                        contentPadding: EdgeInsets.all(10),
                        content: Text(
                          'Calculated from your height and weight. BMI is an estimate of body fat and a good gauge of your risk for diseases that can occur with more body fat.\n\nThe higher your BMI, the higher your risk for certain diseases such as heart disease, high blood pressure, type 2 diabetes, gallstones, breathing problems, and certain cancers.',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                        buttonPadding: EdgeInsets.zero,
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(CircleBorder()),
                              textStyle: MaterialStateProperty.all(TextStyle(fontWeight: FontWeight.w700)),
                              foregroundColor: MaterialStateProperty.all(Color(0xFFF15024)),
                              overlayColor: MaterialStateProperty.resolveWith(
                                (states) =>
                                    states.contains(MaterialState.pressed) ? Color(0xFFF15024).darken(0.1).withOpacity(0.5) : Colors.transparent,
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
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: Color(0xFFF15024),
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: DataTable(
                                  headingTextStyle: TextStyle(color: Color(0xFFF15024), fontWeight: FontWeight.w700),
                                  dataTextStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),

                                  dataRowColor: MaterialStateProperty.resolveWith(
                                      (states) => states.contains(MaterialState.selected) ? Color(0xFFF15024).brighten(0.3) : Colors.transparent),
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
                                          selected: _selected.contains(activity),
                                          onSelectChanged: (val) {
                                            onSelectedRow(val!, activity);
                                          },
                                          cells: [
                                            DataCell(
                                              Text(
                                                DateFormat('MM-dd-y hh:mm a').format(activity.date),
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
                            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.disabled) ? Colors.grey.shade400 : Colors.white,
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.disabled) ? Colors.white : Color(0xFFF15024).brighten(0.05),
                            ),
                            overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.pressed) ? Color(0xFFF15024).darken(0.05) : Colors.transparent,
                            ),
                            side: MaterialStateProperty.resolveWith<BorderSide>(
                              (states) =>
                                  states.contains(MaterialState.disabled) ? BorderSide(color: Colors.grey.shade400, width: 1.0) : BorderSide.none,
                            ),
                          ),
                          onPressed: _selected.isEmpty
                              ? null
                              : () {
                                  List<DateTime> selectedDates = _selected.map((e) => e.date).toList();
                                  List<dynamic> keys = _bmiActivitiesBox
                                      .toMap()
                                      .entries
                                      .where((element) => selectedDates.contains(element.value.date))
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

typedef void BMICalculatorCallback(Map<String, dynamic> result);

class BMICalculator extends StatefulWidget {
  final double userWeight;
  final double userHeight;
  final BMICalculatorCallback onSavePressed;

  BMICalculator({
    Key? key,
    this.userHeight = 0.0,
    this.userWeight = 0.0,
    required this.onSavePressed,
  }) : super(key: key);
  @override
  BMICalculatorState createState() => BMICalculatorState();
}

class BMICalculatorState extends State<BMICalculator> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _massUnit = 'kg';
  String _heightUnit = 'cm';
  String _bmiResult = 'None';
  double _calculatedResult = 0.0;
  Color _bmiColor = Color(0xFF496D47);
  late Future<Artboard> _futureHolder;
  late Artboard _artboard;

  @override
  void didUpdateWidget(covariant BMICalculator oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _futureHolder = _loadAnimationFile();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: AppBar().preferredSize.height,
                ),
                Expanded(
                  child: FutureBuilder<Artboard>(
                    future: _futureHolder,
                    builder: (_, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          return Rive(
                            artboard: _artboard,
                            fit: BoxFit.contain,
                          );
                        default:
                          return SizedBox.shrink();
                      }
                    },
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: double.infinity,
                  color: _bmiColor,
                  margin: const EdgeInsets.only(bottom: 5.0),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text.rich(
                    TextSpan(
                      text: 'BMI: ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                          text: '${_calculatedResult.toStringAsFixed(2)}\n($_bmiResult)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppBar().preferredSize.height),
                Expanded(
                  flex: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 35,
                              child: Text(
                                'Weight: ',
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: TextField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2)),
                                  contentPadding: EdgeInsets.zero,
                                  errorStyle: TextStyle(height: 0),
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(6), FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                              ),
                            ),
                            Expanded(
                              flex: 35,
                              child: Listener(
                                onPointerDown: (_) => FocusScope.of(context).unfocus(),
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    underline: SizedBox.shrink(),
                                    elevation: 0,
                                    isDense: true,
                                    isExpanded: true,
                                    style: TextStyle(color: Theme.of(context).textTheme.subtitle1!.color, fontWeight: FontWeight.w400, fontSize: 14),
                                    value: _massUnit,
                                    items: [
                                      DropdownMenuItem(child: FittedBox(fit: BoxFit.scaleDown, child: Text('kg')), value: 'kg'),
                                      DropdownMenuItem(child: FittedBox(fit: BoxFit.scaleDown, child: Text('lb')), value: 'lb'),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _massUnit = val!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Expanded(
                              flex: 35,
                              child: Text(
                                'Height: ',
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: TextField(
                                controller: _heightController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2)),
                                  contentPadding: EdgeInsets.zero,
                                  errorStyle: TextStyle(height: 0),
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(6), FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]'))],
                              ),
                            ),
                            Expanded(
                              flex: 35,
                              child: Listener(
                                onPointerDown: (_) => FocusScope.of(context).unfocus(),
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    underline: SizedBox.shrink(),
                                    elevation: 0,
                                    isDense: true,
                                    isExpanded: true,
                                    style: TextStyle(color: Theme.of(context).textTheme.subtitle1!.color, fontWeight: FontWeight.w400, fontSize: 14),
                                    value: _heightUnit,
                                    items: [
                                      DropdownMenuItem(child: FittedBox(fit: BoxFit.scaleDown, child: Text('cm')), value: 'cm'),
                                      DropdownMenuItem(child: FittedBox(fit: BoxFit.scaleDown, child: Text('ft')), value: 'ft'),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _heightUnit = val!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        child: Text('Save'),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white;
                            } else if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            } else {
                              return Color(0xFFF15024);
                            }
                          }),
                          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return BorderSide(color: Colors.transparent);
                            } else if (states.contains(MaterialState.disabled)) {
                              return BorderSide(color: Colors.grey);
                            } else {
                              return BorderSide(color: Color(0xFFF15024));
                            }
                          }),
                          overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.pressed) ? Color(0xFFF15024).withOpacity(0.8) : Colors.transparent),
                        ),
                        onPressed: _calculatedResult == 0.0
                            ? null
                            : () {
                                double weight =
                                    _massUnit == 'lb' ? double.parse(_weightController.text) * 0.453592 : double.parse(_weightController.text);
                                double height =
                                    _heightUnit == 'ft' ? double.parse(_heightController.text) * 0.3048 : double.parse(_heightController.text);
                                widget.onSavePressed({
                                  'weight': weight.toStringAsFixed(2),
                                  'height': height.toStringAsFixed(2),
                                  'bmi': _calculatedResult.toStringAsFixed(2),
                                });
                              },
                      ),
                      OutlinedButton(
                        child: Text('Calculate'),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.pressed) ? Colors.white : Color(0xFFF15024)),
                          side: MaterialStateProperty.all(BorderSide(color: Colors.red)),
                          overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.pressed) ? Color(0xFFF15024).withOpacity(0.8) : Colors.transparent),
                        ),
                        onPressed: () {
                          _calculateBMI();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Artboard> _loadAnimationFile() async {
    //Load the animation file
    //Learn more about rive in pub.dev. Create your animations at rive.app
    //Here we just made basic shapes and strokes that we animated using keyframes.
    await RiveFile.asset('assets/animations/heart_emoticon.riv').then((file) {
      _artboard = file.artboardByName('Heart')!;
      _artboard.addController(SimpleAnimation('onEnter'));
    });
    return _artboard;
  }

  void _calculateBMI() {
    if (_weightController.text.isNotEmpty && _heightController.text.isNotEmpty) {
      if (double.tryParse(_weightController.text)!.round() != 0 && double.tryParse(_heightController.text)!.round() != 0) {
        double _weightInKg = _massUnit == 'lb' ? double.parse(_weightController.text) * 0.453592 : double.parse(_weightController.text);
        double _heightInM = _heightUnit == 'ft' ? double.parse(_heightController.text) * 0.3048 : double.parse(_heightController.text) / 100;
        _calculatedResult = _weightInKg / pow(_heightInM, 2);
        //Underweight
        if (_calculatedResult < 18.5) {
          if (_bmiResult == 'None') {
            _artboard.addController(SimpleAnimation('defaultToSad'));
          } else {
            if (_bmiResult == 'Normal') {
              _artboard.addController(SimpleAnimation('happyToSad'));
            }
          }
          _bmiColor = Colors.yellow.shade700;
          _bmiResult = 'Underweight';
          //Normal
        } else if (_calculatedResult >= 18.5 && _calculatedResult <= 24.9) {
          if (_bmiResult == 'None') {
            _artboard.addController(SimpleAnimation('defaultToHappy'));
          } else {
            if (_bmiResult == 'Underweight' || _bmiResult == 'Overweight' || _bmiResult == 'Obese') {
              _artboard.addController(SimpleAnimation('sadToHappy'));
            }
          }
          _bmiColor = Colors.green.shade700;
          _bmiResult = 'Normal';
          //Overweight
        } else if (_calculatedResult >= 25.0 && _calculatedResult <= 29.9) {
          if (_bmiResult == 'None') {
            _artboard.addController(SimpleAnimation('defaultToSad'));
          } else {
            if (_bmiResult == 'Normal') {
              _artboard.addController(SimpleAnimation('happyToSad'));
            }
          }
          _bmiColor = Colors.orange.shade700;
          _bmiResult = 'Overweight';
          //Obese
        } else {
          if (_bmiResult == 'None') {
            _artboard.addController(SimpleAnimation('defaultToSad'));
          } else {
            if (_bmiResult == 'Normal') {
              _artboard.addController(SimpleAnimation('happyToSad'));
            }
          }
          _bmiColor = Colors.red.shade700;
          _bmiResult = 'Obese';
        }
      }
    } else {
      if (_bmiResult == 'Normal') {
        _artboard.addController(SimpleAnimation('happyToDefault'));
      } else if (_bmiResult == 'None') {
        _artboard.addController(SimpleAnimation('default'));
      } else {
        _artboard.addController(SimpleAnimation('sadToDefault'));
      }
      _calculatedResult = 0.0;
      _bmiResult = 'None';
      _bmiColor = Color(0xFF496D47);
    }
    setState(() {});
  }
}
