import 'package:cadence_mtb/models/bike_activity.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/models/bmi_data.dart';
import 'package:cadence_mtb/screens/login_screen.dart';
import 'package:cadence_mtb/screens/main_screen.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

//Note: I Infer not to use var and dynamic in my codes to make the understandability easier.
//I only use var and dynamic during debugging. Use object.runtimeType to check what kind of
//object type it is so you can make it a strong type variable.
void main() async {
  //We need this to be called so we can initialize our storage helper and other asynchronous methods
  WidgetsFlutterBinding.ensureInitialized();
  //StorageHelper (SharedPreferences Singleton).
  await StorageHelper.init();
  //Hive NoSQL Database (Good for small apps. For larger apps with above 10K items in a list should use SQLite instead)
  await Hive.initFlutter();
  //Register your custom adapters first before opening any boxes.
  Hive.registerAdapter(BikeActivityAdapter());
  Hive.registerAdapter(BMIDataAdapter());
  Hive.registerAdapter(WeatherAdapter());
  Hive.registerAdapter(LatLngAdapter());
  Hive.registerAdapter(LatLngBoundsAdapter());
  /* This sets a system wide status bar color */
  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47)));
  /* This hides status bar at the top. (Not recommended. Don't prevent your user from acessing their status bar unless really necessary.)
  Although they can swipe down the status bar. It doesn't automatically hide when theres no more activity happening with status bar and when the 
  Scaffold is wrapped in SafeArea with primary: false. Leave it enabled. */
  //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  /* This sets the orientation this app can rotate to. (Exception: DeviceOrientation.portraitDown) */
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  /* This opens that status bar at the top. */
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  /* Run the app
  NOTE: Don't worry about the frames skipped during startup (mostly, emulator or older phones encounter this).
  It may vary depending on the objects you initialize in the startup. If you are not doing any unnecessesary
  functions then you can ignore the warning.
  Worry if it happened after the app is fully loaded or during user interaction. (e.g: page navigation)
  Use Dart DevTools to find out what may be causing the low frame rate or if there's any memory leak.
  NOTE: You can only monitor frames performance in --profile mode using real device or using emulator with any architecture except x86 */
  runApp(
    //Provider used as the state management for themes.
    //Would be great to migrate into BLoC pattern with Provider or GetX as the overall state manager.
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        //Load user saved theme preference.
        if (FunctionHelper.isLoggedIn) {
          List<UserProfile> userProfiles = StorageHelper.getStringList('userProfiles')!.map((e) => UserProfile.fromJson(e)).toList();
          currentUser = userProfiles.singleWhere((element) => element.profileNumber == StorageHelper.getInt('lastUser'));
        }
        Provider.of<ThemeProvider>(context, listen: false).loadTheme();
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Instance of the Notifier class we made.
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      //App title to show when Overview(Tasks) button in android device is pressed.
      title: 'Cadence MTB',
      theme: AppThemes.lightMode,
      darkTheme: AppThemes.darkMode,
      themeMode: themeProvider.themeMode,
      home: FunctionHelper.isLoggedIn ? MainScreen() : LoginScreen(),
      /* Disables debug label banner on the top right when running on debug mode.
      This is not included when building for release or profile mode whether its true or false. */
      debugShowCheckedModeBanner: false,
    );
  }
}
