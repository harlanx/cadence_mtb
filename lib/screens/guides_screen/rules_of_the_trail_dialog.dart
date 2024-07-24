part of '../../screens/guides_screen.dart';

class RulesOfTheTrailDialog extends StatelessWidget {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.all(1.0),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13.0),
        ),
        height: _size.height * 0.7,
        width: _size.width * 0.9,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(13.0),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF496D47),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 30,
                          child: FittedBox(
                            child: SvgPicture.asset(
                              'assets/icons/guides_dashboard/imba_logo.svg',
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              height: 80,
                              width: 272,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 70,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: AutoSizeText(
                              'Rules of the Trail',
                              wrapWords: true,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(0xFF496D47),
                    width: double.infinity,
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: Container(
                    height: double.maxFinite,
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Center(
                      child: const AutoSizeText(
                        'IMBA developed the "Rules of the Trail" to promote responsible and courteous conduct on shared-use trails.',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Color(0xFF496D47),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 73,
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: rOTTItem.length + 1,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildRottItem(context, index),
                    onPageChanged: (int index) {
                      _currentIndex.value = index;
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: CirclePageIndicator(
                      dotColor: Colors.grey,
                      selectedDotColor: Color(0xFF496D47),
                      itemCount: rOTTItem.length + 1,
                      currentPageNotifier: _currentIndex,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: const Alignment(1.05, -1.05),
              child: Material(
                clipBehavior: Clip.antiAlias,
                shape: CircleBorder(),
                child: Ink(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF496D47),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRottItem(BuildContext context, int index) {
    final ScrollController _scrollController = ScrollController();
    if (index <= 5) {
      return Container(
        child: Column(
          children: [
            Expanded(
              flex: 30,
              child: Center(
                child: AutoSizeText(
                  rOTTItem[index].rule,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: Color(0xFF496D47),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 70,
              child: Container(
                child: Scrollbar(
                  trackVisibility: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: AutoSizeText(
                          rOTTItem[index].description,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF496D47),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              flex: 70,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: AutoSizeText(
                    'Keep trails open by setting a good example of environmentally sound and socially responsible off-road cycling.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: Color(0xFF496D47),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 15,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: 'For more information,\n',
                    children: [
                      WidgetSpan(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomRoutes.fadeThrough(
                                page: AppBrowser(
                                  link:
                                      'https://www.imba.com/explore-imba/meet-imba/',
                                ),
                              ),
                            );
                          },
                          child: AutoSizeText(
                            "visit the webpage of IMBA.",
                            maxLines: 1,
                            style: TextStyle(
                              shadows: [
                                const Shadow(
                                    color: Color(0xFF496D47),
                                    offset: Offset(0, -5))
                              ],
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF496D47).darken(0.1),
                              decorationThickness: 2,
                              fontWeight: FontWeight.w700,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF496D47),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
