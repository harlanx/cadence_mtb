//"..." is an spread operator. It can be used to insert all the elements of a list into another list.
//This is also useful in providing a method the returns a list of widget into the children parameter of a widget
//Example: children: [Container(), ..._buildMenuItems, Container()]
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> preparationKey = GlobalKey<ScaffoldState>();

List<CheckListItem> fullList = [
  ...theTwoEssentials,
  ...coreGear,
  ...coreRepairItems,
  ...clothing,
  ...gearOptions,
  ...repairKitOptions,
  ...freeRidingGear,
  ...personal
];

final List<CheckListItem> theTwoEssentials = [
  CheckListItem(
    name: 'Bike',
    imagePath: 'assets/images/preparation/the_two_essentials/bike.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Trek',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                  preparationKey.currentContext!,
                  CustomRoutes.fadeThrough(
                      page: AppBrowser(
                    link: 'https://www.trekbikes.com/us/en_US/bikes/mountain-bikes/trail-mountain-bikes/roscoe/roscoe-7/p/28499/',
                  )));
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Helmet',
    imagePath: 'assets/images/preparation/the_two_essentials/helmet.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'RockRider',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.decathlon.ph/p/8529388_mountain-bike-helmet-st-500-black.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
];

final List<CheckListItem> coreGear = [
  CheckListItem(
    name: 'Hydration pack or water bottles',
    imagePath: 'assets/images/preparation/core_gear/hydration_pack.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'RockRider',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.decathlon.ph/p/8300156_mountain-biking-4l-hydration-backpack-st-500-black.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Eye protection',
    imagePath: 'assets/images/preparation/core_gear/eye_protection.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'RockBros',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/ROCKBROS-Bicycle-Photochromic-Sunglasses-UV400-Outdoor-Sports-Eyewear-Goggles-i.66842532.5313562252',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Gloves',
    imagePath: 'assets/images/preparation/core_gear/gloves.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'PEARL iZUMi',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.rei.com/product/169151/pearl-izumi-elite-gel-cycling-gloves-mens',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'First-aid Kit',
    imagePath: 'assets/images/preparation/core_gear/first_aid_kit.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'BikePacking',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://bikepacking.com/plan/bikepacking-first-aid-kit/',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
];

final List<CheckListItem> coreRepairItems = [
  CheckListItem(
    name: 'Spare tube and/or patch kit',
    imagePath: 'assets/images/preparation/core_repair_items/spare_tube.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Maxxis',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link:
                        'https://shopee.ph/-ALL-SIZES-Maxxis-Bicycle-Inner-Tube-Ultralight-Road-Bike-Mountain-MTB-700-26-27.5-29-Bicycle-Tube-Racing-Cycling-Accessories-Track-Fixed-Gear-DownHill-WELTER-WEIGHT-Ultralight-Riding-Folding-Sports-Outdoor-Fitness-Exercise-Tools-Components-i.310420565.4556667741',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Tire levers',
    imagePath: 'assets/images/preparation/core_repair_items/tire_levers.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Zefal',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/Zefal-Tire-Lever-(Set-of-3-pcs-TRI-COLOR)-i.259511845.4452411511',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Compact pump',
    imagePath: 'assets/images/preparation/core_repair_items/compact_pump.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Lezyne',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://ride.lezyne.com/collections/hand-pumps/products/1-mp-ltdr-v1m04',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Cycling multi-tool',
    imagePath: 'assets/images/preparation/core_repair_items/cycling_multi_tool.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Armchair, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Bicycle_multi-tool.JPG',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/3.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(
          text: ' via Wikimedia Commons / White background added from original',
        )
      ],
    ),
  ),
];

final List<CheckListItem> clothing = [
  CheckListItem(
    name: 'Wicking jersey or top',
    imagePath: 'assets/images/preparation/clothing/wicking_jersey.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/ranger-short-sleeve-foxhead-jersey',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Shoes suited to bike pedals',
    imagePath: 'assets/images/preparation/clothing/footwear.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Shimano',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://bike.shimano.com/en-NZ/product/component/shimano/SH-M089.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Padded shorts or tights',
    imagePath: 'assets/images/preparation/clothing/padded_shorts.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/ranger-shorts/25128.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Cycling socks',
    imagePath: 'assets/images/preparation/clothing/cycling_socks.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Giro',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.giro.com/p/hrc-grip-cycling-socks/110000000500000021.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Rainwear',
    imagePath: 'assets/images/preparation/clothing/rainwear.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/ranger-2.5l-water-jacket/27361.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Weatherproof Gloves',
    imagePath: 'assets/images/preparation/clothing/weatherproof_gloves.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/ranger-glove-gel/22941.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Stowaway jacket',
    imagePath: 'assets/images/preparation/clothing/stowaway_wind_jacket.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/legion-packable-[blk]-s/26275-001-S.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Insulation layer',
    imagePath: 'assets/images/preparation/clothing/insulation_layer.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/flexair-pro-fire-alpha-jacket/24066.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Neck gaiter/buff',
    imagePath: 'assets/images/preparation/clothing/buff.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'World Balance',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.worldbalance.com.ph/protective-neck-gaiter.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Arm/leg warmers',
    imagePath: 'assets/images/preparation/clothing/arm_leg_warmers.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Specialized (Arm Warmer), ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.specialized.com/us/en/deflect-uv-arm-sleeves/p/161222',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Specialized (Leg Warmer)',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.specialized.com/us/en/therminal-engineered-leg-warmers/p/170252',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
];

final List<CheckListItem> gearOptions = [
  CheckListItem(
    name: 'Lock',
    imagePath: 'assets/images/preparation/gear_options/lock.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Kryptonite Lock',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.kryptonitelock.com/content/kryt-us-2/en/products/product-information/current-key/000815.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Water bottles with cages',
    imagePath: 'assets/images/preparation/gear_options/water_bottle.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'yourpurworld.ph',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/Bicycle-Outdoor-Water-Bottle-Holder-Cage-Rack-i.161721578.3951437414',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'GPS',
    imagePath: 'assets/images/preparation/gear_options/gps.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Garmin',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://ph.garmin.com/products/outdoor/gpsmap-66s/',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Compass',
    imagePath: 'assets/images/preparation/gear_options/compass.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Bios~commonswiki, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Kompas_Sofia.JPG',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'http://creativecommons.org/licenses/by-sa/3.0/',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons / White background added from original')
      ],
    ),
  ),
  CheckListItem(
    name: 'Saddle bag',
    imagePath: 'assets/images/preparation/gear_options/saddle_bag.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'RockBros',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link:
                        'https://shopee.ph/ROCKBROS-Below-6.8-Phone-Bicycle-Bags-Waterproof-1.7L-Top-Tube-Handlebar-Bag-Large-Capactity-Touch-Screen-Bike-Phone-Bag-i.66842532.7054110058',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Wrist altimeter',
    imagePath: 'assets/images/preparation/gear_options/wrist_altimeter.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Altix',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.parasport.it/en/electronic-altimeters/88--1773-altix-digital-altimeter.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Headlight',
    imagePath: 'assets/images/preparation/gear_options/headlight.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'RockBros',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/USB-Rechargeable-LED-Light-ROCKBROS-Bike-Cycling-Headlight-i.66842532.2015172955',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Taillight',
    imagePath: 'assets/images/preparation/gear_options/taillight.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'RockBros',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/ROCKBROS-Smart-Bike-Brake-Detection-Light-Automatic-Start-Stop-Waterproof-LED-i.66842532.4707382310',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Emergency whistle',
    imagePath: 'assets/images/preparation/gear_options/emergency_whistle.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Pierpaoloct at Italian Wikipedia, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Emergency_whistle_SOS.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/3.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
];

final List<CheckListItem> repairKitOptions = [
  CheckListItem(
    name: 'Patch kit',
    imagePath: 'assets/images/preparation/repair_kit_options/patch_kit.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Maruni',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/Maruni-JAPAN-Bicycle-MTB-and-RB-patch-kit-i.84956873.1854273318',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Spare tire',
    imagePath: 'assets/images/preparation/repair_kit_options/spare_tire.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Maxxis',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link:
                        'https://shopee.ph/Maxxis-IKON-MTB-Bicycle-Tires-27.5*2.2-29*2.0-29*2.2-29*2.25-26*2.2-Tubeless-Tyre-3C-TR-EXO-Anti-Puncture-Tyres-Mountain-Bike-Tire-Pneu-i.279113858.5549995588',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Pressure gauge',
    imagePath: 'assets/images/preparation/repair_kit_options/pressure_gauge.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Michelin',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/Michelin-Digital-Tire-Tread-Depth-Pressure-Gauge-MN-4204-i.46098518.1265843305',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Chain tool',
    imagePath: 'assets/images/preparation/repair_kit_options/chain_tool.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'AndrewDressel, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Disassembling_a_bicycle_chain_with_a_chain_tool.JPG',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/3.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'CO2 inflator',
    imagePath: 'assets/images/preparation/repair_kit_options/co2_inflator.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Ryoichi Tanaka from Yokohama, Japan, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:CO2_inflator.jpg ',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY 2.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by/2.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons / White background added from original')
      ],
    ),
  ),
  CheckListItem(
    name: 'Replacement chain links',
    imagePath: 'assets/images/preparation/repair_kit_options/replacement_chain_links.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'cuticate.ph',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/Bicycle-Missing-Link-Chain-Link-Connector-6-7-8-Speed-9-10.11-Speed-Bikes-i.140620530.5307675531',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Spare spokes (minimum of 6)',
    imagePath: 'assets/images/preparation/repair_kit_options/spare_spokes.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Saturn',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://shopee.ph/Spoke-Saturn-Stainless-Black-i.7098011.6953085699',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Lubricant',
    imagePath: 'assets/images/preparation/repair_kit_options/lubricant.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'WD40',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.wd40.com/products/wd-40-bike-dry-lube/',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Spoke wrench',
    imagePath: 'assets/images/preparation/repair_kit_options/spoke_wrench.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Ocdp, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Spoke_wrench_001.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/3.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons / White background added from original')
      ],
    ),
  ),
  CheckListItem(
    name: 'Brake & shifting cable',
    imagePath: 'assets/images/preparation/repair_kit_options/brake_and_derailleure_cables.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Shimano (Brake Cable), ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://bike.shimano.com/en-SG/product/service-upgradeparts/shimano/Y80098021.html',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Shimano (Shifting Cable)',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://bike.shimano.com/en-SG/product/service-upgradeparts/shimano/Y60198090.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: '6" adjustable wrench',
    imagePath: 'assets/images/preparation/repair_kit_options/six_inch_adjustable_wrench.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Dmitry G, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Adjustable_wrench_76-4051.JPG',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: 'Public domain, via Wikimedia Commons / White background added from the original')
      ],
    ),
  ),
  CheckListItem(
    name: 'Nuts and bolts',
    imagePath: 'assets/images/preparation/repair_kit_options/assorted_nuts_and_bolts.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'LPLH (Nuts), ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link:
                        'https://shopee.ph/LHPH-Bicycle-Hub-Nuts-Front-Rear-Drum-Hub-Axle-Fastening-Nut-With-Anti-skid-Texture-joie-i.131639342.7401824454',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'TACHIUWA2 (Bolts)',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link:
                        'https://shopee.ph/-TACHIUWA2-Alloy-Bicycle-Stem-Screw-M5-M6x20mm-Aluminium-Alloy-Bike-Stem-Bolts-with-Washers-Set-Corrosion-resistant-Mountain-Road-Bicycle-Parts-i.238620789.4050929777',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'General purpose multi-tool',
    imagePath: 'assets/images/preparation/repair_kit_options/general_purpose_multitool.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Santeri Viinamäki, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Stainless_2CR.JPG',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by/3.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons / White background added from original')
      ],
    ),
  ),
  CheckListItem(
    name: 'Duct tape',
    imagePath: 'assets/images/preparation/repair_kit_options/duct_tape.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Evan-Amos, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Emergency_whistle_SOS.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: 'Public domain, via Wikimedia Commons')
      ],
    ),
  ),
];

final List<CheckListItem> freeRidingGear = [
  CheckListItem(
    name: 'Full-face helmet',
    imagePath: 'assets/images/preparation/freeriding_gear/full_face_helmet.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/rampage-helmet/27507.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Elbow pads',
    imagePath: 'assets/images/preparation/freeriding_gear/elbow_pads.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/launch-pro-d3o%C2%AE-elbow-guards/18495.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Shin guards',
    imagePath: 'assets/images/preparation/freeriding_gear/shin_guards.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/launch-pro-knee%2Fshin-guard/23851.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Upper body protection',
    imagePath: 'assets/images/preparation/freeriding_gear/upper_body_protection.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Fox Racing',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.foxracing.com/yth-raptor-proframe-lc%2C-ce-%5Bblk%2Fwht%5D-os/13608-018-OS.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
];

final List<CheckListItem> personal = [
  CheckListItem(
    name: 'Emergency contact card',
    imagePath: 'assets/images/preparation/personal/emergency_card.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Cycling Skills',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://cyclingskills.blogspot.com/2008/07/in-case-of-emergency-ice-card.html',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Lunch / snacks',
    imagePath: 'assets/images/preparation/personal/lunch.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              '毒島みるく, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Hamburg_steak_with_demigrass_sauce_lunch_box_of_Hotto_Motto.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/publicdomain/zero/1.0/deed.en',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Sunscreen',
    imagePath: 'assets/images/preparation/personal/sunscreen.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Watsons',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.watsons.com.ph/very-high-protection-sunscreen-body-lotion-spf-50+-pa+++-100ml/p/BP_50017336',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Performance food / drinks',
    imagePath: 'assets/images/preparation/personal/performance_drinks.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'SonHaonugkami, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link:
                        'https://commons.wikimedia.org/wiki/File:HK_Sheung_Wan_Parkn_Shop_pre-packed_soft_drink_Oct-2013_%E4%BD%B3%E5%BE%97%E6%A8%82_Gatorade_Lemon-Lime_600ML.JPG',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 3.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/3.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Lip balm',
    imagePath: 'assets/images/preparation/personal/lip_balm.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Jorge Barrios Riquelme, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:ChapStick_lip_balm.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 4.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/4.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Maps',
    imagePath: 'assets/images/preparation/personal/maps.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Nikolaj, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:USE-IT_Copenhagen_paper_map.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 2.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/2.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Insect repellent',
    imagePath: 'assets/images/preparation/personal/insect_repellant.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Off',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://off.com/en/product/deep-woods',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Guidebook / route description',
    imagePath: 'assets/images/preparation/personal/guidebook.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'MNHNL_pbraun, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:Info_bord_redrock_Mountain_bike_trail_.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/publicdomain/zero/1.0/deed.en',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Chamois cream',
    imagePath: 'assets/images/preparation/personal/chamois_cream.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Assos',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.assos.com/chamois-creme-boxf-20',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Trailhead permit (if needed)',
    imagePath: 'assets/images/preparation/personal/trailhead_permit.jpg',
  ),
  CheckListItem(
    name: 'Small quick-dry towel',
    imagePath: 'assets/images/preparation/personal/quick_dry_towel.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'NatureHike',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.naturehike.com/products/naturehike-microfiber-anti-bacterial-quick-drying-towels-nh15a003-p',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Camera',
    imagePath: 'assets/images/preparation/personal/camera.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Rama, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:GoPro-IMG_0431.jpg',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY-SA 2.0 FR',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by-sa/2.0/fr/deed.en',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Wipes (for cleanups)',
    imagePath: 'assets/images/preparation/personal/wipes.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Sanicare',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://scpa.com.ph/products/sanicare-cleansing-wipes-15s/',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Cellphone',
    imagePath: 'assets/images/preparation/personal/cellphone.jpg',
    attribution: TextSpan(
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'LG Electronics, ',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://commons.wikimedia.org/wiki/File:LG_G8_ThinQ_(cropped).png',
                  ),
                ),
              );
            },
          ),
        ),
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'CC BY 2.0',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://creativecommons.org/licenses/by/2.0',
                  ),
                ),
              );
            },
          ),
        ),
        TextSpan(text: ' via Wikimedia Commons')
      ],
    ),
  ),
  CheckListItem(
    name: 'Toilet paper or tissue',
    imagePath: 'assets/images/preparation/personal/toilet_paper.jpg',
    attribution: TextSpan(
      text: 'Image Credit: ',
      children: [
        WidgetSpan(
          child: GestureDetector(
            child: Text(
              'Kleenex',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.push(
                preparationKey.currentContext!,
                CustomRoutes.fadeThrough(
                  page: AppBrowser(
                    link: 'https://www.kleenex.com/en-us/products/facial-tissues/trusted-care/',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  CheckListItem(
    name: 'Cash / credit card / ID',
    imagePath: 'assets/images/preparation/personal/cash.jpg',
  ),
];