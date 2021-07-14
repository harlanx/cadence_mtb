part of '../../pages/organizations.dart';

class OrganizationDialog extends StatelessWidget {
  OrganizationDialog({required this.item});
  final OrganizationsItem item;
  @override
  Widget build(BuildContext context) {
    bool _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Size _size = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      contentPadding: EdgeInsets.all(10),
      insetPadding: EdgeInsets.all(1.0),
      content: Container(
        width: _size.width * 0.8,
        height: _size.height * 0.6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _isPortrait
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 70,
                        child: CachedNetworkImage(
                          imageUrl: item.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: double.infinity,
                          child: Center(
                            child: AutoSizeText(
                              item.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 40,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 50,
                              child: Center(
                                child: AutoSizeText(
                                  'Location:',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 50,
                              child: Center(
                                child: AutoSizeText(
                                  item.location,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 15,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {},
                          child: Center(
                            child: TextButton(
                              child: AutoSizeText('Visit Facebook Group / Page'),
                              style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                foregroundColor: MaterialStateProperty.all(Colors.white),
                                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF4267B2)),
                                overlayColor: MaterialStateProperty.resolveWith<Color>(
                                    (states) => states.contains(MaterialState.pressed) ? Color(0xFF4267B2).darken(0.1) : Colors.transparent),
                                shape: MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                FunctionHelper.launchURL(item.link);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 50,
                        child: CachedNetworkImage(
                          imageUrl: item.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        flex: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 40,
                              child: Container(
                                width: double.infinity,
                                child: Center(
                                  child: AutoSizeText(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 40,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 50,
                                    child: Center(
                                      child: AutoSizeText(
                                        'Location:',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 50,
                                    child: Center(
                                      child: AutoSizeText(
                                        item.location,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 40,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {},
                                child: Center(
                                  child: TextButton(
                                    child: AutoSizeText('Visit Facebook Group / Page'),
                                    style: ButtonStyle(
                                      textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                      foregroundColor: MaterialStateProperty.all(Colors.white),
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF4267B2)),
                                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                                          (states) => states.contains(MaterialState.pressed) ? Color(0xFF4267B2).darken(0.1) : Colors.transparent),
                                      shape: MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      FunctionHelper.launchURL(item.link);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.close,
                    color: Color(0xFF496D47),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
