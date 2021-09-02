library function_helper;
import 'dart:convert' show jsonDecode;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cadence_mtb/utilities/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng, LatLngBounds;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather/weather.dart';
export 'storage_helper.dart';
export 'widget_helper.dart';

//==================================================
class FunctionHelper {
  ///First run checker
  static bool get isFirstRun {
    final bool isFirstRun = StorageHelper.getBool('first_run') ?? true;
    if (isFirstRun) {
      StorageHelper.setBool('first_run', false);
      return true;
    } else {
      return false;
    }
  }

  ///Check if the last logged in user profile is logged in.
  static bool get isLoggedIn => StorageHelper.getBool('isLoggedIn') ?? false;

  ///Url launcher and sms launcher.
  ///It opens the user's browser or sms form
  ///We only used it on links that can be opened using another app like facebook and youtube.
  static void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///Converts the original value into the new values using a custom range while maintaining the correct ratio.
  static double valToNewRange({
    required double oldValue,
    required double oldMin,
    required double oldMax,
    required double newMin,
    required double newMax,
  }) {
    double newValue = 0.0;
    newValue = (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
    return newValue;
  }

  ///Png file to [Uint8List] using method [BitmapDescriptor.fromBytes(Uint8List)]
  ///This is used for using a custom [Marker] in [GoogleMaps]
  ///
  ///Can also be used in converting Png map tile into
  ///a [Tile] object which uses a [Uint8List] as an overlay from [TileProvider]
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  ///Deletes the image file stored(cached) in app's temporary files folder.
  static Future<void> deleteImage(String imagePath) async {
    File file = File(imagePath);
    try {
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      throw e;
    }
  }

  //======GENERATE RANDOM DATA FOR BIKE ACTIVITY (DEV USE ONLY)======
  static List<String> locationSamples = [
    'Agila Base, West of Bagong Silang near Makiling Forest Reserve, Los Baños, Laguna',
    'Filinvest MTB Trail, 1781 Filinvest Ave, Alabang, Muntinlupa',
    'Fort Bonifacion Army MTB Trail, Taguig, Metro Manila',
    'Heroes Bike Trail, Western Bicutan, Taguig, Metro Manila',
    'La Mesa Nature Reserve, Quirino Highway, Quezon City, Metro Manila',
    'Maarat Basic Trail, Basic Trail, San Mateo, Rizal',
    'Nuvali Bike Trail 1, Sta. Rosa City, Laguna Province',
    'Tree House Bike Park, Tree House Rd. Arayat, Pampanga',
    'Wawa Dam, M.H Del Pilar Street, Rodriguez, Rizal',
    'Forest Bathing Trail, Camp John Hay, Baguio City',
  ];
  static String randomLocation() => locationSamples[Random().nextInt(locationSamples.length)];
  static DateTime randomActivityDate() => DateTime.parse(
      '2021-${randomInt(min: 1, max: 12).toString().padLeft(2, '0')}-${randomInt(min: 1, max: 30).toString().padLeft(2, '0')}T${randomInt(min: 0, max: 23).toString().padLeft(2, '0')}:${randomInt(min: 0, max: 59).toString().padLeft(2, '0')}:${randomInt(min: 0, max: 59).toString().padLeft(2, '0')}.${randomInt(min: 0, max: 999).toString().padLeft(3, '0')}');

  static double randomDouble({required double min, required double max}) {
    Random _random = Random();
    double result = _random.nextDouble() * (min - max) + max;
    return double.parse(result.toStringAsFixed(2));
  }

  static int randomInt({required int min, required int max}) {
    Random _random = Random();
    int result = min + _random.nextInt((max - min) + 1);
    return result;
  }

  static Weather sampleWeather() => Weather(jsonDecode(
      '{"coord":{"lon":120.9893,"lat":15.7844},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"base":"stations","main":{"temp":${randomDouble(min: 290, max: 310)},"feels_like":296.41,"temp_min":295.14,"temp_max":295.14,"pressure":1014,"humidity":81,"sea_level":1014,"grnd_level":1002},"visibility":10000,"wind":{"speed":2.54,"deg":55},"clouds":{"all":100},"dt":1613912483,"sys":{"country":"PH","sunrise":1613859509,"sunset":1613901674},"timezone":28800,"id":1689431,"name":"San Jose","cod":200}'));

  static List<LatLng?> sampleCoordinates() {
    List<dynamic> json = jsonDecode(
        '[[15.855859413795411, 120.9928647189144], [15.856096788054394, 120.99295591402391], [15.85627223841336, 120.9930578379696],[15.856323841431005, 120.9932455926061],[15.856298039923427, 120.99345480491209],[15.856246436899104, 120.99366938163939],[15.856215475078118, 120.99388932278275],[15.856184513252437, 120.9940717130014],[15.856153551423132, 120.99431311180197],[15.856138070506857, 120.99450623085225],[15.856189673558887, 120.99471544316187],[15.856236116294433, 120.9949031977987],[15.85633416203435, 120.99505340150817],[15.856421887129677, 120.99517141870847],[15.85641672683101, 120.99532698683612],[15.856246436900873, 120.99535917334529],[15.856086467441617, 120.99530552916336]]');
    return json.map((e) => LatLng.fromJson(e)).toList();
  }

  static LatLngBounds sampleLatLngBounds() {
    List<dynamic> json = jsonDecode('[[15.855859413795411,120.9928647189144], [15.856421887129677,120.99535917334529]]');
    return LatLngBounds(southwest: LatLng.fromJson(json[0])!, northeast: LatLng.fromJson(json[1])!);
  }
}

//===================================================================
extension GlobalKeyUtil on GlobalKey {
  ///Gets the offset and size on the widget relative to the global position.
  Rect? get globalPaintBounds {
    final RenderObject? renderObject = currentContext?.findRenderObject()!;
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject?.paintBounds.shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

//==================================================
extension IterableNumUtil on Iterable<num> {
  //Gets the maximum value in a list of num.
  num get getMax => this.fold(this.first, max);
  //Gets the lowest value in a list of num.
  num get getMin => this.fold(this.first, min);
}

//==================================================
///Custom Permission Handler
class AppPermissions {
  ///Request all the permission this application needed.
  static requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.contacts,
      Permission.sms,
    ].request();
    return statuses;
  }

  ///Ask for location permission.
  static requestLocation() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [Permission.location, Permission.locationAlways, Permission.locationWhenInUse].request();
      return statuses;
    } catch (e) {}
  }

  ///Ask for contact permission.
  static requestContacts() async {
    try {
      bool status = await Permission.contacts.request().isGranted;
      return status;
    } catch (e) {}
  }

  ///Ask for sms permission.
  static requestSMS() async {
    try {
      bool status = await Permission.sms.request().isGranted;
      return status;
    } catch (e) {}
  }
}

//=========================================================================
/// The great-circle is shortest distance between two points on the surface of a sphere
/// See [Great-circle distance](https://en.wikipedia.org/wiki/Great-circle_distance)
class GreatCircleDistance {
  double latitude1;
  double longitude1;

  double latitude2;
  double longitude2;

  GreatCircleDistance.fromRadians({required this.latitude1, required this.longitude1, required this.latitude2, required this.longitude2}) {
    this.latitude1 = latitude1;
    this.longitude1 = longitude1;

    this.latitude2 = latitude2;
    this.longitude2 = longitude2;

    _throwExceptionOnInvalidCoordinates();
  }

  GreatCircleDistance.fromDegrees({required this.latitude1, required this.longitude1, required this.latitude2, required this.longitude2}) {
    this.latitude1 = _radiansFromDegrees(latitude1);
    this.longitude1 = _radiansFromDegrees(longitude1);

    this.latitude2 = _radiansFromDegrees(latitude2);
    this.longitude2 = _radiansFromDegrees(longitude2);

    _throwExceptionOnInvalidCoordinates();
  }

  /// Calculate distance using the Haversine formula
  /// The haversine formula determines the great-circle distance between two points on a sphere given their longitudes and latitudes
  /// See [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula)
  double haversineDistance() {
    return Haversine.distance(this.latitude1, this.longitude1, this.latitude2, this.longitude2);
  }

  /// Calculate distance using Spherical law of cosines
  /// See [Spherical law of cosines](https://en.wikipedia.org/wiki/Spherical_law_of_cosines)
  double sphericalLawOfCosinesDistance() {
    return SphericalLawOfCosines.distance(this.latitude1, this.longitude1, this.latitude2, this.longitude2);
  }

  /// Calculate distance using Vincenty formula
  /// Vincenty's formulae are two related iterative methods used in geodesy to calculate the distance between two points on the surface of a spheroid
  /// They are based on the assumption that the figure of the Earth is an oblate spheroid, and hence are more accurate than methods that assume a spherical Earth, such as great-circle distance
  /// See [Vincenty's formulae](https://en.wikipedia.org/wiki/Vincenty%27s_formulae)
  double vincentyDistance() {
    return Vincenty.distance(this.latitude1, this.longitude1, this.latitude2, this.longitude2);
  }

  double _radiansFromDegrees(final double degrees) => degrees * (pi / 180.0);

  /// A coordinate is considered invalid if it meets at least one of the following criteria:
  ///
  /// - Its latitude is greater than 90 degrees or less than -90 degrees.
  ///- Its longitude is greater than 180 degrees or less than -180 degrees.
  bool _isValidCoordinate(double latitude, longitude) => _isValidLatitude(latitude) && _isValidLongitude(longitude);

  /// A latitude is considered invalid if its is greater than 90 degrees or less than -90 degrees.
  bool _isValidLatitude(double latitudeInRadians) =>
      !(latitudeInRadians < _radiansFromDegrees(-90.0) || latitudeInRadians > _radiansFromDegrees(90.0));

  /// A longitude is considered invalid if its is greater than 180 degrees or less than -180 degrees.
  bool _isValidLongitude(double longitudeInRadians) =>
      !(longitudeInRadians < _radiansFromDegrees(-180.0) || longitudeInRadians > _radiansFromDegrees(180.0));

  void _throwExceptionOnInvalidCoordinates() {
    String invalidDescription = """
            A coordinate is considered invalid if it meets at least one of the following criteria:
            - Its latitude is greater than 90 degrees or less than -90 degrees.
            - Its longitude is greater than 180 degrees or less than -180 degrees.
            
            see https://en.wikipedia.org/wiki/Decimal_degrees 
        """;

    if (!_isValidCoordinate(this.latitude1, this.longitude1)) {
      throw new FormatException("Invalid coordinates at latitude1|longitude1\n$invalidDescription");
    }

    {
      if (!_isValidCoordinate(this.latitude2, this.longitude2))
        throw new FormatException("Invalid coordinates at latitude2|longitude2\n$invalidDescription");
    }
  }
}

class Haversine {
  static double distance(double lat1, lon1, lat2, lon2) {
    var earthRadius = 6378137.0; // WGS84 major axis
    double distance = 2 * earthRadius * asin(sqrt(pow(sin(lat2 - lat1) / 2, 2) + cos(lat1) * cos(lat2) * pow(sin(lon2 - lon1) / 2, 2)));
    return distance;
  }
}

class SphericalLawOfCosines {
  static double distance(double lat1, lon1, lat2, lon2) {
    double distance = acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1));
    if (distance < 0) distance = distance + pi;

    var earthRadius = 6378137.0; // WGS84 major axis
    return earthRadius * distance;
  }
}

class Vincenty {
  static double distance(double lat1, lon1, lat2, lon2) {
    // Based on http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
    int maxIters = 20; // Maximum Iteration
    double a = 6378137.0; // WGS84 major axis
    double b = 6356752.3142; // WGS84 semi-major axis
    double f = (a - b) / a;
    double aSqMinusBSqOverBSq = (a * a - b * b) / (b * b);
    double? L = lon2 - lon1;
    double A = 0.0;
    double u1 = atan((1.0 - f) * tan(lat1));
    double u2 = atan((1.0 - f) * tan(lat2));
    double cosU1 = cos(u1);
    double cosU2 = cos(u2);
    double sinU1 = sin(u1);
    double sinU2 = sin(u2);
    double cosU1cosU2 = cosU1 * cosU2;
    double sinU1sinU2 = sinU1 * sinU2;
    double sigma = 0.0;
    double deltaSigma = 0.0;
    double cosSqAlpha = 0.0;
    double cos2SM = 0.0;
    double cosSigma = 0.0;
    double sinSigma = 0.0;
    double cosLambda = 0.0;
    double sinLambda = 0.0;
    double? lambda = L; // initial guess
    for (int iter = 0; iter < maxIters; iter++) {
      double lambdaOrig = lambda!;
      cosLambda = cos(lambda);
      sinLambda = sin(lambda);
      double t1 = cosU2 * sinLambda;
      double t2 = cosU1 * sinU2 - sinU1 * cosU2 * cosLambda;
      double sinSqSigma = t1 * t1 + t2 * t2; // (14)
      sinSigma = sqrt(sinSqSigma);
      cosSigma = sinU1sinU2 + cosU1cosU2 * cosLambda; // (15)
      sigma = atan2(sinSigma, cosSigma); // (16)
      double sinAlpha = (sinSigma == 0) ? 0.0 : cosU1cosU2 * sinLambda / sinSigma; // (17)
      cosSqAlpha = 1.0 - sinAlpha * sinAlpha;
      cos2SM = (cosSqAlpha == 0) ? 0.0 : cosSigma - 2.0 * sinU1sinU2 / cosSqAlpha; // (18)
      double uSquared = cosSqAlpha * aSqMinusBSqOverBSq; // defn
      A = 1 +
          (uSquared / 16384.0) * // (3)
              (4096.0 + uSquared * (-768 + uSquared * (320.0 - 175.0 * uSquared)));
      double B = (uSquared / 1024.0) * // (4)
          (256.0 + uSquared * (-128.0 + uSquared * (74.0 - 47.0 * uSquared)));
      double C = (f / 16.0) * cosSqAlpha * (4.0 + f * (4.0 - 3.0 * cosSqAlpha)); // (10)
      double cos2SMSq = cos2SM * cos2SM;
      deltaSigma = B *
          sinSigma * // (6)
          (cos2SM +
              (B / 4.0) * (cosSigma * (-1.0 + 2.0 * cos2SMSq) - (B / 6.0) * cos2SM * (-3.0 + 4.0 * sinSigma * sinSigma) * (-3.0 + 4.0 * cos2SMSq)));
      lambda = L! + (1.0 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SM + C * cosSigma * (-1.0 + 2.0 * cos2SM * cos2SM))); // (11)
      double delta = (lambda - lambdaOrig) / lambda;
      if (delta.abs() < 1.0e-12) {
        break;
      }
    }
    double distance = (b * A * (sigma - deltaSigma));
    return distance;
  }
  // using the "Inverse Formula
}
