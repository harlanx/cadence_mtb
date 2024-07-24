import 'dart:math' as math;
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  ProfileScreen({required this.profile});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //Disposing controllers in dialogs is not required since it is disposed either way by the dialog itself.
  final TextEditingController profileNameController = TextEditingController();
  String avatarCode = '';
  late UserProfile userProfile;
  bool changePin = true;
  String newPin = '';
  String newPinConfirm = '';

  @override
  void initState() {
    super.initState();
    avatarCode = widget.profile.avatarCode;
    userProfile = widget.profile;
    profileNameController.text = userProfile.profileName;
  }

  @override
  void dispose() {
    profileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF496D47),
          statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              'Update Profile',
              style: TextStyle(
                color: Color(0xFF496D47),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Color(0xFF496D47),
            ),
          ),
          body: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        'Avatar',
                        style: TextStyle(
                          color: Color(0xFF496D47),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: AvatarBox(code: avatarCode, size: 50),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            avatarCode = List.generate(
                                6,
                                (_) => math.Random()
                                    .nextInt(48)
                                    .toString()
                                    .padLeft(2, '0')).join();
                          });
                        },
                      ),
                      Text(
                        'Profile Name',
                        style: TextStyle(
                          color: Color(0xFF496D47),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        width: _size.width * 0.8,
                        child: TextFormField(
                          controller: profileNameController,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                            hintText: 'Type in your profile name.',
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
                      ),
                      SizedBox(height: 10),
                      Visibility(
                        visible: !changePin,
                        child: Column(
                          children: [
                            Text(
                              'New Pin Code',
                              style: TextStyle(
                                color: Color(0xFF496D47),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            PinCodeTextField(
                              backgroundColor: Colors.transparent,
                              blinkWhenObscuring: true,
                              keyboardType: TextInputType.number,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              animationType: AnimationType.scale,
                              obscureText: true,
                              obscuringWidget: SvgPicture.asset(
                                'assets/images/navigate/wheel.svg',
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  Color(0xFF496D47),
                                  BlendMode.srcIn,
                                ),
                              ),
                              textStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
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
                                if (value == userProfile.pinCode &&
                                    value == newPinConfirm) {
                                  return 'New pin cannot be the same as old pin';
                                }
                                return null;
                              },
                              appContext: context,
                              length: 4,
                              onChanged: (value) {
                                newPin = value;
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Confirm New Pin Code',
                              style: TextStyle(
                                color: Color(0xFF496D47),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            PinCodeTextField(
                              backgroundColor: Colors.transparent,
                              blinkWhenObscuring: true,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.scale,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              obscureText: true,
                              obscuringWidget: SvgPicture.asset(
                                'assets/images/navigate/wheel.svg',
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  Color(0xFF496D47),
                                  BlendMode.srcIn,
                                ),
                              ),
                              textStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              pinTheme: PinTheme(
                                activeColor: Color(0xFF496D47),
                                inactiveColor: Colors.grey,
                                selectedColor: Color(0xFF496D47),
                              ),
                              validator: (value) {
                                if (value != newPin) {
                                  return 'Pin code does not match';
                                }
                                if (value == userProfile.pinCode &&
                                    value == newPinConfirm) {
                                  return 'New pin cannot be the same as old pin';
                                }
                                return null;
                              },
                              appContext: context,
                              length: 4,
                              onChanged: (value) {
                                newPinConfirm = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              changePin = !changePin;
                            });
                          },
                          child: Text(changePin ? 'Change Pin' : 'Cancel'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF496D47),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Color(0xFF496D47),
                  height: 50,
                  width: double.infinity,
                  child: InkWell(
                    child: Center(
                      child: Text(
                        'Apply Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    onTap: () {
                      List<UserProfile> jsonToProfiles =
                          StorageHelper.getStringList('userProfiles')!
                              .map((e) => UserProfile.fromJson(e))
                              .toList();
                      if (!changePin) {
                        if ((newPin.isEmpty || newPinConfirm.isEmpty) ||
                            (newPin.length < 4 || newPinConfirm.length < 4) ||
                            (newPin == userProfile.pinCode ||
                                newPinConfirm == userProfile.pinCode) ||
                            (newPin != newPinConfirm) ||
                            jsonToProfiles
                                .map((e) => e.profileNumber)
                                .skipWhile((value) =>
                                    value == userProfile.profileNumber)
                                .contains(profileNameController.value.text)) {
                          if (jsonToProfiles
                              .map((e) => e.profileNumber)
                              .skipWhile(
                                  (value) => value == userProfile.profileNumber)
                              .contains(profileNameController.value.text)) {
                            CustomToast.showToastSimple(
                                context: context,
                                simpleMessage: 'Profile Name Already Exist');
                          } else {
                            formKey.currentState!.validate();
                          }
                          return;
                        } else {
                          List<UserProfile> edittedProfiles = [];
                          jsonToProfiles.forEach((element) {
                            if (element.profileNumber ==
                                userProfile.profileNumber) {
                              edittedProfiles.add(UserProfile(
                                profileNumber: userProfile.profileNumber,
                                avatarCode: avatarCode,
                                profileName: profileNameController.value.text,
                                pinCode: newPin,
                              ));
                            } else {
                              edittedProfiles.add(element);
                            }
                          });
                          StorageHelper.setStringList('userProfiles',
                              edittedProfiles.map((e) => e.toJson()).toList());
                          setState(() {
                            userProfile = edittedProfiles.firstWhere(
                              (element) =>
                                  element.profileNumber ==
                                  userProfile.profileNumber,
                            );
                            currentUser = userProfile;
                            changePin = true;
                          });
                          CustomToast.showToastSetupAction(
                              context, 'Changes Applied', true);
                        }
                      } else {
                        if (profileNameController.value.text.isEmpty ||
                            jsonToProfiles
                                .map((e) => e.profileNumber)
                                .skipWhile((value) =>
                                    value == userProfile.profileNumber)
                                .contains(profileNameController.value.text)) {
                          if (jsonToProfiles
                              .map((e) => e.profileNumber)
                              .skipWhile(
                                  (value) => value == userProfile.profileNumber)
                              .contains(profileNameController.value.text)) {
                            CustomToast.showToastSimple(
                                context: context,
                                simpleMessage: 'Profile Name Already Exist');
                          } else {
                            formKey.currentState!.validate();
                          }
                          return;
                        } else {
                          List<UserProfile> jsonToProfiles =
                              StorageHelper.getStringList('userProfiles')!
                                  .map((e) => UserProfile.fromJson(e))
                                  .toList();
                          List<UserProfile> edittedProfiles = [];
                          jsonToProfiles.forEach((element) {
                            if (element.profileNumber ==
                                userProfile.profileNumber) {
                              edittedProfiles.add(UserProfile(
                                profileNumber: userProfile.profileNumber,
                                avatarCode: avatarCode,
                                profileName: profileNameController.value.text,
                                pinCode: userProfile.pinCode,
                              ));
                            } else {
                              edittedProfiles.add(element);
                            }
                          });
                          StorageHelper.setStringList('userProfiles',
                              edittedProfiles.map((e) => e.toJson()).toList());
                          setState(() {
                            userProfile = edittedProfiles.firstWhere(
                              (element) =>
                                  element.profileNumber ==
                                  userProfile.profileNumber,
                            );
                            currentUser = userProfile;
                          });
                          CustomToast.showToastSetupAction(
                              context, 'Changes Applied', true);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
