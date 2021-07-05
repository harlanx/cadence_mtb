import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArticleViewer extends StatelessWidget {
  ArticleViewer({required this.articleItem, required this.articleType});
  final ArticleItem articleItem;
  final int articleType;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: articleType == 1 ? Color(0xFF496D47) : Color(0xFFF15024)),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: AutoSizeText(
              articleItem.title,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: articleType == 1 ? Color(0xFF496D47) : Color(0xFFF15024),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: articleItem.widget,
          ),
          floatingActionButton: (!sosEnabled['First Aid']! || !sosEnabled['Tips and Benefits']!)
              ? null
              : DraggableFab(
                  child: EmergencyButton(),
                ),
        ),
      ),
    );
  }
}
