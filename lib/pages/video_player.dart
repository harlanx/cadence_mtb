import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/services/youtube_service.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  VideoPlayerPage({required this.videoItem});
  final VideoItem videoItem;

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  NumberFormat numFormat = NumberFormat('#,###', 'fil');
  late YoutubePlayerController _controller;
  late IconData backIcon;
  late Future<YoutubeChannel> _futureHolder;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoItem.snippet!.resourceId!.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        isLive: false,
        enableCaption: false,
      ),
    );

    _futureHolder = _fetchChannelInfo();
    backIcon = _controller.value.isFullScreen ? Icons.arrow_back_ios : Icons.close;
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    }
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        setState(() {
          backIcon = _controller.value.isFullScreen ? Icons.arrow_back_ios : Icons.close;
        });
      },
      onExitFullScreen: () {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        setState(() {
          backIcon = _controller.value.isFullScreen ? Icons.arrow_back_ios : Icons.close;
        });
      },
      player: YoutubePlayer(
        controller: _controller,
        onEnded: (metaData) {
          setState(() {
            _controller.seekTo(Duration.zero);
            _controller.pause();
          });
        },
        topActions: [
          IconButton(
            icon: Icon(
              backIcon,
              color: Colors.white,
            ),
            onPressed: () {
              if (_controller.value.isFullScreen) {
                SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          PlaybackSpeedButton(
            controller: _controller,
            icon: Icon(
              Icons.speed,
              color: Colors.white,
            ),
          ),
        ],
        bottomActions: [
          CurrentPosition(
            controller: _controller,
          ),
          ProgressBar(
            controller: _controller,
            isExpanded: true,
            colors: ProgressBarColors(
              bufferedColor: Colors.grey,
              playedColor: Color(0xFF496D47),
              backgroundColor: Colors.white,
              handleColor: Color(0xFF496D47).darken(0.1),
            ),
          ),
          RemainingDuration(
            controller: _controller,
          ),
          FullScreenButton(
            controller: _controller,
            color: Colors.white70,
          ),
        ],
      ),
      builder: (context, player) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(statusBarColor: Color(0xFF496D47), statusBarIconBrightness: Brightness.light),
          child: SafeArea(
            bottom: false,
            child: Scaffold(
              body: Column(
                children: [
                  player,
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        FutureBuilder<YoutubeChannel>(
                          future: _futureHolder,
                          builder: (_, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return SizedBox.shrink();
                                }
                                return ListTileTheme(
                                  contentPadding: EdgeInsets.zero,
                                  child: ListTile(
                                    leading: CachedNetworkImage(
                                      imageUrl: snapshot.data!.items!.first.snippet!.thumbnails!.high!.url!,
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                      placeholder: (context, url) => Icon(Icons.person),
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.contain,
                                    ),
                                    title: Text(
                                      snapshot.data!.items!.first.snippet!.title!,
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    subtitle: !snapshot.data!.items!.first.statistics!.hiddenSubscriberCount!
                                        ? Text(
                                            'Subscribers: ${numFormat.format(int.parse(snapshot.data!.items!.first.statistics!.subscriberCount!))}',
                                            style: TextStyle(fontWeight: FontWeight.w400),
                                          )
                                        : SizedBox.shrink(),
                                    trailing: TextButton(
                                      child: Text('Visit Channel'),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color(0xFFFF0000),
                                        shadowColor: Color(0xFFFF0000).darken(0.1),
                                        primary: Colors.white,
                                        textStyle: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () {
                                        FunctionHelper.launchURL('https://www.youtube.com/channel/${widget.videoItem.snippet!.videoOwnerChannelId}');
                                      },
                                    ),
                                  ),
                                );

                              default:
                                return SizedBox.shrink();
                            }
                          },
                        ),
                        Text(
                          widget.videoItem.snippet!.title,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            widget.videoItem.snippet!.description,
                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<YoutubeChannel> _fetchChannelInfo() async {
    return await YoutubeService.getChannelInfo(channelID: widget.videoItem.snippet!.videoOwnerChannelId);
  }
}
