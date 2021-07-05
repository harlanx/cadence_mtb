import 'package:animations/animations.dart';
import 'package:cadence_mtb/models/user_profile.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:collection/collection.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_fields/form_builder_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
part 'emergency_form.dart';

//GLOBAL VARIABLE [OUTSIDE OF ANY SCOPE AND HAS NO UNDERSCORE]
List<Contact> userContacts = [];

/* EMERGENCY BUTTON
IT IS OK TO USE RETURNING WIDGET USING A METHOD IF IT'S VERY SIMPLE/SHORT BUT USING CLASS
WIDGETS [STATELESS AND STATEFULL] HAS IT'S ADVANTAGE IN MORE CUSTOMIZATION, INITIALIZATION
OF DATA, STATE MANAGEMENT AND LASTLY, IT HAS SLIGHT IMPROVEMENT TO UI PERFORMANCE. */

///The widget assigned to the Floating Action Button on various pages of the app.
class EmergencyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      onPressed: null,
      child: InkWell(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (states) => states.contains(MaterialState.pressed) ? Color(0xFF496D47).withOpacity(0.8) : Colors.transparent,
        ),
        onTap: () {
          final bool alreadySetup = StorageHelper.getBool('${currentUser!.profileNumber}haveSOSDetails') ?? false;
          if (!alreadySetup) {
            Permission.contacts.status.then(
              (permission) async {
                if (permission.isGranted) {
                  userContacts = (await ContactsService.getContacts(withThumbnails: true)).toList();
                } else {
                  userContacts = [];
                }
                showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
                  builder: (_) {
                    return WillPopScope(
                      onWillPop: () => Future.value(false),
                      child: EmergencyForm(),
                    );
                  },
                );
              },
            );
          }
        },
        onDoubleTap: () {
          final bool alreadySetup = StorageHelper.getBool('${currentUser!.profileNumber}haveSOSDetails') ?? false;
          if (!alreadySetup) {
            Permission.contacts.status.then(
              (permission) async {
                if (permission.isGranted) {
                  userContacts = (await ContactsService.getContacts(withThumbnails: true)).toList();
                } else {
                  userContacts = <Contact>[];
                }
                showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
                  builder: (_) {
                    return WillPopScope(
                      onWillPop: () => Future.value(false),
                      child: EmergencyForm(),
                    );
                  },
                );
              },
            );
          } else {
            sendSOS();
          }
        },
        onLongPress: () {
          Permission.contacts.status.then(
            (permission) async {
              if (permission.isGranted) {
                userContacts = (await ContactsService.getContacts(withThumbnails: true)).toList();
              } else {
                userContacts = <Contact>[];
              }
              showModal(
                context: context,
                configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
                builder: (_) {
                  return WillPopScope(
                    onWillPop: () => Future.value(false),
                    child: EmergencyForm(),
                  );
                },
              );
            },
          );
        },
        splashColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: SvgPicture.asset(
                  'assets/icons/home_dashboard/emergency.svg',
                  color: Color(0xFF496D47),
                ),
              ),
            ),
          ],
        ),
      ),
      shape: CircleBorder(
        side: BorderSide(color: Color(0xFF496D47), width: 2),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Color(0xFF496D47),
    );
  }

  void sendSOS() async {
    final String? sosMessage = StorageHelper.getString('${currentUser!.profileNumber}sosMessage');
    final List<String>? sosContacts = StorageHelper.getStringList('${currentUser!.profileNumber}sosContacts');
    final bool appendLocation = StorageHelper.getBool('${currentUser!.profileNumber}appendLocation') ?? false;
    String sosPosition = '';
    if (sosContacts != null || sosMessage != null) {
      if (appendLocation) {
        await GeolocatorPlatform.instance.isLocationServiceEnabled().then((isEnabled) async {
          await GeolocatorPlatform.instance.checkPermission().then((permission) async {
            switch (permission) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) async {
                  await GeocodingPlatform.instance.placemarkFromCoordinates(position.latitude, position.longitude).then((addresses) {
                    sosPosition =
                        'Latitude: ${position.latitude}\nLongitude: ${position.longitude}\nAddress: ${addresses[0].street}, ${addresses[1].street}. ${addresses[0].locality}, ${addresses[0].subAdministrativeArea}, ${addresses[0].administrativeArea}.';
                  }).catchError((e) {
                    sosPosition = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
                  });
                });
                break;
              case LocationPermission.denied:
              case LocationPermission.deniedForever:
              default:
                break;
            }
          });
        });
      }
      final Telephony telephony = Telephony.instance;
      Fluttertoast.showToast(msg: 'Sending SOS Message');
      sosContacts!.forEach((recepient) {
        telephony.sendSms(to: recepient, message: '$sosMessage\n$sosPosition');
      });
    } else {
      Fluttertoast.showToast(msg: 'SoS Details Missing');
    }
  }
}
