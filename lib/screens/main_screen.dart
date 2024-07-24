import 'dart:async';
import 'package:animations/animations.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/screens/guides_screen.dart';
import 'package:cadence_mtb/screens/home_screen.dart';
import 'package:cadence_mtb/screens/login_screen.dart';
import 'package:cadence_mtb/screens/profile_screen.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  late List<Widget> _pages;
  late Future _futureHolder;

  @override
  void initState() {
    super.initState();
    _futureHolder = _openBikeActivitiesBox();
    _pages = [HomeScreen(key: _homeKey), GuidesScreen()];
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (FunctionHelper.isFirstRun) {
        Map<Permission, PermissionStatus> statuses =
            await AppPermissions.requestAllPermissions();
        if (statuses.containsValue(PermissionStatus.denied)) {
          CustomToast.showToastDenied(
            context: context,
            requestText:
                'CadenceMTB requires permissions for the features to work properly.',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool _isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final Size _size = MediaQuery.of(context).size;
    final bool _inHomeScreen = _currentIndex.value == 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF496D47),
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
            canvasColor: Color(0xFF496D47),
            textTheme: TextTheme(
              titleMedium: TextStyle(
                fontFamily: 'Comfortaa',
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            unselectedWidgetColor: Colors.black,
            dividerColor: Colors.white,
          ),
          child: SizedBox(
            width: _size.width * 0.50,
            child: Drawer(
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: AvatarBox(code: currentUser!.avatarCode, size: 100),
                  ),
                  Text(
                    currentUser!.profileName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Profile'),
                    onTap: () {
                      showModal(
                        context: context,
                        configuration: FadeScaleTransitionConfiguration(
                            barrierDismissible: false),
                        builder: (_) => PinCodeScreen(
                          user: currentUser!,
                          onCorrect: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              CustomRoutes.fadeThrough(
                                page: ProfileScreen(
                                  profile: currentUser!,
                                ),
                              ),
                            ).then((value) {
                              setState(() {});
                            });
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Log out'),
                    onTap: () {
                      StorageHelper.setBool('isLoggedIn', false);
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CustomRoutes.fadeThrough(page: LoginScreen()),
                          (route) => false,
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Exit App'),
                    onTap: () {
                      showModal(
                        context: context,
                        configuration: FadeScaleTransitionConfiguration(
                            barrierDismissible: true),
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black.withOpacity(0.6),
                          body: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Are you sure you want to exit?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      child: Text('Yes'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Color(0xFF496D47),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        SystemNavigator.pop();
                                      },
                                    ),
                                    SizedBox(width: 50),
                                    TextButton(
                                      child: Text('No'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Color(0xFF496D47),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: FutureBuilder(
              future: _futureHolder,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return PageView(
                      controller: _pageController,
                      pageSnapping: true,
                      scrollDirection: Axis.horizontal,
                      children: _pages,
                      onPageChanged: (pageIndex) {
                        setState(() {
                          _currentIndex.value = pageIndex;
                        });
                      },
                    );

                  default:
                    return SizedBox.shrink();
                }
              }),
        ),
        //FAB
        floatingActionButton: _isPortrait
            ? EmergencyButton()
            : DraggableFab(
                child: EmergencyButton(),
                securityBottom: 20,
              ),
        floatingActionButtonLocation:
            _isPortrait ? FloatingActionButtonLocation.centerDocked : null,
        //BOTTOM NAV BAR
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.transparent, boxShadow: [
            BoxShadow(
                blurRadius: 10,
                color: Theme.of(context).scaffoldBackgroundColor.darken(0.5),
                offset: Offset(0, -1)),
          ]),
          child: BottomAppBar(
            elevation: 0,
            color: Theme.of(context).scaffoldBackgroundColor,
            notchMargin: 2,
            shape: const CircularNotchedRectangle(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (_, pageIndex, __) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 50,
                          child: Center(
                            child: AnimatedContainer(
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 300),
                              width: _inHomeScreen ? 32 : 0,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _inHomeScreen
                                    ? Color(0xFF496D47)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 50,
                          child: Center(
                            child: AnimatedContainer(
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 300),
                              width: !_inHomeScreen ? 32 : 0,
                              height: 5,
                              decoration: BoxDecoration(
                                color: !_inHomeScreen
                                    ? Color(0xFF496D47)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/home_dashboard/home.svg',
                        height: 32,
                        width: 32,
                        colorFilter: ColorFilter.mode(
                          _inHomeScreen ? Color(0xFF496D47) : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      splashColor: Color(0xFF496D47).withOpacity(0.8),
                      highlightColor: Colors.transparent,
                      onPressed: _inHomeScreen
                          ? null
                          : () {
                              _pageController.animateToPage(0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            },
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                          'assets/icons/guides_dashboard/guides_and_manuals.svg',
                          height: 32,
                          width: 32,
                          colorFilter: ColorFilter.mode(
                            !_inHomeScreen ? Color(0xFF496D47) : Colors.grey,
                            BlendMode.srcIn,
                          )),
                      splashColor: Color(0xFF496D47).withOpacity(0.8),
                      highlightColor: Colors.transparent,
                      onPressed: !_inHomeScreen
                          ? null
                          : () {
                              _homeKey.currentState!.closePanel();
                              _pageController.animateToPage(1,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Box> _openBikeActivitiesBox() async {
    return await Hive.openBox<BikeActivity>(
        '${currentUser!.profileNumber}bikeActivities');
  }
}
