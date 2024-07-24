part of '../../screens/home_screen.dart';

class UserActivityPanel extends StatefulWidget {
  const UserActivityPanel({
    Key? key,
    required this.slidePanelController,
    required this.scrollController,
  }) : super(key: key);

  final PanelController slidePanelController;
  final ScrollController scrollController;

  @override
  _UserActivityPanelState createState() => _UserActivityPanelState();
}

class _UserActivityPanelState extends State<UserActivityPanel> {
  Box<BikeActivity> _topActivitiesBox =
      Hive.box<BikeActivity>('${currentUser!.profileNumber}bikeActivities');
  double _tableWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    //Using slidePanelController.isPanelOpen doesn't equal to true when opened because
    //the panel animation is stuck in 0.999... and the getter must be equal to 1
    //so I have to check myself when it is rounded to an integer.
    bool isPanelOpen = widget.slidePanelController.panelPosition.round() == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          fit: StackFit.passthrough,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (widget.slidePanelController.isAttached) {
                  if (isPanelOpen) {
                    widget.slidePanelController.close();
                  } else {
                    widget.slidePanelController.open();
                  }
                }
              },
              child: LayoutBuilder(
                builder: (_, constraints) {
                  _tableWidth = constraints.maxWidth;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: Icon(
                            isPanelOpen
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.drag_handle_rounded,
                            color: Color(0xFF496D47),
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Expanded(
                              flex: (_tableWidth * 0.6).ceil() + 10,
                              child: Text(
                                'Location',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF496D47),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: (_tableWidth * 0.2).floor() + 1,
                              child: Text(
                                'Duration',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF496D47),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: (_tableWidth * 0.2).floor() + 1,
                              child: Text(
                                'Calories\nBurned',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF496D47),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment(0.95, -1),
                child: OpenContainer(
                  closedElevation: 0,
                  openElevation: 0,
                  closedColor: Colors.transparent,
                  openColor: Colors.transparent,
                  closedShape: CircleBorder(),
                  closedBuilder: (_, action) {
                    return IconButton(
                      splashRadius: 15,
                      tooltip: 'User Activity History',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(maxHeight: 24, maxWidth: 24),
                      color: Colors.grey,
                      icon: Icon(
                        Icons.history_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        action();
                      },
                    );
                  },
                  openBuilder: (_, __) {
                    return UserActivityHistory();
                  },
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _tableWidth = constraints.maxWidth;
              return SingleChildScrollView(
                physics: isPanelOpen
                    ? AlwaysScrollableScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 30),
                controller: widget.scrollController,
                scrollDirection: Axis.vertical,
                child: ValueListenableBuilder(
                  valueListenable: _topActivitiesBox.listenable(),
                  builder: (_, Box box, __) {
                    if (box.values.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            r'No Ride Session Recorded ¯\_(ツ)_/¯',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          OutlinedButton(
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
                              foregroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (_) => Color(0xFF3D5164),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (_) => Colors.white,
                              ),
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (_) => Color(0xFF3D5164).withOpacity(0.8),
                              ),
                              side: WidgetStateProperty.resolveWith<BorderSide>(
                                (_) => BorderSide(
                                    color: Color(0xFF3D5164), width: 1.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CustomRoutes.fadeThrough(
                                      page: Navigate(),
                                      duration: Duration(milliseconds: 300)));
                            },
                          )
                        ],
                      );
                    } else {
                      List<BikeActivity> _topActivitiesData =
                          _topActivitiesBox.values.toList();
                      //Sorts the highest burned calories from top to lowest in bottom.
                      _topActivitiesData.sort((a, b) =>
                          b.burnedCalories!.compareTo(a.burnedCalories!));
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerTheme: DividerThemeData(
                              color: Colors.grey.shade400, indent: 0),
                        ),
                        child: DataTable(
                          headingTextStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF496D47),
                          ),
                          dataTextStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                          showBottomBorder: false,
                          headingRowHeight: 0, //0 to hide
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 0,
                          horizontalMargin: 5,
                          dividerThickness: 0.8,
                          columns: [
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                  color: Colors.red,
                                  child: Text(
                                    'Location',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                  color: Colors.green,
                                  child: Text(
                                    'Duration',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                  color: Colors.blue,
                                  child: Text(
                                    'Calories\nBurned',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: _topActivitiesData
                              .take(10)
                              .map(
                                (activity) => DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        width: (_tableWidth * 0.6) - 10,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            activity.startLocation!,
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        width: (_tableWidth * 0.2) - 10,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${StopWatchTimer.getDisplayTimeMinute(activity.duration!, hours: false)}m',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        width: (_tableWidth * 0.2) - 10,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            activity.burnedCalories!
                                                .toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
