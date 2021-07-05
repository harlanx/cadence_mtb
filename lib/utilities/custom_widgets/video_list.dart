//Video List for Body Conditioning and Repair and Maintenance
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/youtube_videos.dart';
import 'package:cadence_mtb/pages/video_player.dart';
import 'package:cadence_mtb/utilities/widget_helper.dart';
import 'package:flutter/material.dart';

class VideoList extends StatelessWidget {
  const VideoList({
    Key? key,
    required this.isPortrait,
    required this.screenSize,
    required this.videoList,
  }) : super(key: key);

  final bool isPortrait;
  final Size screenSize;
  final List<VideoItem>? videoList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: videoList!.isEmpty ? 1 : videoList!.length,
      itemBuilder: (BuildContext context, int index) {
        if (videoList!.isEmpty) {
          return Center(
            child: Text('No Result'),
          );
        } else {
          if (isPortrait) {
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        CustomRoutes.fadeThrough(
                          page: VideoPlayerPage(videoItem: videoList![index]),
                          duration: Duration(milliseconds: 300),
                        ),
                      ),
                      child: Container(
                        height: screenSize.height * 0.3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: videoList![index].snippet!.thumbnails!.maxres!.url!,
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white.withOpacity(0.6),
                                size: 80,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        childrenPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        tilePadding: EdgeInsets.symmetric(horizontal: 10.0),
                        textColor: Color(0xFF496D47),
                        iconColor: Color(0xFF496D47),
                        title: Text(
                          videoList![index].snippet!.title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          maxLines: 2,
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              videoList![index].snippet!.description,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ListTile(
              dense: true,
              onTap: () {
                Navigator.push(
                  context,
                  CustomRoutes.fadeThrough(
                    page: VideoPlayerPage(videoItem: videoList![index]),
                    duration: Duration(milliseconds: 300),
                  ),
                );
              },
              leading: CachedNetworkImage(
                imageUrl: videoList![index].snippet!.thumbnails!.maxres!.url!,
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: 60,
                fit: BoxFit.cover,
              ),
              title: Text(
                videoList![index].snippet!.title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                maxLines: 1,
                softWrap: true,
              ),
              subtitle: Text(
                videoList![index].snippet!.description,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
              ),
              trailing: Icon(Icons.play_arrow),
            );
          }
        }
      },
    );
  }
}