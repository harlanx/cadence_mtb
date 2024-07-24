import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/app_settings.dart';
import 'package:cadence_mtb/pages/bike_activity_history.dart';
import 'package:cadence_mtb/pages/weather_forecast.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:weather/weather.dart';
part 'navigate/new_ride_session_viewer.dart';
part 'navigate/navigation_settings.dart';

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
  double _activeDistance = 0.0,
      _currentSpeed = 0.0,
      _currentElevation = 0.0,
      _weightInKg = 57.7;
  int _rawTime = 0;
  String _elapsedTime = '00:00:00', _appBarTitle = 'Navigation';
  late DateTime _sessionDateTime;
  late Future<Position> _futurePosition;
  late LatLng _currentPos;
  List<double> _speed = [], _elevation = [];
  List<LatLng> _trackCoordinates = [];
  Set<Polyline> _sessionLines = {
    Polyline(polylineId: PolylineId('border')),
    Polyline(polylineId: PolylineId('line'))
  };
  MapType _mapType = MapType.normal;
  //Possible for offline mode? Not explored yet.
  // Set<TileOverlay> _offlineTiles = {};
  // TileProvider _tileProvider;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<int>? _stopWatchTimerStreamSubscription;
  //WEATHER RELATED VARIABLES AND OBJECTS
  Future<Weather>? _futureWeather;
  Weather? _sessionWeather;
  final WeatherFactory wf = WeatherFactory(Constants.openWeatherMapApiKey,
      language: Language.ENGLISH);

  @override
  void initState() {
    WakelockPlus.toggle(enable: true);
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
    WakelockPlus.toggle(enable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF3D5164),
          statusBarIconBrightness: Brightness.light),
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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: buildBottomInfoContainer())),
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
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
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
                        builder: (context) => PopScope(
                          canPop: false,
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
                    padding: EdgeInsets.fromLTRB(
                        0.0,
                        AppBar().preferredSize.height +
                            MediaQuery.of(context).padding.top +
                            12,
                        12.0,
                        0.0),
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
                              final GoogleMapController controller =
                                  await _mapControllerCompleter.future;
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

    _serviceEnabled =
        await GeolocatorPlatform.instance.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    _permission = await GeolocatorPlatform.instance.checkPermission();
    if (_permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (_permission == LocationPermission.denied) {
      _permission = await GeolocatorPlatform.instance.requestPermission();
      if (_permission != LocationPermission.whileInUse ||
          _permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $_permission).');
      }
    }
    Position pos = await GeolocatorPlatform.instance.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    _currentSpeed = pos.speed;
    _currentElevation = pos.altitude;
    return pos;
  }

  void _userLocationAddress(LatLng coordinates) async {
    final geoInstance = GeocodingPlatform.instance
      ?..setLocaleIdentifier('en_PH');
    await geoInstance
        ?.placemarkFromCoordinates(coordinates.latitude, coordinates.longitude)
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
    _weightInKg =
        StorageHelper.getDouble('${currentUser!.profileNumber}userWeight') ??
            57.7;
    String locationAccuracy =
        StorageHelper.getString('${currentUser!.profileNumber}locationAccuracy')
                ?.toLowerCase() ??
            'high';
    LocationAccuracy userDesiredAccuracy = LocationAccuracy.values
        .singleWhere((element) => element.name == locationAccuracy);
    int distanceFilter =
        StorageHelper.getInt('${currentUser!.profileNumber}distanceFilter') ??
            0;
    String formula =
        StorageHelper.getString('${currentUser!.profileNumber}formula') ??
            'Haversine';
    int lineWidth =
        StorageHelper.getInt('${currentUser!.profileNumber}lineWidth') ?? 4;
    int borderWidth =
        StorageHelper.getInt('${currentUser!.profileNumber}borderWidth') ?? 6;
    //Check if has internet first before showing polyline.
    //Otherwise show latlng data only (Not yet implemented)
    bool hasInternet = await InternetConnectionChecker().hasConnection;
    //This starts the stream of data and starts the timer
    _startSessionTimer();
    _positionStreamSubscription = GeolocatorPlatform.instance
        .getPositionStream(
            locationSettings: LocationSettings(
                accuracy: userDesiredAccuracy, distanceFilter: distanceFilter))
        .listen((position) async {
      final GoogleMapController controller =
          await _mapControllerCompleter.future;
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
            longitude1:
                _trackCoordinates[_trackCoordinates.length - 2].longitude,
            latitude2: _trackCoordinates[_trackCoordinates.length - 1].latitude,
            longitude2:
                _trackCoordinates[_trackCoordinates.length - 1].longitude,
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
    _stopWatchTimer.onResetTimer();
    _stopWatchTimer.onStartTimer();
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
    _stopWatchTimer.onStopTimer();
    _cancelSubscriptions();
    //Check the coordinates is more than or equal two 2 and the coordinates is not all the same
    //Meaning that the user must move before calculating any data.
    final int lineWidth =
        StorageHelper.getInt('${currentUser!.profileNumber}lineWidth') ?? 4;
    final int borderWidth =
        StorageHelper.getInt('${currentUser!.profileNumber}borderWidth') ?? 6;
    //Gets all distinct values and removes the null entries from start and end.
    List<LatLng> trimmedCoordinates =
        _trackCoordinates.whereType<LatLng>().toSet().toList();
    double quickDistance = GeolocatorPlatform.instance.distanceBetween(
        trimmedCoordinates.first.latitude,
        trimmedCoordinates.first.longitude,
        trimmedCoordinates.last.latitude,
        trimmedCoordinates.last.longitude);
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
      _calculateData(trimmedCoordinates, trimmedPolylines)
          .then((calculatedResult) {
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
          configuration:
              FadeScaleTransitionConfiguration(barrierDismissible: false),
          builder: (context) => NewRideSessionViewer(result: calculatedResult),
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
              style: TextStyle(
                  color: Color(0xFF496D47), fontWeight: FontWeight.w700),
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
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all(Colors.grey.shade600),
                  overlayColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.pressed)
                          ? Colors.grey.shade700
                          : Colors.transparent),
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
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  ////CALCULATE TOTAL DISTANCE
  double _totalDistanceFromLatLngList(
      List<LatLng> coordinates, int calculationMethod) {
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
    final int totalMinute = StopWatchTimer.getRawMinute(time) != 0
        ? StopWatchTimer.getRawMinute(time)
        : 1;
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
    return double.parse(
        ((totalMinute * met * 3.5 * weight) / 200).toStringAsFixed(2));
  }

  ///CALCULATE VALUES FROM SESSION
  Future<BikeActivity> _calculateData(
      List<LatLng> coordinates, Set<Polyline> polylines) async {
    //GETTING THE MAX ELEVATION FROM THE ELEVATION LIST
    final double maxElevation =
        double.parse(_elevation.fold(_elevation[0], max).toStringAsFixed(2));

    //GETTING THE AVERAGE(MEAN) FROM THE SPEED LIST
    final double averageSpeed = double.parse(
        (_speed.reduce((a, b) => a + b) / _speed.length).toStringAsFixed(2));

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
                    columnWidths: {
                      0: FlexColumnWidth(0.5),
                      1: FlexColumnWidth(0.5)
                    },
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
              CustomToast.showToastSimple(
                  context: context, simpleMessage: snapshot.error.toString());
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
                            text: snapshot.data!.temperature
                                .toString()
                                .replaceAll(RegExp(r'Celsius'), '°C'),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
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
                                      imageUrl:
                                          'http://openweathermap.org/img/wn/' +
                                              snapshot.data!.weatherIcon! +
                                              '@2x.png',
                                      errorWidget: (context, string, url) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 1.0, sigmaY: 1.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, string) =>
                                            SpinKitDoubleBounce(
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                        imageUrl:
                                            'http://openweathermap.org/img/wn/' +
                                                snapshot.data!.weatherIcon! +
                                                '@2x.png',
                                        errorWidget: (context, string, url) =>
                                            Icon(Icons.error),
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
