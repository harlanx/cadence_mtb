import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/services/supabase_manager.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Organizations extends StatefulWidget {
  @override
  _OrganizationsState createState() => _OrganizationsState();
}

class _OrganizationsState extends State<Organizations> {
  List<OrganizationsItem> _organizationsList = [];
  late Future<List<OrganizationsItem>> _futureHolder;
  bool _wantToRefresh = false;

  @override
  void initState() {
    super.initState();
    _futureHolder = fetchOrganizations();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              'Organizations',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            backgroundColor: Color(0xFF496D47),
            elevation: 0,
          ),
          body: RefreshIndicator(
            backgroundColor: Colors.white,
            color: Color(0xFF496D47),
            onRefresh: _refreshOrganizations,
            child: FutureBuilder<List<OrganizationsItem>>(
              future: _futureHolder,
              builder: (_, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error as String));
                    } else {
                      return ListView(
                        padding: EdgeInsets.all(15),
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _organizationsList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1.0, crossAxisCount: _isPortrait ? 3 : 5, crossAxisSpacing: 20, mainAxisSpacing: 20),
                            itemBuilder: (context, index) => Organization(item: _organizationsList[index]),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 2,
                          ),
                          Center(
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CustomRoutes.fadeThrough(
                                    page: AppBrowser(
                                      link: 'https://nationalbicycle.org.ph/',
                                    ),
                                  ),
                                );
                              },
                              child: AutoSizeText(
                                'Learn more in National Bicycle Org PH',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 20, fontWeight: FontWeight.w700),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                  default:
                    return SpinKitChasingDots(
                      color: Color(0xFF496D47),
                    );
                }
              },
            ),
          ),
          floatingActionButton: !sosEnabled['Organizations']!
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                  securityBottom: 20,
                ),
        ),
      ),
    );
  }

  Future<List<OrganizationsItem>> fetchOrganizations() async {
    if (_organizationsList.isEmpty) {
      List<String> oldData = StorageHelper.getStringList('organizationsContent') ?? <String>[];
      if (oldData.isNotEmpty) {
        _organizationsList = oldData.map((e) => OrganizationsItem.fromJson(e)).toList();
      } else {
        await InternetConnectionChecker().hasConnection.then((hasInternet) async {
          if (hasInternet) {
            _organizationsList = await SupabaseManager.getOrganizationsList();
            StorageHelper.setStringList('organizationsContent', _organizationsList.map((e) => e.toJson()).toList());
          } else {
            return Future.error('No Internet');
          }
        });
      }
    } else if (_organizationsList.isEmpty && _wantToRefresh) {
      await InternetConnectionChecker().hasConnection.then((hasInternet) async {
        if (hasInternet) {
          _organizationsList.clear();
          _organizationsList.addAll(await SupabaseManager.getOrganizationsList());
          StorageHelper.setStringList('organizationsContent', _organizationsList.map((e) => e.toJson()).toList());
        } else {
          CustomToast.showToastSimple(context: context, simpleMessage: 'No Internet');
        }
      });
      _wantToRefresh = false;
    }
    return _organizationsList;
  }

  Future<void> _refreshOrganizations() async {
    _wantToRefresh = true;
    fetchOrganizations().then((value) => setState(() {}));
  }
}

class Organization extends StatelessWidget {
  Organization({Key? key, required this.item}) : super(key: key);
  final OrganizationsItem item;

  @override
  Widget build(BuildContext context) {
    return Ink.image(
      image: CachedNetworkImageProvider(item.logo),
      fit: BoxFit.contain,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Color(0xFF496D47).withOpacity(0.8),
        onTap: () {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(
              barrierDismissible: true,
            ),
            builder: (context) => OrganizationDialog(item: item),
          );
        },
      ),
    );
  }
}

class OrganizationDialog extends StatelessWidget {
  OrganizationDialog({required this.item});
  final OrganizationsItem item;
  @override
  Widget build(BuildContext context) {
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Size _size = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      contentPadding: EdgeInsets.all(10),
      insetPadding: EdgeInsets.all(1.0),
      content: Container(
        width: _size.width * 0.8,
        height: _size.height * 0.6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _isPortrait
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 70,
                        child: CachedNetworkImage(
                          imageUrl: item.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: double.infinity,
                          child: Center(
                            child: AutoSizeText(
                              item.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 40,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 50,
                              child: Center(
                                child: AutoSizeText(
                                  'Location:',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 50,
                              child: Center(
                                child: AutoSizeText(
                                  item.location,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 15,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {},
                          child: Center(
                            child: TextButton(
                              child: AutoSizeText('Visit Facebook Group / Page'),
                              style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                foregroundColor: MaterialStateProperty.all(Colors.white),
                                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF4267B2)),
                                overlayColor: MaterialStateProperty.resolveWith<Color>(
                                    (states) => states.contains(MaterialState.pressed) ? Color(0xFF4267B2).darken(0.1) : Colors.transparent),
                                shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                FunctionHelper.launchURL(item.link);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 50,
                        child: CachedNetworkImage(
                          imageUrl: item.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        flex: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 40,
                              child: Container(
                                width: double.infinity,
                                child: Center(
                                  child: AutoSizeText(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 40,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 50,
                                    child: Center(
                                      child: AutoSizeText(
                                        'Location:',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 50,
                                    child: Center(
                                      child: AutoSizeText(
                                        item.location,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 40,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {},
                                child: Center(
                                  child: TextButton(
                                    child: AutoSizeText('Visit Facebook Group / Page'),
                                    style: ButtonStyle(
                                      textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                      foregroundColor: MaterialStateProperty.all(Colors.white),
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF4267B2)),
                                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                                          (states) => states.contains(MaterialState.pressed) ? Color(0xFF4267B2).darken(0.1) : Colors.transparent),
                                      shape: MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      FunctionHelper.launchURL(item.link);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.close,
                    color: Color(0xFF496D47),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
