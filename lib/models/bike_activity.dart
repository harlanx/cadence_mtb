import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:weather/weather.dart';
part 'bike_activity.g.dart';

//I'm actually using Hive here as the local database instead of sharedpreferences.
//If you are a generating a new HiveType using build runner, make sure to backup the [WeatherAdapter] [LatLngAdapter]
//and [LatLngBoundsAdapter] and add later on in bike_activity.g.dart since it was added manually
//If you use sharedpreferences, you should use the toJson and fromJson
@HiveType(typeId: 0)
class BikeActivity {
  @HiveField(0)
  String? startLocation;
  @HiveField(1)
  String? endLocation;
  @HiveField(2)
  DateTime? activityDate;
  @HiveField(3)
  double? averageSpeed;
  @HiveField(4)
  double? burnedCalories;
  @HiveField(5)
  double? distance;
  @HiveField(6)
  double? elevation;
  @HiveField(7)
  int? duration;
  @HiveField(8)
  Weather? weatherData;
  @HiveField(9)
  List<LatLng?>? coordinates;
  Set<Polyline>? polylines;
  @HiveField(10)
  LatLngBounds? latLngBounds;

  BikeActivity({
    this.startLocation,
    this.endLocation,
    this.activityDate,
    this.averageSpeed,
    this.burnedCalories,
    this.distance,
    this.elevation,
    this.duration,
    this.weatherData,
    this.coordinates,
    this.polylines,
    this.latLngBounds,
  });

  /* This code is manually created, modify to suit your needs. If you want to save it as a String
  just encode it into a JSON string and decode later when needed.
  There are many formats in creating your own JSON serialization and this is my own preference
  since it separates the methods to a simple map and JSON conversion and decoder*/
  factory BikeActivity.fromJson(String str) => BikeActivity.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  /* NOTE: It is okay to use camelCase as string key since under_score naming isn't much of a
  deal according to JSON documentation although google recommends to use camelCase. */

  BikeActivity.fromMap(Map<String, dynamic> json) {
    startLocation = json['startLocation'] ?? null;
    endLocation = json['endLocation'] ?? null;
    activityDate = DateTime.tryParse(json['activityDate']);
    averageSpeed = json['averageSpeed'] ?? null;
    burnedCalories = json['burnedCalories'] ?? null;
    distance = json['distance'] ?? null;
    elevation = json['elevation'] ?? null;
    duration = json['duration'] ?? null;
    weatherData = json['weatherData'] != null ? Weather(json['weatherData']) : null;
    coordinates = json['coordinates'].forEach((coords) => coordinates!.add(LatLng.fromJson(coords)));
    latLngBounds = json['latLngBounds'] != null
        ? LatLngBounds(southwest: LatLng.fromJson(json['latLngBounds'][0])!, northeast: LatLng.fromJson(json['latLngBounds'][1])!)
        : null;
  }

  Map<String, dynamic> toMap() => {
        'startLocation': startLocation ?? null,
        'endLocation': endLocation ?? null,
        'activityDate': activityDate?.toIso8601String() ?? null,
        'averageSpeed': averageSpeed,
        'burnedCalories': burnedCalories,
        'distance': distance,
        'elevation': elevation,
        'duration': duration,
        'weatherData': weatherData!.toJson(),
        'coordinates': coordinates!.map((v) => v!.toJson()).toList(),
        'latLngBounds': latLngBounds!.toJson(),
      };
}
