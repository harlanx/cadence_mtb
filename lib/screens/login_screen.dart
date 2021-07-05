import 'dart:math';
import 'package:animations/animations.dart';
import 'package:cadence_mtb/models/bike_activity.dart';
import 'package:cadence_mtb/models/bmi_data.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/pages/preparation.dart';
import 'package:cadence_mtb/screens/main_screen.dart';
import 'package:collection/collection.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
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
                                    border: Border.all(color: Color(0xFF496D47), width: 2),
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
                                        CustomToast.showToastSimple(context: context, simpleMessage: 'Number of Profile Limit Reached');
                                        return;
                                      } else {
                                        showModal(
                                          context: context,
                                          configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
                                          builder: (_) {
                                            return WillPopScope(
                                              onWillPop: () => Future.value(false),
                                              child: UserForm(
                                                onSave: (profile) {
                                                  if (profileList.isEmpty) {
                                                    profileList.add(profile);
                                                    StorageHelper.setStringList('userProfiles', profileList.map((e) => e.toJson()).toList());
                                                    Navigator.pop(context, true);
                                                  } else {
                                                    if (profileList
                                                        .map((e) => e.profileName.toLowerCase().replaceAll(' ', ''))
                                                        .contains(profile.profileName.toLowerCase().replaceAll(' ', ''))) {
                                                      CustomToast.showToastSimple(context: context, simpleMessage: 'Profile Name Already Exist');
                                                      return;
                                                    } else {
                                                      profileList.add(profile);
                                                      StorageHelper.setStringList('userProfiles', profileList.map((e) => e.toJson()).toList());
                                                      Navigator.pop(context, true);
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
                                    border: Border.all(color: Color(0xFF496D47), width: 2),
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
                                          configuration: FadeScaleTransitionConfiguration(barrierDismissible: true),
                                          builder: (_) {
                                            return AlertDialog(
                                              content: Text('Are you sure you want to delete "${snapshot.data![index - 1].profileName}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context, true);
                                                  },
                                                  child: Text('Yes'),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Color(0xFF496D47),
                                                    primary: Colors.white,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context, false);
                                                  },
                                                  child: Text('No'),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Color(0xFF496D47),
                                                    primary: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).then((result) async {
                                          //Deleting Profile Data
                                          if (result == true) {
                                            int realIndex = index - 1;
                                            deleteProfile(snapshot.data!, realIndex);
                                          }
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      showModal(
                                        context: context,
                                        configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
                                        builder: (_) => PinCodeScreen(
                                          user: snapshot.data![index - 1],
                                          onCorrect: () {
                                            currentUser = snapshot.data![index - 1];
                                            StorageHelper.setBool('isLoggedIn', true);
                                            StorageHelper.setInt('lastUser', currentUser!.profileNumber);
                                            WidgetsBinding.instance!.addPostFrameCallback(
                                              (timeStamp) {
                                                final ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                                _themeProvider.selectTheme(StorageHelper.getInt('${currentUser!.profileNumber}appTheme') ?? 1);
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  CustomRoutes.fadeThrough(page: MainScreen()),
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
    List<String> profilesJson = StorageHelper.getStringList('userProfiles') ?? [];
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
      configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: (_) {
        return DeleteProfile(
          key: deleteStatusKey,
        );
      },
    ).then((value) => getProfiles().then((value) => setState(() {})));
    Future.wait([Hive.openBox<BikeActivity>('${profileNumber}bikeActivities'), Hive.openBox<BMIData>('${profileNumber}bmiActivities')]).then((value) {
      Hive.box<BikeActivity>('${profileNumber}bikeActivities').deleteFromDisk();
      Hive.box<BMIData>('${profileNumber}bmiActivities').deleteFromDisk();
      theTwoEssentials.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}theTwoEssentials$index'),
      );
      coreGear.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}coreGear$index'),
      );
      coreRepairItems.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}coreRepairItems$index'),
      );
      clothing.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}clothing$index'),
      );
      gearOptions.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}gearOptions$index'),
      );
      repairKitOptions.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}repairKitOptions$index'),
      );
      freeRidingGear.forEachIndexed(
        (index, item) => StorageHelper.remove('${profileNumber}freeRidingGear$index'),
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
        modifiedProfiles.removeWhere((element) => element.profileNumber == profileNumber);
        StorageHelper.setStringList('userProfiles', modifiedProfiles.map((e) => e.toJson()).toList());
        Navigator.pop(deleteStatusKey.currentContext!);
      });
    });
  }
}

class DeleteProfile extends StatelessWidget {
  DeleteProfile({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Deleting profile data, please wait.'),
          SpinKitCircle(
            color: Color(0xFF496D47),
          ),
        ],
      ),
    );
  }
}

typedef void UserFormCallback(UserProfile profile);

class UserForm extends StatefulWidget {
  final UserFormCallback? onSave;
  final Function? onClear;
  final Function? onCancel;
  UserForm({
    this.onSave,
    this.onClear,
    this.onCancel,
    Key? key,
  }) : super(key: key);
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController profileNameController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController pinCodeConfirmController = TextEditingController();
  DrawableRoot? svgRoot;
  /* Sample Male Generated
  [074142121646,303028311032,334606193403,111500050820,253039420134,
  224311353805,193035190836,370228202837,131515101046, 141243361946]
  */
  /* Sample Female Generated
  [453227222305,030511162938,452414341004,243936323502,184543041205,
  433008022415,404120071328,313707260414,071509430901,224545463244]
  */
  //It needs 6 of double digits from 01 to 47
  //Max is 474747474747
  String rawAvatarCode = List.generate(6, (_) => Random().nextInt(48).toString().padLeft(2, '0')).join();
  late String avatarCode;
  int? pinCodeHolder;

  @override
  void initState() {
    super.initState();
    avatarCode = multiavatar(rawAvatarCode);
    generateAvatar();
  }

  @override
  void dispose() {
    profileNameController.dispose();
    pinCodeController.dispose();
    pinCodeConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        buttonBarTheme: ButtonBarThemeData(
          alignment: MainAxisAlignment.center,
        ),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 10),
        contentPadding: EdgeInsets.all(10),
        actions: [
          TextButton(
            child: Text('Save'),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF496D47),
              primary: Colors.white,
            ),
            onPressed: () {
              if ((profileNameController.value.text.isEmpty || pinCodeController.value.text.isEmpty || pinCodeConfirmController.value.text.isEmpty) ||
                  pinCodeController.value.text != pinCodeConfirmController.value.text) {
                formKey.currentState!.validate();
                return;
              } else {
                if (widget.onSave != null) {
                  int curProfNum = StorageHelper.getInt('curProfNum') ?? 1;
                  widget.onSave!(UserProfile(
                    profileNumber: curProfNum,
                    avatarCode: rawAvatarCode,
                    profileName: profileNameController.value.text,
                    pinCode: pinCodeController.value.text,
                  ));
                  StorageHelper.setInt('curProfNum', curProfNum + 1);
                }
              }
            },
          ),
          TextButton(
            child: Text('Clear'),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF496D47),
              primary: Colors.white,
            ),
            onPressed: () {
              if (widget.onClear != null) {
                widget.onClear!();
              }
              formKey.currentState!.reset();
              pinCodeController.clear();
              pinCodeConfirmController.clear();
            },
          ),
          TextButton(
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF496D47),
              primary: Colors.white,
            ),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
              }
              Navigator.pop(context, false);
            },
          ),
        ],
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Create New Profile',
                  style: TextStyle(
                    color: Color(0xFF496D47),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100.0,
                      width: 100.0,
                      child: svgRoot == null
                          ? SizedBox.shrink()
                          : CustomPaint(
                              foregroundPainter: AvatarPainter(svgRoot!, Size(50.0, 50.0)),
                              child: Container(),
                            ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        rawAvatarCode = List.generate(6, (_) => Random().nextInt(48).toString().padLeft(2, '0')).join();
                        //print(rawAvatarCode);
                        avatarCode = multiavatar(rawAvatarCode);
                        generateAvatar();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: profileNameController,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    isDense: true,
                    alignLabelWithHint: true,
                    labelText: 'Profile Name',
                    labelStyle: TextStyle(
                      color: Color(0xFF496D47),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    hintText: 'Type in your profile name.',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF496D47),
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 11.0,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Pin Code',
                  style: TextStyle(
                    color: Color(0xFF496D47),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                PinCodeTextField(
                  autoDisposeControllers: false,
                  controller: pinCodeController,
                  backgroundColor: Colors.transparent,
                  blinkWhenObscuring: true,
                  keyboardType: TextInputType.number,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  animationType: AnimationType.scale,
                  obscureText: true,
                  obscuringWidget: SvgPicture.asset(
                    'assets/images/navigate/wheel.svg',
                    fit: BoxFit.contain,
                    color: Color(0xFF496D47),
                  ),
                  textStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  ),
                  pinTheme: PinTheme(
                    activeColor: Color(0xFF496D47),
                    inactiveColor: Colors.grey,
                    selectedColor: Color(0xFF496D47),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  appContext: context,
                  length: 4,
                  onChanged: (value) {
                    pinCodeHolder = int.tryParse(value);
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Confirm Pin Code',
                  style: TextStyle(
                    color: Color(0xFF496D47),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                PinCodeTextField(
                  autoDisposeControllers: false,
                  controller: pinCodeConfirmController,
                  backgroundColor: Colors.transparent,
                  blinkWhenObscuring: true,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.scale,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  obscureText: true,
                  obscuringWidget: SvgPicture.asset(
                    'assets/images/navigate/wheel.svg',
                    fit: BoxFit.contain,
                    color: Color(0xFF496D47),
                  ),
                  textStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                  ),
                  pinTheme: PinTheme(
                    activeColor: Color(0xFF496D47),
                    inactiveColor: Colors.grey,
                    selectedColor: Color(0xFF496D47),
                  ),
                  validator: (value) {
                    if (int.tryParse(value!) != pinCodeHolder) {
                      return 'Pin code does not match';
                    }
                    return null;
                  },
                  appContext: context,
                  length: 4,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  generateAvatar() async {
    return SvgWrapper(avatarCode).generateLogo().then((value) {
      setState(() {
        svgRoot = value;
      });
    });
  }
}

class PinCodeScreen extends StatefulWidget {
  final UserProfile user;
  final Function? onCorrect;
  final Function? onWrong;
  PinCodeScreen({required this.user, this.onCorrect, this.onWrong});
  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final TextEditingController pinController = TextEditingController();
  bool isPinCodeWrong = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Color(0xFF496D47),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type your pin to enter',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF496D47),
              ),
            ),
            PinCodeTextField(
              autoDisposeControllers: false,
              controller: pinController,
              keyboardType: TextInputType.number,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              backgroundColor: Colors.transparent,
              animationType: AnimationType.scale,
              obscureText: true,
              obscuringWidget: SvgPicture.asset(
                'assets/images/navigate/wheel.svg',
                fit: BoxFit.contain,
                color: Color(0xFF496D47),
              ),
              pinTheme: PinTheme(
                activeColor: Color(0xFF496D47),
                inactiveColor: Colors.grey,
                selectedColor: Color(0xFF496D47),
              ),
              appContext: context,
              length: 4,
              onChanged: (value) async {
                if (value.length >= 4) {
                  if (value == widget.user.pinCode) {
                    if (widget.onCorrect != null) {
                      widget.onCorrect!();
                    }
                  } else {
                    if (widget.onWrong != null) {
                      widget.onWrong!();
                    }
                    setState(() {
                      isPinCodeWrong = true;
                    });
                  }
                } else {
                  if (widget.onWrong != null) {
                    widget.onWrong!();
                  }
                  setState(() {
                    isPinCodeWrong = false;
                  });
                }
              },
            ),
            Visibility(
              visible: isPinCodeWrong,
              child: Text(
                'Wrong Pin Code',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
