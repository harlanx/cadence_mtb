part of '../../pages/bike_activity_history.dart';

class RideSessionViewer extends StatefulWidget {
  final BikeActivity activity;
  RideSessionViewer({Key? key, required this.activity}) : super(key: key);

  @override
  _RideSessionViewerState createState() => _RideSessionViewerState();
}

class _RideSessionViewerState extends State<RideSessionViewer> {
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
    var _size = MediaQuery.of(context).size;
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, {
                'takenScreenshot': _takenScreensot,
                'directory': _imagePath
              });
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: SvgPicture.asset('assets/images/navigate/app_logo.svg',
                    height: 24, width: 24, fit: BoxFit.contain),
              ),
              Text(
                'Cadence MTB',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'LexendGiga',
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                _takenScreensot = true;
                GoogleMapController _mapController =
                    await _sessionMapCompleter.future;
                _mapController.takeSnapshot().then((value) async {
                  setState(() {
                    _mapScreenshotBytes = value;
                    _showMapScreenshot = true;
                  });
                  Directory _tempDir = await getTemporaryDirectory();
                  String fileName =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  await _screenshotController
                      .captureAndSave(_tempDir.path,
                          fileName: fileName,
                          delay: Duration(seconds: 1),
                          pixelRatio: 2.0)
                      .then((image) async {
                    _imagePath = image!;
                    final imageFile = XFile(_imagePath);
                    Share.shareXFiles(
                      [imageFile],
                      subject: 'Session Result',
                      text: 'Check out my ride session result!',
                    );
                    setState(() {
                      _showMapScreenshot = false;
                    });
                  });
                });
              },
            ),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: CircleAvatar(
                child: FlutterLogo(),
              ),
              title: Text(currentUser!.profileName),
              subtitle: Text(DateFormat('MMMM dd, yyyy H:m a')
                  .format(_userActivity.activityDate!)),
            ),
            Container(
              height: _size.height * 0.35,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.7,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
              ),
              child: Stack(
                children: [
                  FutureBuilder<List<BitmapDescriptor>>(
                    future: _futureMarkerIcons,
                    builder: (_, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          return GoogleMap(
                            liteModeEnabled: true,
                            mapType: MapType.hybrid,
                            compassEnabled: false,
                            buildingsEnabled: false,
                            mapToolbarEnabled: false,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            markers: _sessionMarkers,
                            polylines: _sessionLines,
                            initialCameraPosition: CameraPosition(
                              //DEFAULT CAMERA POSITION (IT IS A REQUIRED PARAMETER SO WE JUST USED MIDDLE OF COORDINATES)
                              target: _userActivity.coordinates![0],
                              zoom: 18,
                            ),
                            onMapCreated: (controller) {
                              //When the map is created(mounted) we have to quickly update map to focus on the LatLng Bounds.
                              if (mounted) {
                                _sessionMapCompleter.complete(controller);
                                Future.delayed(Duration(milliseconds: 300), () {
                                  controller.moveCamera(
                                      CameraUpdate.newLatLngBounds(
                                          _userActivity.latLngBounds!, 8.0));
                                  setState(() {
                                    _setMarkersAndPolyline(
                                        snapshot.data![0], snapshot.data![1]);
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
            DefaultTextStyle(
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'Start:\n',
                              children: [
                                TextSpan(
                                  text: _startLocation,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'End:\n',
                              children: [
                                TextSpan(
                                  text: _endLocation,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      height: 20,
                      thickness: 0.7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'Duration:\n',
                              children: [
                                TextSpan(
                                  text:
                                      _sessionDuration(_userActivity.duration!),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'Distance:\n',
                              children: [
                                TextSpan(
                                  text: '${_userActivity.distance} km',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      height: 20,
                      thickness: 0.7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'Max Elevation:\n',
                              children: [
                                TextSpan(
                                  text: '${_userActivity.elevation} m',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'Avg. Speed:\n',
                              children: [
                                TextSpan(
                                  text: '${_userActivity.averageSpeed} m/s',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      height: 20,
                      thickness: 0.7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Weather:\n',
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
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 50,
                          child: Text.rich(
                            TextSpan(
                              text: 'Calories Burned:\n',
                              children: [
                                TextSpan(
                                  text: '${_userActivity.burnedCalories} kCal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Screenshot(
            //   controller: _screenshotController,
            //   child:
            // ),
          ],
        ),
      ),
    );
  }

  String _sessionDuration(int duration) {
    String _hours = StopWatchTimer.getDisplayTimeHours(duration);
    String _minutes =
        StopWatchTimer.getDisplayTimeMinute(duration, hours: true);
    String _seconds = StopWatchTimer.getDisplayTimeSecond(duration);
    print(_minutes);
    if (_hours == '00') {
      _hours = '';
    } else {
      _hours = _hours.replaceAll(new RegExp(r'^0+(?=.)'), '') + 'h ';
    }
    if (_minutes == '00') {
      _minutes = '';
    } else {
      _minutes = _minutes.replaceAll(new RegExp(r'^0+(?=.)'), '') + 'm ';
    }
    if (_seconds == '00') {
      _seconds = '';
    } else {
      _seconds = _seconds.replaceAll(new RegExp(r'^0+(?=.)'), '') + 's';
    }

    return '$_hours$_minutes$_seconds';
  }

  void _setMarkersAndPolyline(
      BitmapDescriptor startIcon, BitmapDescriptor endIcon) {
    //Add the session markers after session end
    int _borderWidth =
        StorageHelper.getInt('${currentUser!.profileNumber}borderWidth') ?? 6;
    int _lineWidth =
        StorageHelper.getInt('${currentUser!.profileNumber}lineWidth') ?? 4;

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
        points: _userActivity.coordinates!,
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
    if (_startLocation.isEmpty) {
      geoInstance
          ?.placemarkFromCoordinates(_userActivity.coordinates!.first.latitude,
              _userActivity.coordinates!.first.longitude)
          .then((startPoint) {
        _startLocation =
            '${startPoint[0].street}, ${startPoint[1].street}. ${startPoint[0].locality}, ${startPoint[0].subAdministrativeArea}, ${startPoint[0].administrativeArea}.';
      }).catchError((e) {});
    }
    if (_endLocation.isEmpty) {
      await geoInstance
          ?.placemarkFromCoordinates(_userActivity.coordinates!.last.latitude,
              _userActivity.coordinates!.last.longitude)
          .then((endPoint) {
        _endLocation =
            '${endPoint[0].street}, ${endPoint[1].street}, ${endPoint[0].locality}, ${endPoint[0].subAdministrativeArea}, ${endPoint[0].administrativeArea}.';
      }).catchError((e) {});
    }
  }
}
