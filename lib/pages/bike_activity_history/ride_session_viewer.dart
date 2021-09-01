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
