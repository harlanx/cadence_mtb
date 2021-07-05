import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageViewer extends StatelessWidget {
  final String imagePath;
  final int imageIndex;
  ImageViewer({required this.imagePath, required this.imageIndex});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.black),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          body: Container(
            color: Colors.black,
            child: SizedBox.expand(
              child: InteractiveViewer(
                child: Hero(
                  tag: 'trailItemImage$imageIndex',
                  child: CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                minScale: 1.0,
                maxScale: 5.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}