part of '../../screens/guides_screen.dart';

class GuidesButton extends StatelessWidget {
  const GuidesButton({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Expanded(
      flex: 10,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, _size.height * 0.035),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Color(0xFF496D47).darken(0.1).withOpacity(0.8),
          onTap: () {
            Navigator.push(context, CustomRoutes.fadeThrough(page: guidesItem[index].page, duration: Duration(milliseconds: 300)));
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _isPortrait ? 20 : 10,
              ),
              color: Color(0xFF496D47),
            ),
            height: _size.height * 0.10,
            child: index.isOdd
                ? Row(
                    children: [
                      Expanded(
                        flex: 20,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: _isPortrait ? 20.0 : 2.0,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              guidesItem[index].iconPath,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 74,
                        child: Ink(
                          padding: const EdgeInsets.all(5),
                          height: double.infinity,
                          color: const Color(0xFF496D47).darken(0.1),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Center(
                              child: Text(
                                guidesItem[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(flex: 6, child: SizedBox())
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(flex: 6, child: SizedBox()),
                      Expanded(
                        flex: 74,
                        child: Ink(
                          padding: const EdgeInsets.all(5),
                          height: double.infinity,
                          color: Color(0xFF496D47).darken(0.1),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Center(
                              child: Text(
                                guidesItem[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: _isPortrait ? 20.0 : 2.0,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              guidesItem[index].iconPath,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}