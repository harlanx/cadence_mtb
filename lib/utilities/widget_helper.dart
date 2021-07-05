
library widget_helper;
import 'dart:math' as math;
import 'package:animations/animations.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
export 'package:cadence_mtb/utilities/custom_widgets/custom_widgets.dart';

///Class Provider for our App Theme Modes
class ThemeProvider extends ChangeNotifier {
  //Default
  ThemeMode themeMode = ThemeMode.system;

  void loadTheme() {
    int? theme = currentUser != null ? StorageHelper.getInt('${currentUser!.profileNumber}appTheme') ?? 1 : 1;
    //Android versions lower than 10.0 have Thememode.system that defaults only to ThemeMode.light;
    if (theme == 1) {
      themeMode = ThemeMode.system;
    } else if (theme == 2) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
  }

  void selectTheme(int theme) {
    if (theme == 1) {
      themeMode = ThemeMode.system;
    } else if (theme == 2) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  ThemeMode get currentTheme => themeMode;
}

///The current properties in the ThemeData are the only ones currently used in the whole app.
///Configure (add or remove) more properties if needed.
class AppThemes {
  static ThemeData get lightMode {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Comfortaa',
      accentColor: Color(0xFF496D47),
      appBarTheme: AppBarTheme(
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      primaryColor: Colors.white,
      primarySwatch: MaterialColor(0xFF496D47, <int, Color>{
        50: Color(0xFF496D47).brighten(0.5),
        100: Color(0xFF496D47).brighten(0.4),
        200: Color(0xFF496D47).brighten(0.3),
        300: Color(0xFF496D47).brighten(0.2),
        400: Color(0xFF496D47).brighten(0.1),
        500: Color(0xFF496D47),
        600: Color(0xFF496D47).darken(0.1),
        700: Color(0xFF496D47).darken(0.2),
        800: Color(0xFF496D47).darken(0.3),
        900: Color(0xFF496D47).darken(0.4),
      }),
      colorScheme: ColorScheme.light(),
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        bodyText2: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        caption: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade600),
        subtitle1: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }

  static ThemeData get darkMode {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Comfortaa',
      accentColor: Color(0xFF496D47),
      appBarTheme: AppBarTheme(
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      primaryColor: Colors.black,
      primarySwatch: MaterialColor(0xFF496D47, <int, Color>{
        50: Color(0xFF496D47).brighten(0.5),
        100: Color(0xFF496D47).brighten(0.4),
        200: Color(0xFF496D47).brighten(0.3),
        300: Color(0xFF496D47).brighten(0.2),
        400: Color(0xFF496D47).brighten(0.1),
        500: Color(0xFF496D47),
        600: Color(0xFF496D47).darken(0.1),
        700: Color(0xFF496D47).darken(0.2),
        800: Color(0xFF496D47).darken(0.3),
        900: Color(0xFF496D47).darken(0.4),
      }),
      colorScheme: ColorScheme.dark(),
      scaffoldBackgroundColor: Colors.grey.shade900,
      textTheme: TextTheme(
        bodyText2: TextStyle(color: Colors.white),
        caption: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade400),
        subtitle1: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        headline6: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
      ),
    );
  }
}


//=======================================================================
class CustomRoutes {
  static Route<T> fadeThrough<T>({required Widget page, Duration duration = const Duration(milliseconds: 300)}) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  static Route<T> fadeScale<T>({required Widget page, Duration duration = const Duration(milliseconds: 300)}) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> sharedAxis<T>(
      {required Widget page,
      SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
      Duration duration = const Duration(milliseconds: 300)}) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
        );
      },
    );
  }
}

//=======================================================================
//Avatar Painter
class AvatarPainter extends CustomPainter {
  AvatarPainter(this.svg, [this.size = const Size(50, 50)]);

  final DrawableRoot svg;
  final Size size;
  @override
  void paint(Canvas canvas, Size size) {
    svg.scaleCanvasToViewBox(canvas, size);
    svg.clipCanvasToViewBox(canvas);
    svg.draw(canvas, Rect.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SvgWrapper {
  final String rawSvg;

  SvgWrapper(this.rawSvg);

  Future<DrawableRoot?> generateLogo() async {
    try {
      return await svg.fromSvgString(rawSvg, rawSvg);
    } catch (e) {
      Future.error(e);
    }
  }
}

//==================================================
///Custom toast (snackbar) with [BuildContext] using [FToast] package.
class CustomToast {
  /* IF WE WERE TO NAME THIS METHOD AS "_showToastPermanentlyDenied"
  WE CAN'T ACCESS IT TO A DIFFERENT DART FILE EVEN IF IT IS IMPORTED.
  CustomToast.showToastPermanentlyDenied(properties) [o]This will work in any .dart file if its imported.
  CustomToast._showToastPermanentlyDenied(properties) [o]This will work on the same .dart file where it was written.
  CustomToast._showToastPermanentlyDenied(properties) [x]This will not work on any(except itself) .dart file even if widget_helper.dart is imported.
  THE REASON IS DART USES "_" UNDERSCORE OR WITHOUT UNDERSCORE TO SPEFICY IF IT'S PUBLIC OR PRIVATE VARIABLE, OBJECT OR METHOD.
  IF IT IS SPECIFIED WITH "_" UNDERSCORE AT THE BEGINNING, IT MEANS IT IS PRIVATE TO THAT SPECIFIC .dart FILE. */
  static showToastPermanentlyDenied({required BuildContext context, required String requestText}) {
    final FToast ftoast = FToast();
    ftoast.init(context);
    ftoast.removeCustomToast();
    ftoast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 8),
      child: GestureDetector(
        onTap: () {
          openAppSettings();
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text.rich(
            TextSpan(children: <InlineSpan>[
              TextSpan(
                text: requestText,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ]),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  static showToastDenied({required BuildContext context, required String requestText}) {
    final FToast ftoast = FToast();
    ftoast.init(context);
    ftoast.removeCustomToast();
    ftoast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text.rich(
          TextSpan(children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.priority_high_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            TextSpan(
              text: requestText,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static showToastSetupAction(BuildContext context, String actionResultText, bool success) {
    final FToast ftoast = FToast();
    ftoast.init(context);
    ftoast.removeCustomToast();
    ftoast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text.rich(
          TextSpan(children: <InlineSpan>[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                success ? Icons.check : Icons.cancel_outlined,
                color: Colors.white,
                size: 15,
              ),
            ),
            TextSpan(
              text: actionResultText,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static showToastSimple({
    required BuildContext context,
    required String simpleMessage,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Duration duration = const Duration(seconds: 1),
  }) {
    final FToast ftoast = FToast();
    ftoast.init(context);
    ftoast.removeCustomToast();
    ftoast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          simpleMessage,
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

//==================================================
///Map for showing/hiding SOS button in pages.
Map<String, bool?> sosEnabled = {
  'Trails': StorageHelper.getBool('${currentUser!.profileNumber}trails') ?? true,
  'Navigate': StorageHelper.getBool('${currentUser!.profileNumber}navigate') ?? true,
  'Bike Project': StorageHelper.getBool('${currentUser!.profileNumber}bikeproject') ?? true,
  'First Aid': StorageHelper.getBool('${currentUser!.profileNumber}firstaid') ?? true,
  'Preparation': StorageHelper.getBool('${currentUser!.profileNumber}preparation') ?? true,
  'Body Conditioning': StorageHelper.getBool('${currentUser!.profileNumber}bodyconditioning') ?? true,
  'Repair and Maintenance': StorageHelper.getBool('${currentUser!.profileNumber}repairandmaintenance') ?? true,
  'Tips and Benefits': StorageHelper.getBool('${currentUser!.profileNumber}tipsandbenefits') ?? true,
  'Organizations': StorageHelper.getBool('${currentUser!.profileNumber}organizations') ?? true,
  'User Activity': StorageHelper.getBool('${currentUser!.profileNumber}useractivitypage') ?? true,
};

//==================================================
extension ColorUtil on Color {
  ///Darkens the color.
  ///Percent must be in between 0.0 to 1.0.
  ///Defaults to 0.1.
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  ///Lightens the color.
  ///Percent must be in between 0.0 to 1.0.
  ///Defaults to 10.
  Color brighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static Color get random => Color((math.Random().nextDouble() * 0xFFFFFF).toInt());
}