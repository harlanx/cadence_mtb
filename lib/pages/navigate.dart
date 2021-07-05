import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/bike_activity.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/pages/app_settings.dart';
import 'package:cadence_mtb/pages/bike_activity_history.dart';
import 'package:cadence_mtb/pages/weather_forecast.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:weather/weather.dart';

class Navigate extends StatefulWidget {
  @override
  _NavigateState createState() => _NavigateState();
}

class _NavigateState extends State<Navigate> with TickerProviderStateMixin {
  //MAP RELATED VARIABLES AND OBJECTS
  final GlobalKey<RadialMenuState> _menuKey = GlobalKey<RadialMenuState>();
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _showBanner = true, _sessionStarted = false, _isMapMounted = false;
  double _activeDistance = 0.0, _currentSpeed = 0.0, _currentElevation = 0.0, _weightInKg = 57.7;
  int _rawTime = 0;
  String _elapsedTime = '00:00:00', _appBarTitle = 'Navigation';
  late DateTime _sessionDateTime;
  late Future<Position> _futurePosition;
  late LatLng _currentPos;
  List<double> _speed = [], _elevation = [];
  List<LatLng> _trackCoordinates = [];
  Set<Polyline> _sessionLines = {Polyline(polylineId: PolylineId('border')), Polyline(polylineId: PolylineId('line'))};
  MapType _mapType = MapType.normal;
  //Possible for offline mode? Not explored yet.
  // Set<TileOverlay> _offlineTiles = {};
  // TileProvider _tileProvider;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<int>? _stopWatchTimerStreamSubscription;
  //WEATHER RELATED VARIABLES AND OBJECTS
  Future<Weather>? _futureWeather;
  Weather? _sessionWeather;
  final WeatherFactory wf = WeatherFactory(Constants.openWeatherMapApiKey, language: Language.ENGLISH);

  @override
  void initState() {
    Wakelock.toggle(enable: true);
    super.initState();
    _showWeightTip();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    (_futurePosition = _currentPosition()).then((pos) {
      _currentPos = LatLng(pos.latitude, pos.longitude);
      //Save to JSON if you want offline access of last fetched data of the user's location.
      _futureWeather = _currentWeather(pos);
      _userLocationAddress(LatLng(pos.latitude, pos.longitude));
    }).catchError((e) {
      CustomToast.showToastSimple(
        context: context,
        simpleMessage: e,
        duration: Duration(seconds: 3),
      );
    });
    // Fairly new added feature of Google Maps package. This gives us room for improvement in the future to support offline maps.
    // Tile tile = Tile(1,2,);
    // _tileProvider.getTile(x, y, zoom)
    // _offlineTiles.add(TileOverlay(tileOverlayId: TileOverlayId('downloaded'), tileProvider: _tileProvider));
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _stopWatchTimer.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.dispose();
    Wakelock.toggle(enable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF3D5164), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Color(0xFF3D5164).withOpacity(0.8),
            elevation: 0,
            title: AutoSizeText(
              _appBarTitle,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
            actions: <Widget>[
              buildWeatherInfo(),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              _navigationMap(),
              Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: buildBottomInfoContainer())),
              RadialMenu(
                key: _menuKey,
                openIcon: _sessionStarted
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.stop_outlined,
                          color: Colors.white,
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/images/navigate/wheel.svg',
                        color: Colors.white,
                      ),
                closeIcon: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                tooltip: 'Navigation Menu',
                color: Color(0xFF3D5164),
                border: Border.all(color: Colors.white),
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: 20),
                radius: 70,
                startingAngleInRadian: 1.25 * pi,
                endingAngleInRadian: 1.75 * pi,
                forwardCurve: Curves.linearToEaseOut,
                reverseCurve: Curves.easeInToLinear,
                onPressed: () {
                  if (_sessionStarted) {
                    _menuKey.currentState!.enableOpen();
                    setState(() {
                      _sessionStarted = false;
                    });
                    _menuKey.currentState!.close();
                    _stopSession();
                  }
                },
                children: <RadialMenuItem>[
                  RadialMenuItem(
                    tooltip: 'History',
                    color: Color(0xFF3D5164),
                    border: Border.all(color: Colors.white),
                    child: Icon(Icons.history, color: Colors.white),
                    onTap: () {
                      if (_menuKey.currentState!.isOpen) {
                        _menuKey.currentState!.close();
                      }
                      Navigator.push(
                        context,
                        CustomRoutes.fadeThrough(
                          page: UserActivityHistory(),
                          duration: Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  RadialMenuItem(
                    tooltip: 'Start Navigation',
                    color: Color(0xFF3D5164),
                    border: Border.all(color: Colors.white),
                    onTap: () {
                      if (_menuKey.currentState!.isOpen) {
                        _menuKey.currentState!.close();
                      }
                      if (!_sessionStarted) {
                        _startSession();
                        _menuKey.currentState!.disableOpen();
                        setState(() {
                          _sessionStarted = true;
                        });
                      }
                    },
                    child: Icon(
                      Icons.navigation_outlined,
                      color: Colors.white,
                    ),
                  ),
                  RadialMenuItem(
                    tooltip: 'Settings',
                    color: Color(0xFF3D5164),
                    border: Border.all(color: Colors.white),
                    child: Icon(Icons.settings, color: Colors.white),
                    onTap: () {
                      showModal(
                        context: context,
                        configuration: FadeScaleTransitionConfiguration(
                          barrierDismissible: false,
                        ),
                        builder: (context) => WillPopScope(
                          onWillPop: () => Future.value(false),
                          child: NavigationSettings(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              //CUSTOM BUTTONS
              Visibility(
                visible: _isMapMounted,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 12, 12.0, 0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(2),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () async {
                              final GoogleMapController controller = await _mapControllerCompleter.future;
                              _currentPosition().then((position) {
                                setState(() {
                                  _currentElevation = position.altitude;
                                });
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      zoom: 18,
                                      target: LatLng(
                                        position.latitude,
                                        position.longitude,
                                      ),
                                    ),
                                  ),
                                );
                              }).catchError((e) {
                                CustomToast.showToastSimple(
                                  context: context,
                                  simpleMessage: e,
                                  duration: Duration(seconds: 3),
                                );
                              });
                            },
                            child: Ink(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  //Top
                                  CustomBoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
                                    offset: Offset(-0.08, 0),
                                    blurRadius: 10.0,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                  //Left
                                  CustomBoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
                                    offset: Offset(-0.5, 0),
                                    blurRadius: 10.0,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                  //Right
                                  CustomBoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
                                    offset: Offset(0.5, 0),
                                    blurRadius: 10.0,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.my_location,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(2),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              if (_mapType == MapType.normal) {
                                _mapType = MapType.hybrid;
                              } else if (_mapType == MapType.hybrid) {
                                _mapType = MapType.satellite;
                              } else if (_mapType == MapType.satellite) {
                                _mapType = MapType.terrain;
                              } else {
                                _mapType = MapType.normal;
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
                                    color: Colors.grey.withOpacity(0.8),
                                    offset: Offset(-0.5, 0),
                                    blurRadius: 10.0,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                  //Right
                                  CustomBoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
                                    offset: Offset(0.5, 0),
                                    blurRadius: 10.0,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                  //Bottom
                                  CustomBoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
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
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showBanner,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppBar().preferredSize.height,
                    ),
                    MaterialBanner(
                      padding: EdgeInsets.all(20),
                      content: Text(
                        'You can get a more accurate result of the calories you burn by providing your own weight in the settings.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      leading: Icon(
                        Icons.emoji_objects_rounded,
                        color: Colors.white,
                      ),
                      backgroundColor: Color(0xFF3D5164),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'SETTINGS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CustomRoutes.fadeThrough(
                                page: AppSettings(),
                                duration: Duration(milliseconds: 300),
                              ),
                            ).then((value) {
                              StorageHelper.setBool('showBanner', false);
                              setState(() {
                                _showBanner = false;
                              });
                            });
                          },
                        ),
                        TextButton(
                          child: Text(
                            'DISMISS',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            StorageHelper.setBool('showBanner', false);
                            setState(() {
                              _showBanner = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: !sosEnabled['Navigate']!
              ? null
              : DraggableFab(
                  child: Container(
                    height: 40,
                    width: 40,
                    child: EmergencyButton(),
                  ),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  void _showWeightTip() {
    _showBanner = StorageHelper.getBool('showBanner') ?? true;
  }

  //MAP RELATED FUNCTIONS
  Future<Position> _currentPosition() async {
    //Get Initial Position
    bool _serviceEnabled;
    LocationPermission _permission;

    _serviceEnabled = await GeolocatorPlatform.instance.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    _permission = await GeolocatorPlatform.instance.checkPermission();
    if (_permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permantly denied, we cannot request permissions.');
    }

    if (_permission == LocationPermission.denied) {
      _permission = await GeolocatorPlatform.instance.requestPermission();
      if (_permission != LocationPermission.whileInUse || _permission != LocationPermission.always) {
        return Future.error('Location permissions are denied (actual value: $_permission).');
      }
    }
    Position pos = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _currentSpeed = pos.speed;
    _currentElevation = pos.altitude;
    return pos;
  }

  void _userLocationAddress(LatLng coordinates) async {
    await GeocodingPlatform.instance
        .placemarkFromCoordinates(coordinates.latitude, coordinates.longitude, localeIdentifier: 'en_PH')
        .then((addresses) {
      setState(() {
        _appBarTitle = addresses[0].locality!;
      });
    }).catchError((e) {
      setState(() {
        _appBarTitle = 'Navigate';
      });
    });
  }

  /// Start Navigation Session
  void _startSession() async {
    //Initialization of user preference
    _weightInKg = StorageHelper.getDouble('${currentUser!.profileNumber}userWeight') ?? 57.7;
    String locationAccuracy = StorageHelper.getString('${currentUser!.profileNumber}locationAccuracy')?.toLowerCase() ?? 'high';
    LocationAccuracy userDesiredAccuracy = LocationAccuracy.values.singleWhere((element) => describeEnum(element) == locationAccuracy);
    int distanceFilter = StorageHelper.getInt('${currentUser!.profileNumber}distanceFilter') ?? 0;
    String formula = StorageHelper.getString('${currentUser!.profileNumber}formula') ?? 'Haversine';
    int lineWidth = StorageHelper.getInt('${currentUser!.profileNumber}lineWidth') ?? 4;
    int borderWidth = StorageHelper.getInt('${currentUser!.profileNumber}borderWidth') ?? 6;
    //Check if has internet first before showing polyline.
    //Otherwise show latlng data only (Not yet implemented)
    bool hasInternet = await InternetConnectionChecker().hasConnection;
    //This starts the stream of data and starts the timer
    _startSessionTimer();
    _positionStreamSubscription =
        GeolocatorPlatform.instance.getPositionStream(desiredAccuracy: userDesiredAccuracy, distanceFilter: distanceFilter).listen((position) async {
      final GoogleMapController controller = await _mapControllerCompleter.future;
      _speed.add(position.speed);
      _elevation.add(position.altitude);
      _trackCoordinates.add(LatLng(position.latitude, position.longitude));
      _sessionLines.clear();
      _currentSpeed = position.speed;
      _currentElevation = position.altitude;
      if (hasInternet) {
        _sessionLines.add(
          Polyline(
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true,
            jointType: JointType.round,
            color: Color(0xFF6A8B00),
            width: borderWidth,
            visible: true,
            zIndex: 0,
            polylineId: PolylineId('border'),
            points: _trackCoordinates,
          ),
        );
        _sessionLines.add(
          Polyline(
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true,
            jointType: JointType.round,
            color: Color(0xFF9CCC03),
            width: lineWidth,
            visible: true,
            zIndex: 1,
            polylineId: PolylineId('line'),
            points: _trackCoordinates,
          ),
        );
      }
      if (_trackCoordinates.length >= 2) {
        if (formula == 'Haversine') {
          //THIS ONE USES GEOLOCATOR'S HAVERSINE FORMULA TO CALCULATE  ACTIVE DISTANCE
          _activeDistance += GeolocatorPlatform.instance.distanceBetween(
            _trackCoordinates[_trackCoordinates.length - 2].latitude,
            _trackCoordinates[_trackCoordinates.length - 2].longitude,
            _trackCoordinates[_trackCoordinates.length - 1].latitude,
            _trackCoordinates[_trackCoordinates.length - 1].longitude,
          );
        } else {
          //THIS ONE USES GCD'S VINCENTY FORMULA TO CALCULATE ACTIVE DISTANCE
          _activeDistance += GreatCircleDistance.fromDegrees(
            latitude1: _trackCoordinates[_trackCoordinates.length - 2].latitude,
            longitude1: _trackCoordinates[_trackCoordinates.length - 2].longitude,
            latitude2: _trackCoordinates[_trackCoordinates.length - 1].latitude,
            longitude2: _trackCoordinates[_trackCoordinates.length - 1].longitude,
          ).vincentyDistance();
        }
      }
      setState(() {});
      if (hasInternet) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 18,
              target: LatLng(position.latitude, position.longitude),
            ),
          ),
        );
      }
    });
  }

  void _startSessionTimer() {
    //Starts the navigation session timer
    _sessionDateTime = DateTime.now();
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    _stopWatchTimerStreamSubscription = _stopWatchTimer.rawTime.listen((value) {
      _rawTime = value;
      setState(
        () {
          _elapsedTime = StopWatchTimer.getDisplayTime(
            value,
            hours: true,
            minute: true,
            second: true,
            milliSecond: false,
          );
        },
      );
    });
  }

  void _cancelSubscriptions() {
    //Cancelling data subscription to end listener that triggers the setstate(updating output values in UI)
    _positionStreamSubscription?.cancel();
    _stopWatchTimerStreamSubscription?.cancel();
  }

  void _stopSession() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    _cancelSubscriptions();
    //Check the coordinates is more than or equal two 2 and the coordinates is not all the same
    //Meaning that the user must move before calculating any data.
    final int lineWidth = StorageHelper.getInt('${currentUser!.profileNumber}lineWidth') ?? 4;
    final int borderWidth = StorageHelper.getInt('${currentUser!.profileNumber}borderWidth') ?? 6;
    //Gets all distinct values and removes the null entries from start and end.
    List<LatLng> trimmedCoordinates = _trackCoordinates.whereType<LatLng>().toSet().toList();
    double quickDistance = GeolocatorPlatform.instance.distanceBetween(
        trimmedCoordinates.first.latitude, trimmedCoordinates.first.longitude, trimmedCoordinates.last.latitude, trimmedCoordinates.last.longitude);
    //Check if user has moved before deciding in calculating or not. (Output is in meters)
    if (quickDistance >= 3.0 && trimmedCoordinates.length >= 2) {
      Set<Polyline> trimmedPolylines = {};
      trimmedPolylines.add(
        Polyline(
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          jointType: JointType.round,
          color: Color(0xFF6A8B00),
          width: borderWidth,
          visible: true,
          zIndex: 0,
          polylineId: PolylineId('border'),
          points: trimmedCoordinates,
        ),
      );
      trimmedPolylines.add(
        Polyline(
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          jointType: JointType.round,
          color: Color(0xFF9CCC03),
          width: lineWidth,
          visible: true,
          zIndex: 1,
          polylineId: PolylineId('line'),
          points: trimmedCoordinates,
        ),
      );
      _calculateData(trimmedCoordinates, trimmedPolylines).then((calculatedResult) {
        setState(() {
          //Clear all after calculation is done.
          _sessionLines.clear();
          _trackCoordinates.clear();
          _activeDistance = 0.0;
          _elapsedTime = '00:00:00';
          _currentElevation = 0.0;
          _currentSpeed = 0.0;
        });
        showModal<Map<String, dynamic>>(
          context: context,
          configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
          builder: (context) => SessionResultDialog(result: calculatedResult),
        ).then((result) async {
          //DELETES THE FILE GENERATED BY SCREENSHOT CONTROLLER.
          if (result!['takenScreenshot'] as bool) {
            FunctionHelper.deleteImage((result['imagePath'] as String));
          }
        });
      });
    } else {
      showModal(
        context: context,
        configuration: FadeScaleTransitionConfiguration(
          barrierDismissible: true,
        ),
        builder: (context) {
          return AlertDialog(
            title: Text(
              'You haven\'t moved.',
              style: TextStyle(color: Color(0xFF496D47), fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No navigation session data recorded. Try moving after starting navigation.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade600),
                  overlayColor: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.pressed) ? Colors.grey.shade700 : Colors.transparent),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ).then((value) {
        setState(() {
          _activeDistance = 0.0;
          _elapsedTime = '00:00:00';
          _currentElevation = 0.0;
          _currentSpeed = 0.0;
          _sessionLines.clear();
          _trackCoordinates.clear();
        });
      });
    }
  }

  ///Calculate LatLngBounds
  LatLngBounds _boundsFromLatLngList(List<LatLng> coordinates) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in coordinates) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast:  LatLng(x1!, y1!), southwest: LatLng(x0!, y0!), );
  }

  ////CALCULATE TOTAL DISTANCE
  double _totalDistanceFromLatLngList(List<LatLng> coordinates, int calculationMethod) {
    double distanceInMeters = 0.0;
    if (calculationMethod == 1) {
      //USES GEOLOCATOR'S HAVERSINE FORMULA
      for (var i = 0; i < coordinates.length - 1; i++) {
        distanceInMeters += GeolocatorPlatform.instance.distanceBetween(
          coordinates[i].latitude,
          coordinates[i].longitude,
          coordinates[i + 1].latitude,
          coordinates[i + 1].longitude,
        );
      }
    } else if (calculationMethod == 2) {
      //USES GCD CALCULATOR'S HAVERSINE FORMULA
      for (var i = 0; i < coordinates.length - 1; i++) {
        distanceInMeters += GreatCircleDistance.fromDegrees(
          latitude1: coordinates[i].latitude,
          longitude1: coordinates[i].longitude,
          latitude2: coordinates[i + 1].latitude,
          longitude2: coordinates[i + 1].longitude,
        ).haversineDistance();
      }
    } else {
      //USES GCD CALCULATOR'S VINCENTY FORMULA
      for (var i = 0; i < coordinates.length - 1; i++) {
        distanceInMeters += GreatCircleDistance.fromDegrees(
          latitude1: coordinates[i].latitude,
          longitude1: coordinates[i].longitude,
          latitude2: coordinates[i + 1].latitude,
          longitude2: coordinates[i + 1].longitude,
        ).vincentyDistance();
      }
    }
    //Calculation output is in meters then we convert it to kilometers.
    return double.parse((distanceInMeters / 1000).toStringAsFixed(2));
  }

  ///Calculate burned calories
  double _totalCaloriesBurned(int time, double averageSpeed, double weight) {
    // Formula: (Minutes x MET x 3.5 x Weight) / 200
    // SINCE getRawMinute always picks the floor, when the user doesn't complete a single minute.
    // It will return 0 so we have to check if it's 0 then we set it to 1, otherwhise the original higher result
    final int totalMinute = StopWatchTimer.getRawMinute(time) != 0 ? StopWatchTimer.getRawMinute(time) : 1;
    final double averageSpeedInMph = averageSpeed * 2.23694;
    double met = 0.0;
    if (averageSpeedInMph < 5.5) {
      met = 3.5;
    } else if (averageSpeedInMph > 5.5 && averageSpeedInMph < 9.4) {
      met = 5.8;
    } else if (averageSpeedInMph > 9.4 && averageSpeedInMph < 11.9) {
      met = 6.8;
    } else if (averageSpeedInMph > 11.9 && averageSpeedInMph < 13.9) {
      met = 8.0;
    } else if (averageSpeedInMph > 13.9 && averageSpeedInMph < 15.9) {
      met = 10.0;
    } else if (averageSpeedInMph > 15.9 && averageSpeedInMph < 19.0) {
      met = 12.0;
    } else {
      met = 15.8;
    }
    return double.parse(((totalMinute * met * 3.5 * weight) / 200).toStringAsFixed(2));
  }

  ///CALCULATE VALUES FROM SESSION
  Future<BikeActivity> _calculateData(List<LatLng> coordinates, Set<Polyline> polylines) async {
    //GETTING THE MAX ELEVATION FROM THE ELEVATION LIST
    final double maxElevation = double.parse(_elevation.fold(_elevation[0], max).toStringAsFixed(2));

    //GETTING THE AVERAGE(MEAN) FROM THE SPEED LIST
    final double averageSpeed = double.parse((_speed.reduce((a, b) => a + b) / _speed.length).toStringAsFixed(2));

    return BikeActivity(
      activityDate: _sessionDateTime,
      averageSpeed: averageSpeed,
      burnedCalories: _totalCaloriesBurned(_rawTime, averageSpeed, _weightInKg),
      distance: _totalDistanceFromLatLngList(coordinates, 3),
      elevation: maxElevation,
      duration: _rawTime,
      weatherData: _sessionWeather,
      polylines: polylines,
      coordinates: coordinates,
      latLngBounds: _boundsFromLatLngList(coordinates),
    );
  }

  Widget _navigationMap() {
    //Build Google Map
    return FutureBuilder(
      future: _futurePosition,
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              return GoogleMap(
                mapToolbarEnabled: false,
                myLocationEnabled: true,
                compassEnabled: true,
                myLocationButtonEnabled: false,
                rotateGesturesEnabled: true,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 50.0 + 12.0),
                mapType: _mapType,
                polylines: _sessionLines,
                onMapCreated: (GoogleMapController controller) {
                  if (mounted) {
                    setState(() {
                      _isMapMounted = true;
                    });
                    _mapControllerCompleter.complete(controller);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    snapshot.data!.latitude,
                    snapshot.data!.longitude,
                  ),
                  zoom: 18,
                ),
              );
            } else {
              return SizedBox();
            }
          case ConnectionState.active:
          case ConnectionState.waiting:
          default:
            return Center(
              child: SpinKitCubeGrid(
                color: Colors.white,
              ),
            );
        }
      },
    );
  }

  //USER POSITION BOTTOM INFO CONTAINER
  Widget buildBottomInfoContainer() {
    return Container(
      height: 50.0,
      color: Color(0xFF3D5164).withOpacity(0.8),
      child: DefaultTextStyle(
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        child: FutureBuilder(
          future: _futurePosition,
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  width: 150,
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(0.5),
                      1: FlexColumnWidth(0.7),
                    },
                    children: [
                      TableRow(
                        children: [
                          AutoSizeText('Duration: '),
                          snapshot.hasData
                              ? AutoSizeText(
                                  _elapsedTime,
                                  overflow: TextOverflow.fade,
                                )
                              : Center(
                                  child: SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 8.0,
                                  ),
                                ),
                        ],
                      ),
                      TableRow(
                        children: [
                          AutoSizeText('Distance: '),
                          snapshot.hasData
                              ? AutoSizeText(
                                  ' ${(_activeDistance / 1000).toStringAsFixed(2)} km',
                                  overflow: TextOverflow.fade,
                                )
                              : Center(
                                  child: SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 8.0,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  width: 150,
                  child: Table(
                    columnWidths: {0: FlexColumnWidth(0.5), 1: FlexColumnWidth(0.5)},
                    children: [
                      TableRow(
                        children: [
                          AutoSizeText('Elevation: '),
                          snapshot.hasData
                              ? AutoSizeText(
                                  _currentElevation.toStringAsFixed(0),
                                  overflow: TextOverflow.fade,
                                )
                              : Center(
                                  child: SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 8.0,
                                  ),
                                ),
                        ],
                      ),
                      TableRow(
                        children: [
                          AutoSizeText('Speed: '),
                          snapshot.hasData
                              ? AutoSizeText(
                                  _currentSpeed.toStringAsFixed(2) + ' m/s',
                                  overflow: TextOverflow.fade,
                                )
                              : Center(
                                  child: SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 8.0,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //WEATHER RELATED FUNCTIONS
  Future<Weather> _currentWeather(Position pos) async {
    late Weather _currentWeather;
    //Position pos = await _currentPosition();
    await InternetConnectionChecker().hasConnection.then((hasInternet) async {
      if (hasInternet) {
        _currentWeather = await wf.currentWeatherByLocation(
          pos.latitude,
          pos.longitude,
        );
      } else {
        return Future.error('No Internet');
      }
    });
    _sessionWeather = _currentWeather;
    return _currentWeather;
  }

  Widget buildWeatherInfo() {
    return FutureBuilder(
      future: _futureWeather,
      builder: (BuildContext context, AsyncSnapshot<Weather?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              CustomToast.showToastSimple(context: context, simpleMessage: snapshot.error.toString());
              return SizedBox.shrink();
            } else {
              return Tooltip(
                message: snapshot.data!.weatherDescription!,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomRoutes.sharedAxis(
                        page: WeatherForecast(
                          coordinates: _currentPos,
                          weather: snapshot.data!,
                        ),
                      ),
                    );
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: snapshot.data!.temperature.toString().replaceAll(RegExp(r'Celsius'), '°C'),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                          ),
                          WidgetSpan(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Stack(
                                children: [
                                  Opacity(
                                    opacity: 0.8,
                                    child: CachedNetworkImage(
                                      color: Colors.black,
                                      imageUrl: 'http://openweathermap.org/img/wn/' + snapshot.data!.weatherIcon! + '@2x.png',
                                      errorWidget: (context, string, url) => Icon(Icons.error),
                                    ),
                                  ),
                                  ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, string) => SpinKitDoubleBounce(
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                        imageUrl: 'http://openweathermap.org/img/wn/' + snapshot.data!.weatherIcon! + '@2x.png',
                                        errorWidget: (context, string, url) => Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            }

          case ConnectionState.active:
          case ConnectionState.waiting:
          default:
            return Align(
              alignment: Alignment.center,
              child: SpinKitThreeBounce(
                color: Colors.white,
                size: 15,
              ),
            );
        }
      },
    );
  }
}

//==================SESSION RESULT DIALOG V2====================//
//Show Result Dialog of the Session When the User Stops the Session Activity.
//V1 WAS KINDA BAD
class SessionResultDialog extends StatefulWidget {
  final BikeActivity result;
  SessionResultDialog({Key? key, required this.result}) : super(key: key);

  @override
  _SessionResultDialogState createState() => _SessionResultDialogState();
}

class _SessionResultDialogState extends State<SessionResultDialog> {
  late BikeActivity _userActivity;
  final Completer<GoogleMapController> _sessionMapCompleter = Completer();
  Uint8List? _mapScreenshotBytes;
  bool _showMapScreenshot = false, _sessionSaved = false, _takenScreenhot = false;
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
                                          mapType: _resultMapType,
                                          markers: _sessionMarkers,
                                          polylines: _userActivity.polylines!,
                                          initialCameraPosition: CameraPosition(
                                            //Default Camera Target (It is a required parameter so we just used middle of the coordinates)
                                            target: _userActivity.coordinates![_userActivity.coordinates!.length ~/ 2]!,
                                            zoom: 18,
                                          ),
                                          onMapCreated: (controller) {
                                            if (mounted) {
                                              _sessionMapCompleter.complete(controller);
                                              Future.delayed(Duration(milliseconds: 300), () {
                                                controller.moveCamera(CameraUpdate.newLatLngBounds(_userActivity.latLngBounds!, 10.0));
                                                setState(() {
                                                  _setSessionMarkers(snapshot.data![0], snapshot.data![1]);
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
                                    padding: EdgeInsets.fromLTRB(0, 5.0, 5.0, 0),
                                    child: Material(
                                      color: Colors.white.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(2),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          if (_resultMapType == MapType.normal) {
                                            _resultMapType = MapType.hybrid;
                                          } else if (_resultMapType == MapType.hybrid) {
                                            _resultMapType = MapType.satellite;
                                          } else if (_resultMapType == MapType.satellite) {
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
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: Offset(-0.5, 0),
                                                blurRadius: 10.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                              //Right
                                              CustomBoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: Offset(0.5, 0),
                                                blurRadius: 10.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                              //Bottom
                                              CustomBoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
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
                        child: Text(
                          'Save',
                        ),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          backgroundColor: MaterialStateProperty.all(Color(0xFF496D47)),
                          overlayColor: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.pressed) ? Color(0xFF496D47).darken(0.1) : Colors.transparent),
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
                            await Hive.box<BikeActivity>('${currentUser!.profileNumber}bikeActivities').add(
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
                                coordinates: _userActivity.coordinates!.toList(),
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
                          onPrimary: Colors.white,
                          primary: Colors.grey,
                        ),
                        onPressed: () {
                          if (_sessionSaved) {
                            Navigator.pop(context, {'takenScreenshot': _takenScreenhot, 'imagePath': _imagePath});
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
                                      foregroundColor: MaterialStateProperty.all(Colors.white),
                                      backgroundColor: MaterialStateProperty.all(Colors.red.shade300),
                                      overlayColor: MaterialStateProperty.resolveWith(
                                          (states) => states.contains(MaterialState.pressed) ? Colors.red.withOpacity(0.8) : Colors.transparent),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('No'),
                                    style: ButtonStyle(
                                      foregroundColor: MaterialStateProperty.all(Color(0xFF496D47)),
                                      backgroundColor: MaterialStateProperty.all(Colors.grey.shade300),
                                      overlayColor: MaterialStateProperty.resolveWith((states) =>
                                          states.contains(MaterialState.pressed) ? Color(0xFF496D47).withOpacity(0.8) : Colors.transparent),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                  ),
                                ],
                              ),
                            ).then((wantToClose) {
                              if (wantToClose!) {
                                Navigator.pop(context, {'takenScreenshot': _takenScreenhot, 'imagePath': _imagePath});
                              }
                            });
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text('Share'),
                        style: ElevatedButton.styleFrom(onPrimary: Colors.white, primary: Colors.blue.shade400),
                        onPressed: () async {
                          _takenScreenhot = true;
                          GoogleMapController _mapController = await _sessionMapCompleter.future;
                          await _mapController.takeSnapshot().then((value) async {
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
                              Share.shareFiles([_imagePath],
                                  subject: 'Session Result', text: 'Check out my ride session result!', mimeTypes: ['image/png']);
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

  void _setSessionMarkers(BitmapDescriptor startIcon, BitmapDescriptor endIcon) {
    //Add the session markers after session end
    setState(() {
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
    });
  }

  Future<List<BitmapDescriptor>> _initializeIcons() async {
    //Loads the icons to be used as markers later
    final _startIconMarker =
        BitmapDescriptor.fromBytes(await FunctionHelper.getBytesFromAsset('assets/images/navigate/starting_point_icon_v4.png', 50));
    final _endIconMarker = BitmapDescriptor.fromBytes(await FunctionHelper.getBytesFromAsset('assets/images/navigate/end_point_icon_v4.png', 50));
    return [_startIconMarker, _endIconMarker];
  }

  void _sessionLocations() async {
    await GeocodingPlatform.instance
        .placemarkFromCoordinates(_userActivity.coordinates!.first!.latitude, _userActivity.coordinates!.first!.longitude, localeIdentifier: 'en_PH')
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
    await GeocodingPlatform.instance
        .placemarkFromCoordinates(_userActivity.coordinates!.last!.latitude, _userActivity.coordinates!.last!.longitude, localeIdentifier: 'en_PH')
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

class NavigationSettings extends StatefulWidget {
  @override
  _NavigationSettingsState createState() => _NavigationSettingsState();
}

class _NavigationSettingsState extends State<NavigationSettings> with SingleTickerProviderStateMixin {
  final Map<String, String> _accuracyChoices = {
    'Low': 'Accurate within 500m distance. Consumes less battery power but less accurate.',
    'Medium': 'Accurate between 100m-500m distance . Consumes average battery power and slightly accurate.',
    'High': 'Accurate between 0m and 100m distance. Consumes more battery power but more accurate.'
  };
  String? _selectedAccuracy = StorageHelper.getString('${currentUser!.profileNumber}locationAccuracy') ?? 'High';

  final _dfKey = GlobalKey<FormState>();
  final TextEditingController _dfController = TextEditingController();
  final FocusNode _dfFocusNode = FocusNode();
  final int _distanceFilter = StorageHelper.getInt('${currentUser!.profileNumber}distanceFilter') ?? 0;
  String? _dfError;

  final Map<String, String> _formulaChoices = {
    'Haversine': 'Consumes less battery power but less accurate.',
    'Vincenty': 'Consumes more battery power but more accurate.',
  };
  String? _selectedFormula = StorageHelper.getString('${currentUser!.profileNumber}formula') ?? 'Haversine';

  double _lineWidth = StorageHelper.getInt('${currentUser!.profileNumber}lineWidth')?.toDouble() ?? 4.0;
  double _borderWidth = StorageHelper.getInt('${currentUser!.profileNumber}borderWidth')?.toDouble() ?? 6.0;
  bool? _includeBorder = StorageHelper.getBool('${currentUser!.profileNumber}includeBorder') ?? true;
  Set<Polyline> _samplePolyline = {};
  final List<LatLng> _sampleCoordinates = [
    LatLng(15.855859413795411, 120.9928647189144),
    LatLng(15.856096788054394, 120.99295591402391),
    LatLng(15.85627223841336, 120.9930578379696),
    LatLng(15.856323841431005, 120.9932455926061),
    LatLng(15.856298039923427, 120.99345480491209),
    LatLng(15.856246436899104, 120.99366938163939),
    LatLng(15.856215475078118, 120.99388932278275),
    LatLng(15.856184513252437, 120.9940717130014),
    LatLng(15.856153551423132, 120.99431311180197),
    LatLng(15.856138070506857, 120.99450623085225),
    LatLng(15.856189673558887, 120.99471544316187),
    LatLng(15.856236116294433, 120.9949031977987),
    LatLng(15.85633416203435, 120.99505340150817),
    LatLng(15.856421887129677, 120.99517141870847),
    LatLng(15.85641672683101, 120.99532698683612),
    LatLng(15.856246436900873, 120.99535917334529),
    LatLng(15.856086467441617, 120.99530552916336),
  ];

  @override
  void initState() {
    super.initState();
    _dfController.addListener(_dfFormValidator);
    _dfFocusNode.addListener(_dfListener);
    _dfController.text = _distanceFilter.toString();
    if (_includeBorder!) {
      _samplePolyline.add(
        Polyline(
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          jointType: JointType.round,
          color: Color(0xFF6A8B00),
          width: _borderWidth.floor(),
          visible: true,
          zIndex: 0,
          polylineId: PolylineId('border'),
          points: _sampleCoordinates,
        ),
      );
    }
    _samplePolyline.add(
      Polyline(
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        jointType: JointType.round,
        color: Color(0xFF9CCC03),
        width: _lineWidth.floor(),
        visible: true,
        zIndex: 1,
        polylineId: PolylineId('line'),
        points: _sampleCoordinates,
      ),
    );
  }

  @override
  void dispose() {
    _dfController.dispose();
    _dfFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.0),
      contentPadding: EdgeInsets.all(10),
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 2.0),
      actions: [
        TextButton(
          child: Text('Save'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Color(0xFF496D47)),
            overlayColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.pressed) ? Color(0xFF496D47).darken(0.1) : Colors.transparent),
          ),
          onPressed: () {
            StorageHelper.setString('${currentUser!.profileNumber}locationAccuracy', _selectedAccuracy!);
            StorageHelper.setInt('${currentUser!.profileNumber}distanceFilter', double.parse(_dfController.text).floor());
            StorageHelper.setString('${currentUser!.profileNumber}formula', _selectedFormula!);
            StorageHelper.setInt('${currentUser!.profileNumber}lineWidth', _lineWidth.floor());
            StorageHelper.setInt('${currentUser!.profileNumber}borderWidth', _borderWidth.floor());
            StorageHelper.setBool('${currentUser!.profileNumber}includeBorder', _includeBorder!);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('Default'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Colors.orange.shade400),
            overlayColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed) ? Colors.orange : Colors.transparent),
          ),
          onPressed: () {
            setState(() {
              _selectedAccuracy = 'High';
              _dfController.text = '0';
              _selectedFormula = 'Haversine';
              _lineWidth = 4;
              _borderWidth = 6;
              _includeBorder = true;
            });
            _updatePolyline();
          },
        ),
        TextButton(
          child: Text('Cancel'),
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              overlayColor:
                  MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.pressed) ? Colors.grey.shade600 : Colors.transparent)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 70,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text.rich(
                        TextSpan(
                          text: 'Accuracy: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: _accuracyChoices[_selectedAccuracy!],
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Listener(
                        onPointerDown: (_) => FocusScope.of(context).unfocus(),
                        child: DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          value: _selectedAccuracy,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedAccuracy = value;
                            });
                          },
                          items: _accuracyChoices.keys.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 85,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 90,
                            child: Text.rich(
                              TextSpan(
                                text: 'Distance Filter: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        'The distance in meters you need to move before updating the next position. The lower the better but consumes more power.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 10,
                            child: Visibility(
                              visible: _dfError != null ? true : false,
                              child: Text(
                                _dfError ?? '',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: Form(
                      key: _dfKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        controller: _dfController,
                        autofocus: false,
                        focusNode: _dfFocusNode,
                        onEditingComplete: () {
                          _dfFocusNode.unfocus();
                        },
                        onFieldSubmitted: (val) {
                          _dfFocusNode.unfocus();
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(3), FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                        decoration: InputDecoration(
                          isDense: true,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF496D47),
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          errorStyle: TextStyle(height: 0),
                        ),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return null;
                          } else {
                            if (num.parse(text) > 100) {
                              return '';
                            }
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 65,
                    child: Text.rich(
                      TextSpan(
                        text: 'Active Distance Calculator:\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: _formulaChoices[_selectedFormula!],
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 35,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        underline: SizedBox.shrink(),
                        value: _selectedFormula,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedFormula = value;
                          });
                        },
                        items: _formulaChoices.keys
                            .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                )))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Traveled Route Indicator',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Container(
              height: 100,
              width: double.maxFinite,
              child: IgnorePointer(
                ignoring: true,
                child: GoogleMap(
                  mapType: MapType.none,
                  polylines: _samplePolyline,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                    //Default camera position (It is a required parameter so we just used a random coordinates)
                    target: LatLng(15.856045184982273, 120.99408780624543),
                    zoom: 17,
                  ),
                ),
              ),
            ),
            //Polyline Line Width Settings Slider
            Container(
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: false,
                    child: Expanded(
                      flex: 20,
                      child: Text(
                        'Line',
                        style: TextStyle(
                          color: Color(0xFF496D47),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.white,
                        activeTrackColor: Color(0xFF9CCC03),
                        inactiveTrackColor: Color(0xFF6A8B00),
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                        trackShape: RoundedRectSliderTrackShape(),
                        thumbShape: BorderedSliderThumbShape(
                          borderWidth: 2,
                          borderColor: Color(0xFF9CCC03),
                        ),
                      ),
                      child: Slider(
                        value: _lineWidth,
                        min: 1,
                        max: 9,
                        divisions: (9 - 1) * 4,
                        onChanged: (val) {
                          _lineWidth = val;
                          _updatePolyline();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Polyline Border Width Setting Slider
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: false,
                    child: Expanded(
                      flex: 20,
                      child: AutoSizeText(
                        'Border',
                        style: TextStyle(
                          color: Color(0xFF496D47),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Checkbox(
                      value: _includeBorder,
                      activeColor: Color(0xFF496D47),
                      onChanged: (val) {
                        setState(() {
                          _includeBorder = val;
                        });
                        _updatePolyline();
                      },
                    ),
                  ),
                  Expanded(
                    flex: 75,
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.white,
                        activeTrackColor: Color(0xFF6A8B00),
                        disabledActiveTrackColor: Colors.grey,
                        inactiveTrackColor: Color(0xFF9CCC03),
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                        disabledThumbColor: Colors.grey.shade300,
                        trackShape: RoundedRectSliderTrackShape(),
                        thumbShape: BorderedSliderThumbShape(
                          borderWidth: 2,
                          borderColor: Color(0xFF6A8B00),
                          disableBorderColor: Colors.grey,
                        ),
                      ),
                      child: Slider(
                        value: _borderWidth,
                        min: 2,
                        max: 10,
                        divisions: (10 - 2) * 4,
                        onChanged: _includeBorder != true
                            ? null
                            : (val) {
                                _borderWidth = val;
                                _updatePolyline();
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dfListener() {
    if (!_dfFocusNode.hasFocus) FocusScope.of(context).requestFocus(new FocusNode());
  }

  void _dfFormValidator() {
    if (_dfController.text.isEmpty) {
      setState(() {
        _dfController.text = _distanceFilter.toString();
        _dfError = null;
      });
    } else {
      if (num.parse(_dfController.text) > 100) {
        setState(() {
          _dfError = 'Exceeding 100 meters';
        });
      } else {
        setState(() {
          _dfError = null;
        });
      }
    }
  }

  void _updatePolyline() {
    _samplePolyline.clear();
    setState(() {
      if (_includeBorder!) {
        _samplePolyline.add(
          Polyline(
            polylineId: PolylineId('border'),
            visible: true,
            zIndex: 0,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true,
            jointType: JointType.round,
            color: Color(0xFF6A8B00),
            width: _borderWidth.floor(),
            points: _sampleCoordinates,
          ),
        );
      }
      _samplePolyline.add(
        Polyline(
          polylineId: PolylineId('line'),
          visible: true,
          zIndex: 1,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          jointType: JointType.round,
          color: Color(0xFF9CCC03),
          width: _lineWidth.floor(),
          points: _sampleCoordinates,
        ),
      );
    });
  }
}
