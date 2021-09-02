import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:collection/collection.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final FocusNode _massUnitNode = FocusNode();
  final TextEditingController _massUnitController = TextEditingController();
  String _massUnit = 'kg';
  int _appTheme = 1;
  final Map<int, List<dynamic>> _appThemes = {
    1: ['System Default', Icons.settings],
    2: ['Light Mode', Icons.wb_sunny_outlined],
    3: ['Dark Mode', Icons.brightness_2_outlined]
  };

  @override
  void initState() {
    super.initState();
    getSavedValues();
  }

  @override
  void dispose() {
    _massUnitController.dispose();
    _massUnitNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Size _size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            ),
            backgroundColor: Color(0xFF496D47),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  final ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  _themeProvider.selectTheme(_appTheme);
                  double weight = double.parse(_massUnitController.text);
                  if (_massUnit == 'lb') {
                    double converted = weight / 2.2;
                    weight = converted;
                  }
                  sosEnabled.entries.forEachIndexed((index, item) {
                    StorageHelper.setBool('${currentUser!.profileNumber}${item.key.toLowerCase().replaceAll(' ', '')}', item.value!);
                  });
                  StorageHelper.setDouble('${currentUser!.profileNumber}userWeight', weight);
                  StorageHelper.setString('${currentUser!.profileNumber}massUnit', _massUnit);
                  StorageHelper.setInt('${currentUser!.profileNumber}appTheme', _appTheme);
                  CustomToast.showToastSimple(context: context, simpleMessage: 'Settings Applied');
                },
              ),
            ],
          ),
          body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(8.0),
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          'Body Weight',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: TextFormField(
                            controller: _massUnitController,
                            focusNode: _massUnitNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF496D47),
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              errorStyle: TextStyle(height: 0),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                            ],
                            onEditingComplete: () {
                              _massUnitNode.unfocus();
                            },
                            onFieldSubmitted: (val) {
                              _massUnitNode.unfocus();
                            },
                            onChanged: (val) {
                              setState(() {});
                            },
                            validator: (val) {
                              if (val!.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Listener(
                        onPointerDown: (_) => FocusScope.of(context).unfocus(),
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            underline: SizedBox.shrink(),
                            isDense: true,
                            value: _massUnit,
                            items: [
                              DropdownMenuItem(child: Text('kg'), value: 'kg'),
                              DropdownMenuItem(child: Text('lb'), value: 'lb'),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _massUnit = val!;
                              });
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _massUnitController.text.isEmpty,
                        child: Text(
                          'Cannot be empty.',
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Providing your current weight will result in a more accurate calculation of the calories you burn when using the navigation feature. By default, the app uses the global average weight of a person which is 57.7.',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                  ),
                ],
              ),
              Divider(),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'SOS Button',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                            text: '\nChoose the pages to show the SOS Button.\nBy default, it shows in all of the pages.',
                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12)),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: _isPortrait ? _size.height * 0.006 : _size.height * 0.009,
                      crossAxisCount: _isPortrait ? 2 : 4,
                    ),
                    itemCount: sosEnabled.values.length,
                    itemBuilder: (_, index) {
                      String key = sosEnabled.keys.elementAt(index);
                      return CheckboxListTile(
                          title: Text(key),
                          value: sosEnabled[key],
                          dense: true,
                          activeColor: Color(0xFF496D47),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (newValue) {
                            setState(() {
                              sosEnabled[key] = newValue;
                            });
                          });
                    },
                  ),
                ],
              ),
              Divider(),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left,
                  ),
                  ..._appThemes.entries.map((theme) {
                    return ListTileTheme(
                      contentPadding: EdgeInsets.zero,
                      child: RadioListTile<int>(
                          dense: true,
                          title: Text(theme.value[0]),
                          secondary: Icon(theme.value[1]),
                          value: theme.key,
                          groupValue: _appTheme,
                          activeColor: Color(0xFF496D47),
                          selected: theme.key == _appTheme,
                          onChanged: (val) {
                            setState(() {
                              _appTheme = val!;
                            });
                          }),
                    );
                  }).toList(),
                ],
              ),
              Divider(),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (_, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return SizedBox.shrink();
                      }
                      return ListTileTheme(
                        contentPadding: EdgeInsets.zero,
                        child: ListTile(
                          onTap: () async {
                            DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                            await deviceInfo.androidInfo.then((info) {
                              showAboutDialog(
                                context: context,
                                applicationIcon: Image.asset(
                                  'assets/icons/final_app_icon.png',
                                  height: 50,
                                  width: 50,
                                ),
                                applicationName: 'Cadence MTB',
                                //Update app version in pubspec.yaml when releasing new version
                                applicationVersion: snapshot.data!.version,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 40,
                                        child: Text('Build Date: '),
                                      ),
                                      Expanded(
                                        flex: 60,
                                        child: Text(
                                          //Update date when releasing new version
                                          '05/22/2021 14:57',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 40,
                                        child: Text('Model :'),
                                      ),
                                      Expanded(
                                        flex: 60,
                                        child: Text(
                                          '${info.brand} ${info.model}',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 40,
                                        child: Text('OS Version :'),
                                      ),
                                      Expanded(
                                        flex: 60,
                                        child: Text(
                                          'Android ${info.version.release} sdk ${info.version.sdkInt}',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Cadence MTB was made to serve as a guide and application tool for mountain bikers in the Philippines.',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 40,
                                        child: Text('Developers :'),
                                      ),
                                      Expanded(
                                        flex: 60,
                                        child: Text(
                                          'Gutierrez, Ezekiel V.\nRelos, Renzo R.\nSilan, Harry C.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                          },
                          title: Text(
                            'About',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Version: ${snapshot.data!.version}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Author: Harry Silan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.info_outline),
                        ),
                      );
                    default:
                      return SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getSavedValues() {
    _appTheme = StorageHelper.getInt('${currentUser!.profileNumber}appTheme') ?? 1;
    _massUnit = StorageHelper.getString('${currentUser!.profileNumber}massUnit') ?? 'kg';
    double weight = StorageHelper.getDouble('${currentUser!.profileNumber}userWeight') ?? 57.7;
    if (_massUnit == 'lb') {
      double converted = weight * 0.453592;
      weight = converted;
    }
    _massUnitController.text = weight.toString();
    sosEnabled = {
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
  }
}
