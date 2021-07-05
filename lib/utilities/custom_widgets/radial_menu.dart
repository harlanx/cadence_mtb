import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:math' as math;

class RadialMenu extends StatefulWidget {
  /// Use global key to control animation anywhere in the code
  final GlobalKey<RadialMenuState>? key;

  /// Use your own open icon, close icon must not be null.
  /// Defaults to [Icon(Icons.menu)]
  final Widget openIcon;

  /// Use your own close icon, open icon must not be null.
  /// Defaults to [Icon(Icons.close)]
  final Widget closeIcon;

  /// Text to display when long pressed
  final String? tooltip;

  /// List of RadialMenuItem, must contains at least two items.
  /// Arranged in clockwise order.
  final List<RadialMenuItem> children;

  /// Menu button alignment.
  /// Defaults to [Alignment.bottomCenter]
  final AlignmentGeometry alignment;

  /// Distance radius of children.
  /// Defaults to [100]
  final double radius;

  /// Shrinks icon when animating to close icon.
  /// Recommended to wrap your icon widget using
  /// [FittedBox] with property [BoxFit.cover]
  /// Defaults to [false] which has expanding animation
  final bool iconShrink;

  /// Animation duration
  /// Defaults to [Duration(milliseconds: 500)]
  final Duration animationDuration;

  /// Forward animation curve
  /// Defaults to [Curves.bounceOut]
  final Curve forwardCurve;

  /// Reverse animation curve
  /// Defaults to [Curves.fastOutSlowIn]
  final Curve reverseCurve;

  /// Callback for you own function
  final VoidCallback? onPressed;

  /// Button background color
  /// Defaults to the [Theme.of(context).primaryColor]
  final Color? color;

  /// Menu button size
  /// Defaults to [56]
  final double buttonSize;

  /// Menu button border
  /// Defaults to null
  final BoxBorder? border;

  /// Menu button box shadow
  /// Can implement an elevation style
  final List<BoxShadow>? boxShadow;

  /// Menu button inside padding
  /// Defaults to [8]
  final double padding;

  /// Menu button outside padding
  /// Can manipulate position after using alignment property
  final EdgeInsetsGeometry? margin;

  /// Statring angle in clockwise radian (Left to Right).
  /// A circle is 2 * Pi Radian.
  /// Example: [startingAngleInRadian = 0] and [endingAngleRadian = pi].
  /// This results from 9 to 3 clockwise in terms of range using a clock.
  /// You can start off with [1.25 * pi] to find your own needed values
  final double? startingAngleInRadian;

  /// Ending angle in clockwise radian (Left to Right).
  /// A circle is 2 Pi Radian.
  /// Example: startingAngleInRadian = 0 and endingAngleRadian = pi.
  /// This results from 9 to 3 clockwise in terms of range using a clock.
  /// You can start off with [1.75 * pi] to find your own needed values
  final double? endingAngleInRadian;

  /// creates a circular menu with specific [radius] and [alignment] .
  /// [boxShadow] ,[padding] which must be
  /// equal or greater than zero.
  /// [children] must not be null and must contain at least to items.
  RadialMenu({
    this.key,
    this.openIcon = const Icon(Icons.menu),
    this.closeIcon = const Icon(Icons.close),
    this.tooltip,
    required this.children,
    this.alignment = Alignment.bottomCenter,
    this.radius = 100,
    this.iconShrink = false,
    this.animationDuration = const Duration(milliseconds: 500),
    this.forwardCurve = Curves.bounceOut,
    this.reverseCurve = Curves.fastOutSlowIn,
    this.onPressed,
    this.color,
    this.border,
    this.boxShadow,
    this.padding = 8,
    this.margin,
    this.buttonSize = 56,
    this.startingAngleInRadian,
    this.endingAngleInRadian,
  })  : assert(children.length > 1, 'if you only have one item no need to use a menu'),
        super(key: key);

  @override
  RadialMenuState createState() => RadialMenuState();
}

class RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double _completeAngle;
  late double _initialAngle;
  late double _endAngle;
  late double _startAngle;
  late int _itemsCount;
  late Widget _currentIcon;
  late Animation<double> _animation;
  bool _isEnabled = true;
  bool _isOpen = false;

  @override
  void didUpdateWidget(oldWidget) {
    _configure();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _configure();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addListener(() {
        setState(() {});
      });
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.forwardCurve,
        reverseCurve: widget.reverseCurve,
      ),
    );
    _currentIcon = widget.openIcon;
    _itemsCount = widget.children.length;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin!,
      child: Stack(
        children: <Widget>[
          ..._buildMenuItems(),
          _buildMenuButton(context),
        ],
      ),
    );
  }

  /// Forward animation
  void open() {
    if (_isEnabled) {
      _changeIcon(_animationController.value);
      _animationController.forward();
      _isOpen = true;
    }
  }

  /// Reverse animation
  void close() {
    if (_isEnabled) {
      _changeIcon(_animationController.value);
      _animationController.reverse();
      _isOpen = false;
    }
  }

  bool get isEnabled => _isEnabled == true;

  bool get isOpen => _isOpen == true;

  /// Enable the animation to show the items
  void enableOpen() {
    _isEnabled = true;
  }

  /// Disable the animation to keep the items hidden.
  /// Useful when you want to execute your own function first
  /// before enabling to expand the menu.
  void disableOpen() {
    _isEnabled = false;
  }

  void _changeIcon(double value) {
    Future.delayed(
      //half of the duration. using "~" gives an int value instead of double when dividing.
      Duration(milliseconds: (widget.animationDuration.inMilliseconds ~/ 2)),
      () => setState(
        () {
          if (_isOpen) {
            //When Opened, it will change to close icon
            _currentIcon = widget.closeIcon;
          } else {
            _currentIcon = widget.openIcon;
          }
        },
      ),
    );
  }

  void _configure() {
    if (widget.startingAngleInRadian != null || widget.endingAngleInRadian != null) {
      if (widget.startingAngleInRadian == null) {
        throw ('startingAngleInRadian can not be null');
      }
      if (widget.endingAngleInRadian == null) {
        throw ('endingAngleInRadian can not be null');
      }

      if (widget.startingAngleInRadian! < 0) {
        throw 'startingAngleInRadian has to be in clockwise radian';
      }
      if (widget.endingAngleInRadian! < 0) {
        throw 'endingAngleInRadian has to be in clockwise radian';
      }
      _startAngle = (widget.startingAngleInRadian! / math.pi) % 2;
      _endAngle = (widget.endingAngleInRadian! / math.pi) % 2;
      if (_endAngle < _startAngle) {
        throw 'startingAngleInRadian can not be greater than endingAngleInRadian';
      }
      _completeAngle = _startAngle == _endAngle ? 2 * math.pi : (_endAngle - _startAngle) * math.pi;
      _initialAngle = _startAngle * math.pi;
    } else {
      switch (widget.alignment.toString()) {
        case 'bottomCenter':
          _completeAngle = 1 * math.pi;
          _initialAngle = 1 * math.pi;
          break;
        case 'topCenter':
          _completeAngle = 1 * math.pi;
          _initialAngle = 0 * math.pi;
          break;
        case 'centerLeft':
          _completeAngle = 1 * math.pi;
          _initialAngle = 1.5 * math.pi;
          break;
        case 'centerRight':
          _completeAngle = 1 * math.pi;
          _initialAngle = 0.5 * math.pi;
          break;
        case 'center':
          _completeAngle = 2 * math.pi;
          _initialAngle = 0 * math.pi;
          break;
        case 'bottomRight':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 1 * math.pi;
          break;
        case 'bottomLeft':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 1.5 * math.pi;
          break;
        case 'topLeft':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 0 * math.pi;
          break;
        case 'topRight':
          _completeAngle = 0.5 * math.pi;
          _initialAngle = 0.5 * math.pi;
          break;
        default:
          throw 'startingAngleInRadian and endingAngleInRadian can not be null';
      }
    }
  }

  List<Widget> _buildMenuItems() {
    return widget.children
        .mapIndexed((index, RadialMenuItem item) => Positioned.fill(
              child: Align(
                alignment: widget.alignment,
                child: Transform.translate(
                  offset: Offset.fromDirection(
                      _completeAngle == (2 * math.pi)
                          ? (_initialAngle + (_completeAngle / (_itemsCount)) * index)
                          : (_initialAngle + (_completeAngle / (_itemsCount - 1)) * index),
                      _animation.value * widget.radius),
                  child: Transform.scale(
                    scale: _animation.value,
                    child: Transform.rotate(
                      angle: _animation.value * (math.pi * 2),
                      child: item,
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }

  Widget _buildMenuButton(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: widget.alignment,
        child: RadialMenuItem(
          tooltip: widget.tooltip,
          size: widget.buttonSize,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (_, __) {
              return Transform.rotate(angle: _animation.value * 2.0 * math.pi, child: _currentIcon);
            },
          ),
          color: widget.color ?? Theme.of(context).primaryColor,
          padding: widget.iconShrink
              ? ((_animation.value * widget.padding * 0.5) + widget.padding)
              : ((-_animation.value * widget.padding * 0.5) + widget.padding),
          border: widget.border,
          boxShadow: widget.boxShadow,
          onTap: () {
            if (_isEnabled) {
              //0.0 means it is closed
              if (!_isOpen) {
                //When closed and tapped, it will animate to opening animation
                open();
              } else {
                close();
              }
            }
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
          },
        ),
      ),
    );
  }
}

//==================================================
class RadialMenuItem extends StatelessWidget {
  /// [child] will be used as the icon
  final Widget child;

  /// Text to display when long pressed
  final String? tooltip;

  /// Button color
  final Color? color;

  /// add your own function
  final VoidCallback? onTap;

  /// button size
  final double size;

  /// button padding
  final double padding;

  /// custom border;
  final BoxBorder? border;

  /// boxshadow
  final List<BoxShadow>? boxShadow;

  /// creates a menu item .
  /// [child] must not be null.
  /// [padding] must be equal or greater than zero.
  RadialMenuItem({
    this.onTap,
    required this.child,
    this.tooltip,
    this.color,
    this.size = 35,
    this.border,
    this.boxShadow,
    this.padding = 0,
  }) : assert(padding >= 0.0);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip!,
      child: ClipOval(
        child: Material(
          child: InkWell(
            onTap: onTap ?? () {},
            child: Ink(
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: border,
                boxShadow: boxShadow ?? null,
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: SizedBox.expand(child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}