part of '../../pages/bmi_history.dart';

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
                                keyboardType: TextInputType.number,
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
                                keyboardType: TextInputType.number,
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
