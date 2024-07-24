import 'dart:math';
import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:cadence_mtb/data/data.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/screens/main_screen.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
part 'login_screen/delete_profile.dart';
part 'login_screen/user_form.dart';
part 'login_screen/pin_code_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF496D47),
          statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 50),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Image.asset(
                    'assets/icons/final_app_icon.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                FutureBuilder<List<UserProfile>>(
                  future: getProfiles(),
                  builder: (_, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text('Failed to fetch users');
                        } else {
                          return ListView.separated(
                            separatorBuilder: (_, index) {
                              return SizedBox(height: 5);
                            },
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length + 1,
                            itemBuilder: (_, index) {
                              List<UserProfile> profileList = snapshot.data!;
                              if (index == 0) {
                                return Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Color(0xFF496D47), width: 2),
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.person_add),
                                    title: Text(
                                      'Create New Profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    onTap: () {
                                      if (snapshot.data!.length >= 5) {
                                        CustomToast.showToastSimple(
                                            context: context,
                                            simpleMessage:
                                                'Number of Profile Limit Reached');
                                        return;
                                      } else {
                                        showModal(
                                          context: context,
                                          configuration:
                                              FadeScaleTransitionConfiguration(
                                                  barrierDismissible: false),
                                          builder: (_) {
                                            return PopScope(
                                              canPop: false,
                                              child: UserForm(
                                                onSave: (profile) {
                                                  if (profileList.isEmpty) {
                                                    profileList.add(profile);
                                                    StorageHelper.setStringList(
                                                        'userProfiles',
                                                        profileList
                                                            .map((e) =>
                                                                e.toJson())
                                                            .toList());
                                                    Navigator.pop(
                                                        context, true);
                                                  } else {
                                                    if (profileList
                                                        .map((e) => e
                                                            .profileName
                                                            .toLowerCase()
                                                            .replaceAll(
                                                                ' ', ''))
                                                        .contains(profile
                                                            .profileName
                                                            .toLowerCase()
                                                            .replaceAll(
                                                                ' ', ''))) {
                                                      CustomToast.showToastSimple(
                                                          context: context,
                                                          simpleMessage:
                                                              'Profile Name Already Exist');
                                                      return;
                                                    } else {
                                                      profileList.add(profile);
                                                      StorageHelper
                                                          .setStringList(
                                                              'userProfiles',
                                                              profileList
                                                                  .map((e) => e
                                                                      .toJson())
                                                                  .toList());
                                                      Navigator.pop(
                                                          context, true);
                                                    }
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ).then((value) {
                                          if (value == true) {
                                            setState(() {});
                                          }
                                        });
                                      }
                                    },
                                  ),
                                );
                              } else {
                                return Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Color(0xFF496D47), width: 2),
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text(
                                      snapshot.data![index - 1].profileName,
                                      style: TextStyle(
                                        color: Color(0xFF496D47),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_forever_rounded),
                                      onPressed: () {
                                        showModal<bool>(
                                          context: context,
                                          configuration:
                                              FadeScaleTransitionConfiguration(
                                                  barrierDismissible: true),
                                          builder: (_) {
                                            return AlertDialog(
                                              content: Text(
                                                  'Are you sure you want to delete the profile "${snapshot.data![index - 1].profileName}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                  child: Text('Yes'),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Color(0xFF496D47),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, false);
                                                  },
                                                  child: Text('No'),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Color(0xFF496D47),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).then((result) async {
                                          //Deleting Profile Data
                                          if (result == true) {
                                            int realIndex = index - 1;
                                            deleteProfile(
                                                snapshot.data!, realIndex);
                                          }
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      showModal(
                                        context: context,
                                        configuration:
                                            FadeScaleTransitionConfiguration(
                                                barrierDismissible: false),
                                        builder: (_) => PinCodeScreen(
                                          user: snapshot.data![index - 1],
                                          onCorrect: () {
                                            currentUser =
                                                snapshot.data![index - 1];
                                            StorageHelper.setBool(
                                                'isLoggedIn', true);
                                            StorageHelper.setInt('lastUser',
                                                currentUser!.profileNumber);
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                              (timeStamp) {
                                                final ThemeProvider
                                                    _themeProvider =
                                                    Provider.of<ThemeProvider>(
                                                        context,
                                                        listen: false);
                                                _themeProvider.selectTheme(
                                                    StorageHelper.getInt(
                                                            '${currentUser!.profileNumber}appTheme') ??
                                                        1);
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  CustomRoutes.fadeThrough(
                                                      page: MainScreen()),
                                                  (route) => false,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        }
                      default:
                        return SpinKitChasingDots(
                          color: Color(0xFF496D47),
                        );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<UserProfile>> getProfiles() async {
    List<String> profilesJson =
        StorageHelper.getStringList('userProfiles') ?? [];
    if (profilesJson.isNotEmpty) {
      return profilesJson.map((e) => UserProfile.fromJson(e)).toList();
    } else {
      return []; //List<UserPro>
    }
  }

  void deleteProfile(List<UserProfile> profiles, int index) {
    int profileNumber = profiles[index].profileNumber;
    final GlobalKey deleteStatusKey = GlobalKey();
    showModal(
      context: context,
      configuration:
          FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (_) {
        return DeleteProfile(
          key: deleteStatusKey,
        );
      },
    ).then((value) => getProfiles().then((value) => setState(() {})));
    Future.wait([
      Hive.openBox<BikeActivity>('${profileNumber}bikeActivities'),
      Hive.openBox<BMIData>('${profileNumber}bmiActivities')
    ]).then((value) {
      Hive.box<BikeActivity>('${profileNumber}bikeActivities').deleteFromDisk();
      Hive.box<BMIData>('${profileNumber}bmiActivities').deleteFromDisk();
      theTwoEssentials.forEachIndexed(
        (index, item) =>
            StorageHelper.remove('${profileNumber}theTwoEssentials$index'),
      );
      coreGear.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}coreGear$index'),
      );
      coreRepairItems.forEachIndexed(
        (index, item) =>
            StorageHelper.remove('${profileNumber}coreRepairItems$index'),
      );
      clothing.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}clothing$index'),
      );
      gearOptions.forEachIndexed(
        (index, item) =>
            StorageHelper.remove('${profileNumber}gearOptions$index'),
      );
      repairKitOptions.forEachIndexed(
        (index, item) =>
            StorageHelper.remove('${profileNumber}repairKitOptions$index'),
      );
      freeRidingGear.forEachIndexed(
        (index, item) =>
            StorageHelper.remove('${profileNumber}freeRidingGear$index'),
      );
      personal.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}personal$index'),
      );
      Future.wait([
        StorageHelper.remove('${profileNumber}appTheme'),
        StorageHelper.remove('${profileNumber}massUnit'),
        StorageHelper.remove('${profileNumber}userWeight'),
        StorageHelper.remove('${profileNumber}borderWidth'),
        StorageHelper.remove('${profileNumber}lineWidth'),
        StorageHelper.remove('${profileNumber}bikeProjects'),
        StorageHelper.remove('${profileNumber}locationAccuracy'),
        StorageHelper.remove('${profileNumber}distanceFilter'),
        StorageHelper.remove('${profileNumber}formula'),
        StorageHelper.remove('${profileNumber}locationAccuracy'),
        StorageHelper.remove('${profileNumber}distanceFilter'),
        StorageHelper.remove('${profileNumber}lineWidth'),
        StorageHelper.remove('${profileNumber}borderWidth'),
        StorageHelper.remove('${profileNumber}includeBorder'),
        StorageHelper.remove('${profileNumber}sosContacts'),
        StorageHelper.remove('${profileNumber}sosMessage'),
        StorageHelper.remove('${profileNumber}appendLocation'),
        StorageHelper.remove('${profileNumber}trails'),
        StorageHelper.remove('${profileNumber}navigate'),
        StorageHelper.remove('${profileNumber}bikeproject'),
        StorageHelper.remove('${profileNumber}firstaid'),
        StorageHelper.remove('${profileNumber}preparation'),
        StorageHelper.remove('${profileNumber}bodyconditioning'),
        StorageHelper.remove('${profileNumber}repairandmaintenance'),
        StorageHelper.remove('${profileNumber}tipsandbenefits'),
        StorageHelper.remove('${profileNumber}organizations'),
        StorageHelper.remove('${profileNumber}useractivitypage'),
        StorageHelper.remove('${profileNumber}haveSOSDetails'),
      ]).then((value) {
        List<UserProfile> modifiedProfiles = [];
        modifiedProfiles.addAll(profiles);
        modifiedProfiles
            .removeWhere((element) => element.profileNumber == profileNumber);
        StorageHelper.setStringList(
            'userProfiles', modifiedProfiles.map((e) => e.toJson()).toList());
        Navigator.pop(deleteStatusKey.currentContext!);
      });
    });
  }
}
