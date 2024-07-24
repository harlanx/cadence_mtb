part of '../../pages/navigate.dart';

//==================SESSION RESULT DIALOG V2====================//
//Show Result Dialog of the Session When the User Stops the Session Activity.
//V1 WAS KINDA BAD
class NewRideSessionViewer extends StatefulWidget {
  final BikeActivity result;
  NewRideSessionViewer({Key? key, required this.result}) : super(key: key);

  @override
  _NewRideSessionViewerState createState() => _NewRideSessionViewerState();
}

class _NewRideSessionViewerState extends State<NewRideSessionViewer> {
  late BikeActivity _userActivity;
  final Completer<GoogleMapController> _sessionMapCompleter = Completer();
  Uint8List? _mapScreenshotBytes;
  bool _showMapScreenshot = false,
      _sessionSaved = false,
      _takenScreenhot = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  late Future<List<BitmapDescriptor>> _futureMarkerIcons;
  String _startLocation = '', _endLocation = '', _imagePath = '';
  MapType _resultMapType = MapType.normal;
  Set<Marker> _sessionMarkers = {};

  @override
  void initState() {
    super.initState();
    _userActivity = widget.result;
    _futureMarkerIcons = _initializeIcons();
    _sessionLocations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
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
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 5.0, 10.0, 5.0),
                                    child: SvgPicture.asset(
                                        'assets/images/navigate/app_logo.svg',
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.contain),
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
                                          mapType: _resultMapType,
                                          markers: _sessionMarkers,
                                          polylines: _userActivity.polylines!,
                                          initialCameraPosition: CameraPosition(
                                            //Default Camera Target (It is a required parameter so we just used middle of the coordinates)
                                            target: _userActivity.coordinates![
                                                _userActivity
                                                        .coordinates!.length ~/
                                                    2],
                                            zoom: 18,
                                          ),
                                          onMapCreated: (controller) {
                                            if (mounted) {
                                              _sessionMapCompleter
                                                  .complete(controller);
                                              Future.delayed(
                                                  Duration(milliseconds: 300),
                                                  () {
                                                controller.moveCamera(
                                                    CameraUpdate
                                                        .newLatLngBounds(
                                                            _userActivity
                                                                .latLngBounds!,
                                                            10.0));
                                                setState(() {
                                                  _setSessionMarkers(
                                                      snapshot.data![0],
                                                      snapshot.data![1]);
                                                });
                                              });
                                            }
                                          },
                                        );

                                      default:
                                        return SizedBox.expand();
                                    }
                                  }),
                              Visibility(
                                visible: !_showMapScreenshot,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(0, 5.0, 5.0, 0),
                                    child: Material(
                                      color: Colors.white.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(2),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          if (_resultMapType ==
                                              MapType.normal) {
                                            _resultMapType = MapType.hybrid;
                                          } else if (_resultMapType ==
                                              MapType.hybrid) {
                                            _resultMapType = MapType.satellite;
                                          } else if (_resultMapType ==
                                              MapType.satellite) {
                                            _resultMapType = MapType.terrain;
                                          } else {
                                            _resultMapType = MapType.normal;
                                          }
                                          setState(() {});
                                        },
                                        child: Ink(
                                          height: 38,
                                          width: 38,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              //Left
                                              CustomBoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.8),
                                                offset: Offset(-0.5, 0),
                                                blurRadius: 10.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                              //Right
                                              CustomBoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.8),
                                                offset: Offset(0.5, 0),
                                                blurRadius: 10.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                              //Bottom
                                              CustomBoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.8),
                                                offset: Offset(0, -0.8),
                                                blurRadius: 10.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.map_rounded,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            child: Container(
                              color: Color(0xFF496D47),
                              width: double.maxFinite,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 46,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 3, 5, 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 50,
                                            child: AutoSizeText.rich(
                                              TextSpan(
                                                text: 'Duration: ',
                                                children: [
                                                  TextSpan(
                                                    text: StopWatchTimer
                                                            .getDisplayTime(
                                                          _userActivity
                                                              .duration!,
                                                          hours: true,
                                                          hoursRightBreak: 'h',
                                                          minute: true,
                                                          minuteRightBreak: 'm',
                                                          second: true,
                                                          milliSecond: false,
                                                        ) +
                                                        's',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                                    text:
                                                        '${_userActivity.distance} km',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 50,
                                            child: AutoSizeText.rich(
                                              TextSpan(
                                                text: 'Max Elevation: ',
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${_userActivity.elevation} m',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                                    text:
                                                        '${_userActivity.averageSpeed} m/s',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
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
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 3, 5, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 50,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                            fontWeight:
                                                                FontWeight.w300,
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
                                                    text:
                                                        '${_userActivity.burnedCalories}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
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
                        child: Text(
                          'Save',
                        ),
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          backgroundColor:
                              WidgetStateProperty.all(Color(0xFF496D47)),
                          overlayColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.pressed)
                                  ? Color(0xFF496D47).darken(0.1)
                                  : Colors.transparent),
                        ),
                        onPressed: () async {
                          if (_sessionSaved) {
                            CustomToast.showToastSimple(
                              context: context,
                              simpleMessage: 'Already Saved',
                              duration: Duration(seconds: 1),
                            );
                          } else {
                            _sessionSaved = true;
                            await Hive.box<BikeActivity>(
                                    '${currentUser!.profileNumber}bikeActivities')
                                .add(
                              BikeActivity(
                                startLocation: _startLocation,
                                endLocation: _endLocation,
                                activityDate: _userActivity.activityDate,
                                averageSpeed: _userActivity.averageSpeed,
                                burnedCalories: _userActivity.burnedCalories,
                                distance: _userActivity.distance,
                                elevation: _userActivity.elevation,
                                duration: _userActivity.duration,
                                weatherData: _userActivity.weatherData,
                                //Related to question https://github.com/hivedb/hive/issues/182
                                coordinates:
                                    _userActivity.coordinates!.toList(),
                                latLngBounds: _userActivity.latLngBounds,
                              ),
                            );
                            CustomToast.showToastSimple(
                              context: context,
                              simpleMessage: 'Saved',
                              duration: Duration(seconds: 2),
                            );
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text('Close'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          if (_sessionSaved) {
                            Navigator.pop(context, {
                              'takenScreenshot': _takenScreenhot,
                              'imagePath': _imagePath
                            });
                          } else {
                            showModal<bool>(
                              context: context,
                              configuration: FadeScaleTransitionConfiguration(
                                barrierDismissible: false,
                              ),
                              builder: (_) => AlertDialog(
                                contentPadding: EdgeInsets.all(10),
                                content: Text(
                                  'Result is not saved yet, do you really want to close?',
                                  style: TextStyle(
                                    color: Color(0xFF496D47),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Yes'),
                                    style: ButtonStyle(
                                      foregroundColor:
                                          WidgetStateProperty.all(Colors.white),
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.red.shade300),
                                      overlayColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) => states.contains(
                                                      WidgetState.pressed)
                                                  ? Colors.red.withOpacity(0.8)
                                                  : Colors.transparent),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('No'),
                                    style: ButtonStyle(
                                      foregroundColor: WidgetStateProperty.all(
                                          Color(0xFF496D47)),
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.grey.shade300),
                                      overlayColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) => states.contains(
                                                      WidgetState.pressed)
                                                  ? Color(0xFF496D47)
                                                      .withOpacity(0.8)
                                                  : Colors.transparent),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                  ),
                                ],
                              ),
                            ).then((wantToClose) {
                              if (wantToClose!) {
                                Navigator.pop(context, {
                                  'takenScreenshot': _takenScreenhot,
                                  'imagePath': _imagePath
                                });
                              }
                            });
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text('Share'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.shade400,
                        ),
                        onPressed: () async {
                          _takenScreenhot = true;
                          GoogleMapController _mapController =
                              await _sessionMapCompleter.future;
                          await _mapController
                              .takeSnapshot()
                              .then((value) async {
                            setState(() {
                              _mapScreenshotBytes = value;
                              _showMapScreenshot = true;
                            });
                            Directory _tempDir = await getTemporaryDirectory();
                            String fileName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            await _screenshotController
                                .captureAndSave(_tempDir.path,
                                    fileName: fileName,
                                    delay: Duration(seconds: 1),
                                    pixelRatio: 2.0)
                                .then((image) async {
                              _imagePath = image!;
                              final imageFile = XFile(_imagePath);
                              Share.shareXFiles([imageFile],
                                  subject: 'Session Result',
                                  text: 'Check out my ride session result!');
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
      ),
    );
  }

  void _setSessionMarkers(
      BitmapDescriptor startIcon, BitmapDescriptor endIcon) {
    //Add the session markers after session end
    setState(() {
      _sessionMarkers.add(
        Marker(
          markerId: MarkerId('startMarker'),
          zIndex: 3,
          flat: true,
          draggable: false,
          anchor: Offset(0.5, 0.5),
          position: _userActivity.coordinates!.first,
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
          position: _userActivity.coordinates!.last,
          icon: endIcon,
        ),
      );
    });
  }

  Future<List<BitmapDescriptor>> _initializeIcons() async {
    //Loads the icons to be used as markers later
    final _startIconMarker = BitmapDescriptor.bytes(
        await FunctionHelper.getBytesFromAsset(
            'assets/images/navigate/starting_point_icon_v4.png', 50));
    final _endIconMarker = BitmapDescriptor.bytes(
        await FunctionHelper.getBytesFromAsset(
            'assets/images/navigate/end_point_icon_v4.png', 50));
    return [_startIconMarker, _endIconMarker];
  }

  void _sessionLocations() async {
    final geoInstance = GeocodingPlatform.instance
      ?..setLocaleIdentifier('en_PH');
    await geoInstance
        ?.placemarkFromCoordinates(_userActivity.coordinates!.first.latitude,
            _userActivity.coordinates!.first.longitude)
        .then((startPoint) {
      setState(() {
        _startLocation =
            '${startPoint[0].street}, ${startPoint[1].street}. ${startPoint[0].locality}, ${startPoint[0].subAdministrativeArea}, ${startPoint[0].administrativeArea}.';
      });
    }).catchError((e) {
      setState(() {
        _startLocation = '';
      });
    });

    await geoInstance
        ?.placemarkFromCoordinates(_userActivity.coordinates!.last.latitude,
            _userActivity.coordinates!.last.longitude)
        .then((endPoint) {
      setState(() {
        _endLocation =
            '${endPoint[0].street}, ${endPoint[1].street}, ${endPoint[0].locality}, ${endPoint[0].subAdministrativeArea}, ${endPoint[0].administrativeArea}.';
      });
    }).catchError((e) {
      setState(() {
        _endLocation = '';
      });
    });
  }
}
