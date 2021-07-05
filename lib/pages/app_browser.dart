import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppBrowser extends StatelessWidget {
  final String link;
  final int purpose;
  AppBrowser({
    required this.link,
    this.purpose = 1,
  }) : assert(purpose > 0 && purpose <= 4, 'Select purpose from 1 to 4 only.');

  final Completer<WebViewController> completer = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: appBarColor(purpose), statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: appBarColor(purpose),
          ),
          body: WebView(
            initialUrl: link,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              completer.complete(controller);
            },
          ),
        ),
      ),
    );
  }

  Color appBarColor(int purpose) {
    if (purpose == 1) {
      //Default App Color
      return Color(0xFF496D47);
    } else if (purpose == 2) {
      //Trails Color
      return Color(0xFFB8784B);
    } else if (purpose == 3) {
      //First Aid Color
      return Color(0xFFF15024);
    } else if (purpose == 4) {
      //Bike Editor
      return Color(0xFFFF8B02);
    } else {
      //Default App Color
      return Color(0xFF496D47);
    }
  }
}
