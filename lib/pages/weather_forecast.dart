import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherForecast extends StatelessWidget {
  final LatLng coordinates;
  final Weather weather;

  final WeatherFactory wf = WeatherFactory(Constants.openWeatherMapApiKey,
      language: Language.ENGLISH);
  WeatherForecast({required this.coordinates, required this.weather});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: Theme.of(context).brightness == Brightness.light
                ? IconThemeData(color: Colors.black)
                : Theme.of(context).appBarTheme.iconTheme,
            elevation: 0,
            title: Text(
              DateFormat('EEEE MMMM d, yyyy').format(weather.date!),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 80,
                              child: FutureBuilder<String>(
                                future: _exactAreaName(),
                                builder: (ctx, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.done:
                                      if (snapshot.hasError) {
                                        return SizedBox.shrink();
                                      } else {
                                        return FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            snapshot.data!,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 25,
                                            ),
                                          ),
                                        );
                                      }

                                    default:
                                      return SizedBox.shrink();
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 20,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '${coordinates.latitude.toStringAsFixed(5)}, ${coordinates.longitude.toStringAsFixed(5)}',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Opacity(
                                    opacity: 0.8,
                                    child: CachedNetworkImage(
                                      color: Colors.black,
                                      placeholder: (context, string) =>
                                          SpinKitDoubleBounce(
                                              color: Colors.white),
                                      imageUrl:
                                          'http://openweathermap.org/img/wn/' +
                                              weather.weatherIcon! +
                                              '@2x.png',
                                      errorWidget: (context, string, url) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 1.0, sigmaY: 1.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, string) =>
                                            SpinKitDoubleBounce(
                                                color: Colors.white),
                                        imageUrl:
                                            'http://openweathermap.org/img/wn/' +
                                                weather.weatherIcon! +
                                                '@2x.png',
                                        errorWidget: (context, string, url) =>
                                            Icon(Icons.error),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              weather.weatherDescription!.toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 50,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${weather.temperature!.celsius!.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 50,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  //color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 50,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'MIN',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '${weather.tempMin!.celsius!.toStringAsFixed(1)}°',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'MAX',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '${weather.tempMax!.celsius!.toStringAsFixed(1)}°',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'FEELS LIKE',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${weather.tempFeelsLike!.celsius!.toStringAsFixed(1)}°',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 25,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'WIND',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      weather.windSpeed != null
                                          ? '${weather.windSpeed!.toStringAsFixed(1)}m/s'
                                          : 'N/A',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'HUMIDITY',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      weather.humidity != null
                                          ? '${weather.humidity}%'
                                          : 'N/A',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'SUNRISE',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      weather.sunrise != null
                                          ? DateFormat.jm()
                                              .format(weather.sunrise!)
                                          : 'N/A',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'SUNSET',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      weather.sunset != null
                                          ? DateFormat.jm()
                                              .format(weather.sunset!)
                                          : 'N/A',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 25,
                        child: SizedBox.expand(
                          child: LayoutBuilder(
                            builder: (_, constraints) {
                              return FutureBuilder<List<Weather>>(
                                future: _fetchForecast(),
                                builder: (_, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.done:
                                      if (snapshot.hasError) {
                                        return SizedBox.shrink();
                                      } else {
                                        List<Widget> items = [];
                                        snapshot.data!.forEach((element) {
                                          items
                                            ..add(Column(
                                              children: [
                                                Text(
                                                  element.date != null
                                                      ? DateFormat('EEE, h a')
                                                          .format(element.date!)
                                                      : 'N/A',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  element.temperature!
                                                              .celsius !=
                                                          null
                                                      ? '${element.temperature!.celsius!.toStringAsFixed(1)}°'
                                                      : 'N/A',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ))
                                            ..add(VerticalDivider(
                                              color: Colors.grey,
                                              thickness: 1,
                                            ));
                                        });
                                        items.removeLast();
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics: BouncingScrollPhysics(),
                                          child: FittedBox(
                                            fit: BoxFit.fitHeight,
                                            child: IntrinsicHeight(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: items,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    default:
                                      return SizedBox.shrink();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Weather>> _fetchForecast() async {
    List<Weather> forecastResult = [];
    await wf
        .fiveDayForecastByLocation(coordinates.latitude, coordinates.longitude)
        .then((result) {
      forecastResult = result;
    }).catchError((e) {
      forecastResult = <Weather>[];
    });
    return forecastResult;
  }

  Future<String> _exactAreaName() async {
    String _areaName = '';
    await GeocodingPlatform.instance
        ?.placemarkFromCoordinates(coordinates.latitude, coordinates.longitude)
        .then((result) {
      if (result.elementAt(0).locality!.isNotEmpty) {
        _areaName =
            '${result.elementAt(0).name}, ${result.elementAt(0).locality}';
      } else {
        _areaName = weather.areaName ?? '';
      }
    }).catchError((e) {
      _areaName = weather.areaName ?? '';
    });
    return _areaName;
  }
}
