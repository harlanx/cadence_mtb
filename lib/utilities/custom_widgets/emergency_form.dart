
part of 'emergency_button.dart';

///Emergency Form. Show up if the user haven't set their SOS details.
class EmergencyForm extends StatefulWidget {
  @override
  _EmergencyFormState createState() => _EmergencyFormState();
}

class _EmergencyFormState extends State<EmergencyForm> with WidgetsBindingObserver {
  final GlobalKey<FormBuilderState> formBuilderKey = GlobalKey<FormBuilderState>();
  //final GlobalKey<FormBuilderFieldState> _chipsInputState = GlobalKey<FormBuilderFieldState>();
  GlobalKey<ChipsInputState> _chipsInputKey = GlobalKey<ChipsInputState>();
  //ChipsInputState<Contact> _chipsState = ChipsInputState<Contact>();
  final Function deepEquals = DeepCollectionEquality.unordered().equals;
  final List<String> _savedContactNumbers = StorageHelper.getStringList('${currentUser!.profileNumber}sosContacts') ?? [];
  List<String> _selectedContacts = [];
  List<Contact> savedContacts = [];
  final FocusNode _customMessageNode = FocusNode();
  final FocusNode _appendLocationNode = FocusNode();
  final FocusNode _selectedContactsNode = FocusNode();
  bool resetEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _customMessageNode.addListener(() => _smsPermissionChecker(context));
    _appendLocationNode.addListener(() => _locationPermissionChecker(context));
    _selectedContactsNode.addListener(() => _contactsPermissionChecker(context));
    savedContacts = userContacts.where((element) => _savedContactNumbers.contains(element.phones?.elementAt(0).value?.replaceAll('-', ''))).toList();
  }

  @override
  void dispose() {
    _customMessageNode.dispose();
    _appendLocationNode.dispose();
    _selectedContactsNode.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //ALLOWS US TO UPDATE OUR CONTACT LIST IN CASE OF USER LEAVING THE APP TEMPORARILY AND ADDING A CONTACT
    if (state == AppLifecycleState.resumed) {
      Permission.contacts.status.then((permission) async {
        if (permission.isGranted) {
          userContacts = (await ContactsService.getContacts(withThumbnails: true)).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //YOU CAN OVERRIDE GLOBAL APP THEME IF NEEDED, JUST WRAP YOUR MAIN WIDGET IN A THEME WIDGET
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
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) => states.contains(MaterialState.disabled) ? Colors.grey.shade400 : Colors.white),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.disabled) ? Color(0xF496D47).brighten(0.1) : Color(0xFF496D47),
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.pressed) ? Color(0xFF496D47).darken(0.1) : Colors.transparent,
              ),
            ),
            onPressed: () {
              //Check first if the required fields are filled.
              if (formBuilderKey.currentState!.fields['sosMessage']!.value.isEmpty ||
                      _chipsInputKey.currentState!.currentTextEditingValue.text.isEmpty
                  //formBuilderKey.currentState.fields['selectedContacts'].value.isEmpty
                  ) {
                formBuilderKey.currentState!.validate();
                return;
              }
              /* CHECK IF INITIAL VALUE IS THE SAME TO THE CURRENT VALUE [BASICALLY CHECKS IF THE USER CHANGED ANYTHING].
                  THERE ARE MULTIPLE WAYS [listEquals, setEquals, mapEquals] BUT WHEN I TRIED IT ALL, IT DIDN'T MEET WHAT I 
                  NEEDED AS IT ALWAYS RETURNING TO FALSE WHENEVER THERE ARE CHANGES IN THE CONTACTS BUT THE VALUE IS STILL
                  THE SAME. THE REASON IS THE CHANGES IN HASHCODES CHECKED BY setEquals and mapEquals, and listEquals REQUIRES
                  THE SAME ORDER OF VALUE TO RETURN TRUE. SO IN MY CASE I NEED TO CHECK FOR CONTACT PROPERTY VALUES INSTEAD
                  AND USE DeepCollectionEquality.unordered().equals AS THE SOLUTION*/
              Map<String, dynamic> initialValue = {
                'sosMessage': formBuilderKey.currentState!.fields['sosMessage']!.initialValue,
                'appendLocation': formBuilderKey.currentState!.fields['appendLocation']!.initialValue,
                'selectedContacts': savedContacts,
              };
              Map<String, dynamic> currentValue = {
                'sosMessage': formBuilderKey.currentState!.fields['sosMessage']!.value,
                'appendLocation': formBuilderKey.currentState!.fields['appendLocation']!.value,
                'selectedContacts': _selectedContacts
                    .map((e) => userContacts.singleWhere((element) => element.phones!.elementAt(0).value!.replaceAll('-', '') == e))
                    .toList(),
                //'selectedContacts': formBuilderKey.currentState.fields['selectedContacts'].value,
              };
              //print('Deep Equal: ${deepEq(currentValue, formBuilderKey.currentState.initialValue)}');
              //if (deepEquals(currentValue, formBuilderKey.currentState.initialValue)) {
              if (deepEquals(currentValue, initialValue)) {
                CustomToast.showToastSetupAction(context, 'No Changes Were Made', true);
              } else {
                CustomToast.showToastSetupAction(context, 'Emergency Details Saved', true);
                //SAVE THE VALUES IN THE FORMBUILDER KEY
                formBuilderKey.currentState!.save();
                //SAVING TO SHARED PREFERENCES
                StorageHelper.setBool('${currentUser!.profileNumber}haveSOSDetails', true);
                StorageHelper.setString('${currentUser!.profileNumber}sosMessage', formBuilderKey.currentState!.fields['sosMessage']!.value);
                StorageHelper.setBool('${currentUser!.profileNumber}appendLocation', formBuilderKey.currentState!.fields['appendLocation']!.value);
                //StorageHelper.setStringList('${currentUser.profileNumber}sosContacts', formBuilderKey.currentState.value['selectedContacts']);
                StorageHelper.setStringList('${currentUser!.profileNumber}sosContacts', _selectedContacts);
              }

              Navigator.of(context).pop();
              /* // GETTING ALL THE VALUES SAVED IN THE formBuilderKey
                    // HAD TO USE A DELAY BECAUSE currentState.save MAY NOT BE THAT FAST
                    // SO WE CAN'T ACCESS THE NEW VALUES QUICKLY.
                    Timer(Duration(milliseconds: 100), () {print(formBuilderKey.currentState.value);});
                    //GETTING SPECIFIC VALUES

                    //Raw Values (Values Inside The TextField, Checkbox, Switch etc..)
                    print(formBuilderKey.currentState.fields['sosMessage'].value);
                    print(formBuilderKey.currentState.fields['appendLocation'].value);
                    print(formBuilderKey.currentState.fields['selectedContacts'].value);

                    //Transformed Values (The Values Returned When Using valueTransformed Property in a FormBuilderWidget)
                    print(formBuilderKey.currentState.value['sosMessage']);
                    print(formBuilderKey.currentState.value['appendLocation']);
                    print(formBuilderKey.currentState.value['selectedContacts']); */
            },
          ),
          TextButton(
            child: Text('Reset'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => states.contains(MaterialState.disabled) ? Colors.orange.shade100 : Colors.orange.shade400),
              overlayColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.pressed) ? Colors.orange.shade800 : Colors.transparent,
              ),
            ),
            onPressed: !resetEnabled
                ? null
                : () {
                    if (_chipsInputKey.currentState!.mounted) {
                      _selectedContacts
                          .map((e) => userContacts.singleWhere((element) => element.phones!.elementAt(0).value!.replaceAll('-', '') == e))
                          .toList()
                          .forEach((element) {
                        _chipsInputKey.currentState!.deleteChip(element);
                      });
                      savedContacts.forEach((element) {
                        _chipsInputKey.currentState!.selectSuggestion(element);
                      });
                      // formBuilderKey.currentState.fields['selectedContacts'].value.forEach((val) {
                      //   _chipsInputKey.currentState.deleteChip(val);
                      // });
                      // formBuilderKey.currentState.fields['selectedContacts'].initialValue.forEach((val) {
                      //   _chipsInputKey.currentState.selectSuggestion(val);
                      // });
                    }
                    formBuilderKey.currentState!.reset();
                    formBuilderKey.currentState!.validate();
                    resetEnabled = false;
                  },
          ),
          TextButton(
            child: Text('Clear'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade400),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.pressed) ? Colors.red.shade800 : Colors.transparent,
              ),
            ),
            onPressed: () {
              //CLEAR THE VALUES/ASSIGN YOUR OWN VALUES USING MAP
              //String : dynamic
              //'key' : value
              if (_chipsInputKey.currentState!.mounted) {
                _selectedContacts
                    .map((e) => userContacts.singleWhere((element) => element.phones!.elementAt(0).value!.replaceAll('-', '') == e))
                    .toList()
                    .forEach((element) {
                  _chipsInputKey.currentState!.deleteChip(element);
                });
                // formBuilderKey.currentState.fields['selectedContacts'].value.forEach((val) {
                //   _chipsInputKey.currentState.deleteChip(val);
                // });
              }
              formBuilderKey.currentState!.patchValue({'sosMessage': '', 'appendLocation': false});
              formBuilderKey.currentState!.validate();
            },
          ),
          TextButton(
            child: Text('Cancel'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade400),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.pressed) ? Colors.grey.shade800 : Colors.transparent,
              ),
            ),
            onPressed: () {
              CustomToast.showToastSetupAction(context, 'Emergency Setup Cancelled', false);
              Navigator.pop(context);
            },
          ),
        ],
        content: Container(
          width: double.maxFinite,
          child: FormBuilder(
            key: formBuilderKey,
            initialValue: {
              'sosMessage': StorageHelper.getString('${currentUser!.profileNumber}sosMessage') ?? '',
              'appendLocation': StorageHelper.getBool('${currentUser!.profileNumber}appendLocation') ?? false,
              //DOESN'T WORK CORRECTLY SO WE ALSO HAVE TO ASSIGN THE INITIAL VALUE TO THE SPECIFIC FORM BUILDER WIDGET
              //*******CHECK GITHUB REPO ISSUE IF ITS FIXED ALREADY*******
              'selectedContacts': savedContacts,
            },
            onChanged: () {
              /* Map<String, dynamic> currentValue = {
                'sosMessage': formBuilderKey.currentState.fields['sosMessage'].value,
                'appendLocation': formBuilderKey.currentState.fields['appendLocation'].value,
                'selectedContacts': formBuilderKey.currentState.fields['selectedContacts'].value,
              }; */
              Map<String, dynamic> initialValue = {
                'sosMessage': formBuilderKey.currentState!.fields['sosMessage']!.initialValue,
                'appendLocation': formBuilderKey.currentState!.fields['appendLocation']!.initialValue,
                'selectedContacts': savedContacts,
              };
              Map<String, dynamic> currentValue = {
                'sosMessage': formBuilderKey.currentState!.fields['sosMessage']!.value,
                'appendLocation': formBuilderKey.currentState!.fields['appendLocation']!.value,
                'selectedContacts': _selectedContacts
                    .map((e) => userContacts.singleWhere((element) => element.phones!.elementAt(0).value!.replaceAll('-', '') == e))
                    .toList(),
                //'selectedContacts': formBuilderKey.currentState.fields['selectedContacts'].value,
              };
              //if (deepEquals(formBuilderKey.currentState.initialValue, currentValue)) {
              if (deepEquals(initialValue, currentValue)) {
                resetEnabled = false;
              } else {
                resetEnabled = true;
              }
              setState(() {});
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Emergency SOS via SMS',
                    style: TextStyle(
                      color: Color(0xFF496D47),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                FormBuilderTextField(
                  //"name: " THE KEY FOR GETTING OR SETTING THE VALUE
                  name: 'sosMessage',
                  focusNode: _customMessageNode,
                  autofocus: false,
                  style: TextStyle(fontSize: 15),
                  //maxLines: 0,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Text Message',
                    labelStyle: TextStyle(
                      color: Color(0xFF496D47),
                      fontWeight: FontWeight.w300,
                    ),
                    hintMaxLines: 6,
                    isDense: true,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                    hintText: 'Type in your custom text message.',
                    errorStyle: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 11.0,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF496D47),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF496D47),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF496D47),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                  validator: FormBuilderValidators.required(context),
                ),
                FormBuilderSwitch(
                  name: 'appendLocation',
                  focusNode: _appendLocationNode,
                  autofocus: false,
                  title: Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFF496D47),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  contentPadding: EdgeInsets.zero,
                  subtitle: Text(
                    'Adds your location information at the last part of your message.',
                    textAlign: TextAlign.left,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    isDense: true,
                    errorStyle: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 11.0,
                    ),
                  ),
                  activeTrackColor: Color(0xFF496D47).brighten(0.2),
                  activeColor: Color(0xFF496D47),
                ),
                //TODO: Update code when ChipsInput has been integrated in FormBuilder
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ChipsInput<Contact>(
                    //name: 'selectedContacts',
                    //key: _chipsInputState,
                    key: _chipsInputKey,
                    maxChips: 5,
                    focusNode: _selectedContactsNode,
                    autofocus: false,
                    initialValue: savedContacts,
                    initialSuggestions: userContacts,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        color: Color(0xFF496D47),
                      ),
                      isDense: true,
                      hintMaxLines: 1,
                      labelText: 'Emergency Contacts',
                      hintText: 'Type in to search contacts.',
                      errorStyle: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 11.0,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF496D47),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF496D47),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF496D47),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    onChanged: (contacts) {
                      _selectedContacts = contacts.map((contact) => contact.phones!.elementAt(0).value!.replaceAll('-', '')).toList();
                      Map<String, dynamic> initialValue = {
                        'sosMessage': formBuilderKey.currentState!.fields['sosMessage']!.initialValue,
                        'appendLocation': formBuilderKey.currentState!.fields['appendLocation']!.initialValue,
                        'selectedContacts': savedContacts,
                      };
                      Map<String, dynamic> currentValue = {
                        'sosMessage': formBuilderKey.currentState!.fields['sosMessage']!.value,
                        'appendLocation': formBuilderKey.currentState!.fields['appendLocation']!.value,
                        'selectedContacts': _selectedContacts
                            .map((e) => userContacts.singleWhere((element) => element.phones!.elementAt(0).value!.replaceAll('-', '') == e))
                            .toList(),
                        //'selectedContacts': formBuilderKey.currentState.fields['selectedContacts'].value,
                      };
                      //if (deepEquals(formBuilderKey.currentState.initialValue, currentValue)) {
                      if (deepEquals(initialValue, currentValue)) {
                        resetEnabled = false;
                      } else {
                        resetEnabled = true;
                      }
                      setState(() {});
                    },
                    // validator: FormBuilderValidators.required(context),
                    // valueTransformer: (contacts) {
                    //   /*
                    //   IF YOU DON'T CAST THE FormBuilderChipsInput as Contact [E.g.: FormBuilderChipsInput<Contacts>(builders: etc...)]
                    //    Then you have to cast it's dynamic value results as Contact or to whatever object type you need it to be
                    //   Example: return values.map((value) => value as Contact).map((contact) => contact.phones.elementAt(0).value.replaceAll('-', '')).toList();
                    //    */
                    //   return contacts.map((contact) => contact.phones.elementAt(0).value.replaceAll('-', '')).toList();
                    // },
                    // onReset: () {
                    //   setState(() {});
                    // },
                    // onChanged: (contacts) {
                    //   setState(() {});
                    // },
                    chipBuilder: (context, state, contact) {
                      return InputChip(
                        key: ObjectKey(contact),
                        label: Text(contact.displayName!),
                        avatar: (contact.avatar != null && contact.avatar!.isNotEmpty)
                            ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar!))
                            : CircleAvatar(
                                backgroundColor: Color(0xFF496D47),
                                child: Padding(
                                  padding: EdgeInsets.all(3.5),
                                  child: Text(
                                    contact.initials(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        onDeleted: () => state.deleteChip(contact),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                    suggestionBuilder: (context, state, contact) {
                      return ListTile(
                        dense: true,
                        key: ObjectKey(contact),
                        leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(
                                  contact.avatar!,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Color(0xFF496D47),
                                child: Text(
                                  contact.initials(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                        title: Text(contact.displayName!),
                        subtitle: Text(contact.phones!.elementAt(0).value!),
                        onTap: () => state.selectSuggestion(contact),
                      );
                    },
                    findSuggestions: (String query) {
                      if (query.length != 0) {
                        var lowercaseQuery = query.toLowerCase();
                        return userContacts.where((contact) => contact.displayName!.toLowerCase().contains(query.toLowerCase())).toList(
                            growable: true)
                          ..sort((a, b) =>
                              a.displayName!.toLowerCase().indexOf(lowercaseQuery).compareTo(b.displayName!.toLowerCase().indexOf(lowercaseQuery)));
                      } else {
                        return <Contact>[];
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

  _smsPermissionChecker(BuildContext context) async {
    if (_customMessageNode.hasFocus) {
      PermissionStatus status = await Permission.sms.request();
      switch (status) {
        case PermissionStatus.permanentlyDenied:
          CustomToast.showToastPermanentlyDenied(
              context: context, requestText: 'In-app sms permission request is permanently denied. Tap here to change through App Settings.');
          _customMessageNode.unfocus();
          break;
        case PermissionStatus.denied:
          CustomToast.showToastDenied(
              context: context, requestText: 'CadenceMTB requires sms permission to send your message to your emergency contacts.');
          _customMessageNode.unfocus();
          break;
        default:
          break;
      }
    }
  }

  _locationPermissionChecker(BuildContext context) async {
    if (_appendLocationNode.hasFocus) {
      PermissionStatus status = await Permission.location.request();
      switch (status) {
        case PermissionStatus.permanentlyDenied:
          CustomToast.showToastPermanentlyDenied(
              context: context, requestText: 'In-app location permission request is permanently denied. Tap here to change through App Settings.');
          _appendLocationNode.unfocus();
          formBuilderKey.currentState!.patchValue({'appendLocation': formBuilderKey.currentState!.initialValue['appendLocation']});
          break;
        case PermissionStatus.denied:
          CustomToast.showToastDenied(context: context, requestText: 'CadenceMTB requires location permission to enable append location.');
          _appendLocationNode.unfocus();
          formBuilderKey.currentState!.patchValue({'appendLocation': formBuilderKey.currentState!.initialValue['appendLocation']});
          break;
        default:
          break;
      }
    }
  }

  _contactsPermissionChecker(BuildContext context) async {
    if (_selectedContactsNode.hasFocus) {
      PermissionStatus status = await Permission.contacts.request();
      switch (status) {
        case PermissionStatus.permanentlyDenied:
          CustomToast.showToastPermanentlyDenied(
              context: context, requestText: 'In-app contact permission request is permanently denied. Tap here to change through App Settings.');
          _selectedContactsNode.unfocus();
          break;
        case PermissionStatus.denied:
          CustomToast.showToastDenied(context: context, requestText: 'CadenceMTB requires sms permission to be able to search for contact list.');
          _selectedContactsNode.unfocus();
          break;
        default:
          if (userContacts.isEmpty) userContacts = (await ContactsService.getContacts(withThumbnails: true)).toList();
          break;
      }
    }
  }
}
