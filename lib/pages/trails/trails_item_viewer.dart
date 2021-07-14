part of '../../pages/trails.dart';

class TrailsItemViewer extends StatefulWidget {
  TrailsItemViewer({
    required this.item,
  });
  final TrailsItem item;

  @override
  _TrailsItemViewerState createState() => _TrailsItemViewerState();
}

class _TrailsItemViewerState extends State<TrailsItemViewer> {
  final WeatherFactory wf = WeatherFactory(Constants.openWeatherMapApiKey, language: Language.ENGLISH);
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  bool _isMapMounted = false;
  MapType _mapType = MapType.satellite;
  Set<Marker> _markers = {};
  late Future<Weather?> _futureWeather;
  late Future<BitmapDescriptor> _futureIcon;

  @override
  void initState() {
    super.initState();
    _futureIcon = _initializeIcon();
    //Save to JSON in the future if you want offline access of last fetched weather data for various trails
    _futureWeather = _trailWeather();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _screenSize = MediaQuery.of(context).size;
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFFB8784B), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Color(0xFFB8784B),
            elevation: 5,
            bottom: PreferredSize(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor.darken(0.1),
                height: 2.0,
              ),
              preferredSize: Size.fromHeight(2.0),
            ),
            title: AutoSizeText(
              widget.item.trailName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              maxLines: 1,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ListView(
              children: [
                Container(
                  height: _isPortrait ? _screenSize.height * 0.3 : _screenSize.height * 0.5,
                  width: double.maxFinite,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FutureBuilder<BitmapDescriptor>(
                        future: _futureIcon,
                        builder: (_, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return SizedBox.expand();
                              } else {
                                return GoogleMap(
                                  markers: _markers,
                                  mapType: _mapType,
                                  mapToolbarEnabled: false,
                                  onMapCreated: (controller) {
                                    if (mounted) {
                                      _mapControllerCompleter.complete(controller);
                                      setState(() {
                                        _markers.add(
                                          Marker(
                                            markerId: MarkerId('trailMarker'),
                                            draggable: false,
                                            position: LatLng(widget.item.latitude, widget.item.longitude),
                                            infoWindow: InfoWindow(title: widget.item.trailName),
                                            icon: snapshot.data!,
                                          ),
                                        );
                                        _isMapMounted = true;
                                      });
                                      Future.delayed(Duration(milliseconds: 300), () {
                                        controller.showMarkerInfoWindow(MarkerId('trailMarker'));
                                      });
                                    }
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(widget.item.latitude, widget.item.longitude),
                                    zoom: 17,
                                  ),
                                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                    Factory<OneSequenceGestureRecognizer>(
                                      () => EagerGestureRecognizer(),
                                    ),
                                  ].toSet(),
                                );
                              }

                            default:
                              return SizedBox.expand();
                          }
                        },
                      ),
                      Visibility(
                        visible: _isMapMounted,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 12, 12.0, 0.0),
                            child: Material(
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Address: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: widget.item.location,
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Table(
                  children: [
                    TableRow(
                      children: [
                        AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Trail Type: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: widget.item.trailType,
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                        AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Distance: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: widget.item.distance,
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Difficulty: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: widget.item.difficulty,
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                        AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Elevation: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: widget.item.elevation,
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Rating: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              WidgetSpan(
                                child: RatingBarIndicator(
                                  rating: widget.item.rating,
                                  itemCount: 5,
                                  itemSize: 18,
                                  direction: Axis.horizontal,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              WidgetSpan(
                                child: AutoSizeText(
                                  widget.item.rating.toString(),
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                  presetFontSizes: [12, 8],
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                        Text.rich(
                          TextSpan(
                            text: 'Weather: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                            children: [
                              WidgetSpan(
                                child: FutureBuilder<Weather?>(
                                  future: _futureWeather,
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.done:
                                        if (snapshot.hasError) {
                                          return Text(
                                            snapshot.error as String,
                                            style: TextStyle(fontWeight: FontWeight.w300),
                                            maxLines: 1,
                                            overflow: TextOverflow.clip,
                                          );
                                        } else {
                                          return Tooltip(
                                            message: snapshot.data!.weatherDescription!,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  CustomRoutes.fadeThrough(
                                                    page: WeatherForecast(
                                                      coordinates: LatLng(widget.item.latitude, widget.item.longitude),
                                                      weather: snapshot.data!,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: snapshot.data!.temperature.toString().replaceAll(RegExp(r'Celsius'), '°C'),
                                                      style: TextStyle(fontWeight: FontWeight.w300),
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
                                                                placeholder: (context, string) => SpinKitDoubleBounce(color: Colors.white),
                                                                imageUrl:
                                                                    'http://openweathermap.org/img/wn/' + snapshot.data!.weatherIcon! + '@2x.png',
                                                                errorWidget: (context, string, url) => Icon(Icons.error),
                                                              ),
                                                            ),
                                                            ClipRect(
                                                              child: BackdropFilter(
                                                                filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                                                                child: CachedNetworkImage(
                                                                  placeholder: (context, string) => SpinKitDoubleBounce(color: Colors.white),
                                                                  imageUrl:
                                                                      'http://openweathermap.org/img/wn/' + snapshot.data!.weatherIcon! + '@2x.png',
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
                                              ),
                                            ),
                                          );
                                        }

                                      default:
                                        return Text('Loading...', style: TextStyle(fontWeight: FontWeight.w300));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: AutoSizeText(
                    widget.item.description,
                    textAlign: TextAlign.justify,
                    softWrap: true,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  height: _isPortrait ? _screenSize.height * 0.4 : _screenSize.height * 0.5,
                  width: double.maxFinite,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.item.previews.length + 1,
                    separatorBuilder: (_, __) => SizedBox(width: 5),
                    itemBuilder: (_, index) {
                      if (index < widget.item.previews.length) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomRoutes.fadeThrough(
                                page: ImageViewer(
                                  imageIndex: index,
                                  imagePath: widget.item.previews[index],
                                ),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.item.previews[index],
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomRoutes.fadeThrough(
                                page: AppBrowser(
                                  link: widget.item.imagesLink,
                                  purpose: 2,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            color: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Google\nSearch \nImages',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(Icons.search, color: Colors.white),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: !sosEnabled['Trails']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _initializeIcon() async {
    return BitmapDescriptor.fromBytes(await FunctionHelper.getBytesFromAsset('assets/images/navigate/trail_marker_simple_v2.png', 50));
  }

  Future<Weather?> _trailWeather() async {
    Weather? weather;
    await InternetConnectionChecker().hasConnection.then((hasInternet) async {
      if (hasInternet) {
        weather = await wf.currentWeatherByLocation(widget.item.latitude, widget.item.longitude).catchError((e) {
          Future.error(e);
        });
      } else {
        Future.error('No Internet.');
      }
    });
    return weather;
  }
}
