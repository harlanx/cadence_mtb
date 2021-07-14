part of '../../screens/login_screen.dart';

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
