import 'package:cadence_mtb/data/data.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:collection/collection.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BikeSummary extends StatefulWidget {
  final BikeBuild project;
  BikeSummary({required this.project});
  @override
  _BikeSummaryState createState() => _BikeSummaryState();
}

class _BikeSummaryState extends State<BikeSummary> {
  final NumberFormat _currency = NumberFormat("#,##0.00", "fil");
  late BrakeCaliper _brakeCaliper;
  late Cassette _cassette;
  late Crankset _crankset;
  late Frame _frame;
  late FrontDerailleur _frontDerailleur;
  late FrontFork _frontFork;
  late Handlebar _handlebar;
  late Pedal _pedal;
  late RearDerailleur _rearDerailleur;
  late Rim _rim;
  late Saddle _saddle;
  late Tire _tire;
  late Accessory _bell;
  late Accessory _bottleCage;
  late Accessory _fender;
  late Accessory _kickstand;
  late Accessory _light;
  late Accessory _phoneHolder;

  @override
  void initState() {
    super.initState();
    getMatchData();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Color(0xFFFF8B02), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Color(0xFFFF8B02),
            title: Text(
              'Project Summary',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: ListView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            children: [
              Text.rich(
                TextSpan(
                  text: 'Project Name: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  children: [
                    TextSpan(
                      text: widget.project.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 10,
                thickness: 0,
                color: Colors.transparent,
              ),
              Text.rich(
                TextSpan(
                  text: 'Total Cost: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  children: [
                    TextSpan(
                      text: '₱${_currency.format(_totalCost())}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 10,
                thickness: 0,
                color: Colors.transparent,
              ),
              Text.rich(
                TextSpan(
                  text: 'Brands: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  children: _allBrandsUsed().mapIndexed(
                    (index, e) {
                      int _total = _allBrandsUsed().length - 1;
                      if (index == _total) {
                        return TextSpan(
                          text: '$e.',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        );
                      }
                      return TextSpan(
                        text: '$e, ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              Divider(
                thickness: 1.5,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Parts',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10,
                thickness: 0,
                color: Colors.transparent,
              ),
              //Dis Brake Caliper
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Brakes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _brakeCaliper.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _brakeCaliper.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _brakeCaliper.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_brakeCaliper.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _brakeCaliper.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Cassette
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Cassette',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _cassette.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _cassette.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _cassette.speed,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_cassette.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _cassette.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Crankset
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Crankset',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _crankset.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _crankset.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _crankset.speed,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_crankset.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _crankset.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Frame
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Frame',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _frame.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _frame.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _frame.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_frame.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _frame.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Front Derailleur
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Front Derailleur',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _frontDerailleur.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _frontDerailleur.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _frontDerailleur.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_frontDerailleur.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _frontDerailleur.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Front Fork
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Front Suspension',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _frontFork.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _frontFork.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _frontFork.sizeType,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_frontFork.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _frontFork.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Handlebar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Handlebar',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _handlebar.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _handlebar.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _handlebar.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_handlebar.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _handlebar.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Pedal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Pedal',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _pedal.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _pedal.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _pedal.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_pedal.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _pedal.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Rear Derailleur
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Rear Derailleur',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _rearDerailleur.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _rearDerailleur.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _rearDerailleur.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_rearDerailleur.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _rearDerailleur.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Rim
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Rim',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _rim.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _rim.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _rim.sizeType,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_rim.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _rim.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Saddle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Saddle',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _saddle.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _saddle.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _saddle.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_saddle.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _saddle.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Tire
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Tire',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _tire.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _tire.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Type: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _tire.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_tire.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _tire.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Bell
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Bell',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _bell.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _bell.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_bell.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _bell.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Bottle Cage
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Bottle Cage',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _bottleCage.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _bottleCage.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_bottleCage.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _bottleCage.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Fender
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Fender / Mud Guard',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _fender.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _fender.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_fender.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _fender.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Kickstand
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Kickstand',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _kickstand.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _kickstand.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_kickstand.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _kickstand.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Light
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Light / Reflector',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _light.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _light.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_light.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _light.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              //Phone Holder
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Phone Holder',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 80,
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: _phoneHolder.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Brand: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: _phoneHolder.brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₱${_currency.format(_phoneHolder.price)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Link: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        CustomRoutes.fadeThrough(
                                          page: AppBrowser(
                                            link: _phoneHolder.link,
                                            purpose: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getMatchData() {
    _brakeCaliper = brakeCaliperItems.where((element) => element.code == widget.project.brakeClprCode).first;
    _cassette = cassetteItems.where((element) => element.code == widget.project.cassetteCode).first;
    _crankset = cranksetItems.where((element) => element.code == widget.project.cranksetCode).first;
    _frame = frameItems.where((element) => element.code == widget.project.frameCode).first;
    _frontDerailleur = frontDlrItems.where((element) => element.code == widget.project.frontDlrCode).first;
    _frontFork = frontForkItems.where((element) => element.code == widget.project.frontForkCode).first;
    _handlebar = handlebarItems.where((element) => element.code == widget.project.handlebarCode).first;
    _pedal = pedalItems.where((element) => element.code == widget.project.pedalCode).first;
    _rearDerailleur = rearDlrItems.where((element) => element.code == widget.project.rearDlrCode).first;
    _rim = rimItems.where((element) => element.code == widget.project.rimCode).first;
    _saddle = saddleItems.where((element) => element.code == widget.project.saddleCode).first;
    _tire = tireItems.where((element) => element.code == widget.project.tireCode).first;
    _bell = bellItems.where((element) => element.code == widget.project.bellCode).first;
    _bottleCage = bottleCageItems.where((element) => element.code == widget.project.bottleCageCode).first;
    _fender = fenderItems.where((element) => element.code == widget.project.fenderCode).first;
    _kickstand = kickstandItems.where((element) => element.code == widget.project.kickstandCode).first;
    _light = lightItems.where((element) => element.code == widget.project.lightCode).first;
    _phoneHolder = phoneHolderItems.where((element) => element.code == widget.project.phoneHolderCode).first;
  }

  double _totalCost() =>
      _brakeCaliper.price +
      _cassette.price +
      _crankset.price +
      _frame.price +
      _frontDerailleur.price +
      _frontFork.price +
      _handlebar.price +
      _pedal.price +
      _rearDerailleur.price +
      _rim.price +
      _saddle.price +
      _tire.price +
      _bell.price +
      _bottleCage.price +
      _fender.price +
      _kickstand.price +
      _light.price +
      _phoneHolder.price;

  List<String> _allBrandsUsed() {
    List<String> _brands = [];
    _brands.add(_brakeCaliper.brand);
    _brands.add(_cassette.brand);
    _brands.add(_crankset.brand);
    _brands.add(_frame.brand);
    _brands.add(_frontDerailleur.brand);
    _brands.add(_frontFork.brand);
    _brands.add(_handlebar.brand);
    _brands.add(_pedal.brand);
    _brands.add(_rearDerailleur.brand);
    _brands.add(_rim.brand);
    _brands.add(_saddle.brand);
    _brands.add(_tire.brand);
    _brands.add(_bell.brand);
    _brands.add(_bottleCage.brand);
    _brands.add(_fender.brand);
    _brands.add(_kickstand.brand);
    _brands.add(_light.brand);
    _brands.add(_phoneHolder.brand);
    return _brands.toSet().toList();
  }
}
