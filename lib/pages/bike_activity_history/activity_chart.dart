part of '../../pages/bike_activity_history.dart';

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
                    tooltipBgColor: Colors.white,
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
                  getTextStyles: (_, value) {
                    return TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400);
                  },
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
                  getTextStyles: (_, value) => TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400),
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
