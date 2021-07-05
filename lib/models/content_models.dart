import 'dart:convert';
import 'package:flutter/material.dart';

//Guides Screen Page
class GuidesList {
  String title;
  final String iconPath;
  final Widget page;

  GuidesList({
    required this.title,
    required this.iconPath,
    required this.page,
  });
}

//Naming it [extension GuidesListExtension on GuidesList] so it will be accessible to other dart files,
//otherwise [extension on GuidesList] it will be private to this dart file.
//This is not used in the app but just to demonstrate how to create it how it works.
/* extension GuidesListExtension on GuidesList {
  int titleLength1 () => title.length;
  //To call this use <GuidesList> object.titleLength();
  int get titleLength2 => title.length;
  //To call this use <GuidesList> object.titleLength;
} */

class RulesOfTheTrail {
  final String /*!*/ rule;
  final String description;

  const RulesOfTheTrail({
    required this.rule,
    required this.description,
  });
}

//Organizations
class OrganizationsItem {
  String name;
  String location;
  String logo;
  String link;

  OrganizationsItem({
    required this.name,
    required this.location,
    required this.logo,
    required this.link,
  });

  factory OrganizationsItem.fromJson(String str) => OrganizationsItem.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  OrganizationsItem.fromMap(Map<String, dynamic> json)
      : name = json['name'],
        location = json['location'],
        logo = json['logo'],
        link = json['link'];

  Map<String, dynamic> toMap() => {
        'name': name,
        'location': location,
        'logo': logo,
        'link': link,
      };
}

//Trails
class TrailsItem {
  String trailName;
  String description;
  String location;
  String imagesLink;
  double latitude;
  double longitude;
  double rating;
  String trailType;
  String distance;
  String elevation;
  String difficulty;
  List<String> previews;

  TrailsItem({
    required this.trailName,
    required this.description,
    required this.location,
    required this.imagesLink,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.trailType,
    required this.distance,
    required this.elevation,
    required this.difficulty,
    required this.previews,
  });

  factory TrailsItem.fromJson(String str) => TrailsItem.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  TrailsItem.fromMap(Map<String, dynamic> json)
      : trailName = json['trailName'],
        description = json['description'],
        location = json['location'],
        imagesLink = json['imagesLink'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        rating = json['rating'],
        trailType = json['trailType'],
        distance = json['distance'],
        elevation = json['elevation'],
        difficulty = json['difficulty'],
        previews = json['previews'].toString().split(',');

  Map<String, dynamic> toMap() => {
        'trailName': trailName,
        'description': description,
        'location': location,
        'imagesLink': imagesLink,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'trailType': trailType,
        'distance': distance,
        'elevation': elevation,
        'difficulty': difficulty,
        'previews': previews.join(','),
      };
}

//USED IN FIRST AID AND TIPS AND BENEFITS
class ArticleItem {
  final String image;
  final String title;
  final String subtitle;
  final Widget widget;

  const ArticleItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.widget,
  });
}

//BIKE PROJECT PARTS
class BikeProjectItem {
  final String part;
  final List<String> types;
  final List<List<String>>? subtypes;
  //final String preview;
  bool isExpanded;

  BikeProjectItem({
    required this.part,
    required this.types,
    this.subtypes,
    //this.preview;
    this.isExpanded = false,
  });
}

//Preparations Page Data
class CheckListItem {
  final String name;
  final String imagePath;
  final TextSpan? attribution;
  bool value;

  CheckListItem({
    required this.name,
    required this.imagePath,
    this.attribution,
    this.value = false,
  });
}
