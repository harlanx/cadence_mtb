part of '../../pages/navigate.dart';

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
