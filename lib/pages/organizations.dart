import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/services/supabase_manager.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
part 'organizations/organization_box.dart';
part 'organizations/organizations_dialog.dart';

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
                            itemBuilder: (context, index) => OrganizationBox(item: _organizationsList[index]),
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