part of '../../screens/home_screen.dart';

//We don't need to pass the snapshot since we are accessing the homeVideosList which is a global list.
//We only used the future to notify the builder when to build the widget.
class _HomeVideoCarousel extends StatelessWidget {
  _HomeVideoCarousel({
    Key? key,
    required this.videos,
    required this.isPortrait,
  }) : super(key: key);
  final bool isPortrait;
  final List<VideoItem> videos;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: AlwaysScrollableScrollPhysics(),
      child: Align(
        alignment: Alignment.topCenter,
        child: CarouselSlider.builder(
          itemCount: videos.length,
          options: CarouselOptions(
            scrollPhysics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            aspectRatio: isPortrait ? 16 / 9 : 16 / 4,
            initialPage: 0,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            viewportFraction: isPortrait ? 0.7 : 0.38,
          ),
          itemBuilder: (_, itemIndex, __) {
            return OpenContainer(
              closedElevation: 0,
              closedColor: Colors.transparent,
              closedBuilder: (_, action) {
                return InkWell(
                  onTap: () => action(),
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: isPortrait ? BorderRadius.circular(25) : BorderRadius.circular(15),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 65,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: videos[itemIndex].snippet!.thumbnails!.maxres!.url!,
                                errorWidget: (_, url, error) => Icon(Icons.error),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_circle_outline_rounded,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 35,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: isPortrait ? 15 : 5,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 30,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: AutoSizeText(
                                      videos[itemIndex].snippet!.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 70,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: AutoSizeText(
                                      videos[itemIndex].snippet!.description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
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
                );
              },
              openBuilder: (_, __) {
                return VideoPlayerPage(videoItem: videos[itemIndex]);
              },
            );
          },
        ),
      ),
    );
  }
}