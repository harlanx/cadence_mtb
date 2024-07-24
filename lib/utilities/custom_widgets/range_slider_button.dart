import 'package:flutter/material.dart';

/// A range slider with additional button to increase and decrease value.
class RangeSliderButton<T extends num> extends StatefulWidget {
  final T value;
  final T minValue;
  final T maxValue;
  final T addingNumber;
  final T subtractingNumber;

  /// If values provided are double, it will be parsed
  /// into an integer with floor to decide the number.
  final double buttonSize;
  final double spacing;
  final double sliderWidth;
  final double valueSize;
  final TextStyle? textStyle;
  final Color? minusButtonColor;
  final Color? minusIconColor;
  final Color? plusButtonColor;
  final Color? plusIconColor;
  final ValueChanged<T> onChanged;

  RangeSliderButton({
    Key? key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.addingNumber,
    required this.subtractingNumber,
    this.buttonSize = 10,
    this.spacing = 5,
    this.sliderWidth = 120,
    this.valueSize = 15,
    this.textStyle,
    this.minusButtonColor,
    this.minusIconColor,
    this.plusButtonColor,
    this.plusIconColor,
    required this.onChanged,
  })  : assert(minValue <= value && value <= maxValue,
            'initialValue is not in range of minValue and maxValue'),
        assert(
            minValue < maxValue, 'minValue must not be greater than maxValue'),
        super(key: key);

  @override
  RangeCounterState<T> createState() => RangeCounterState<T>();
}

class RangeCounterState<T extends num> extends State<RangeSliderButton<T>> {
  late T _currentValue;
  @override
  void didUpdateWidget(covariant RangeSliderButton<T> oldWidget) {
    _currentValue = widget.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.buttonSize,
          width: widget.buttonSize,
          child: MaterialButton(
            color: widget.minusButtonColor ??
                Theme.of(context).colorScheme.onPrimary,
            shape: CircleBorder(),
            padding: EdgeInsets.all(2),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color:
                    widget.minusIconColor ?? Theme.of(context).iconTheme.color,
              ),
            ),
            onPressed: () {
              subtract();
            },
          ),
        ),
        _spacing(),
        SizedBox(
          width: widget.sliderWidth,
          //Weird, the height expands so we have to set a height
          height: 10,
          child: Slider(
            max: widget.maxValue as double,
            min: widget.minValue as double,
            divisions: null,
            value: _currentValue as double,
            onChanged: (value) {
              widget.onChanged(num.parse(value.toStringAsFixed(3)) as T);
              setState(() {
                _currentValue = value as T;
              });
            },
          ),
        ),
        _spacing(),
        SizedBox(
          height: widget.buttonSize,
          width: widget.buttonSize,
          child: MaterialButton(
            height: widget.buttonSize,
            minWidth: widget.buttonSize,
            color: widget.plusButtonColor ??
                Theme.of(context).colorScheme.onPrimary,
            shape: CircleBorder(),
            padding: EdgeInsets.all(2),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(
                Icons.arrow_forward_ios,
                color:
                    widget.plusIconColor ?? Theme.of(context).iconTheme.color,
              ),
            ),
            onPressed: () {
              add();
            },
          ),
        ),
      ],
    );
  }

  Widget _spacing() {
    return SizedBox(
      width: widget.spacing,
    );
  }

  /// Increase the current number
  void add() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue = _currentValue + widget.addingNumber as T;
      });
      widget.onChanged(num.parse(_currentValue.toStringAsFixed(3)) as T);
    }
  }

  /// Decrease the current number
  void subtract() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue = _currentValue - widget.subtractingNumber as T;
      });
      widget.onChanged(num.parse(_currentValue.toStringAsFixed(3)) as T);
    }
  }
}
