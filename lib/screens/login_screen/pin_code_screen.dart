part of '../../screens/login_screen.dart';

class PinCodeScreen extends StatefulWidget {
  final UserProfile user;
  final Function? onCorrect;
  final Function? onWrong;
  PinCodeScreen({required this.user, this.onCorrect, this.onWrong});
  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final TextEditingController pinController = TextEditingController();
  bool isPinCodeWrong = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Color(0xFF496D47),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type your pin to enter',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF496D47),
              ),
            ),
            PinCodeTextField(
              autoDisposeControllers: false,
              controller: pinController,
              keyboardType: TextInputType.number,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              backgroundColor: Colors.transparent,
              animationType: AnimationType.scale,
              obscureText: true,
              obscuringWidget: SvgPicture.asset(
                'assets/images/navigate/wheel.svg',
                fit: BoxFit.contain,
                color: Color(0xFF496D47),
              ),
              pinTheme: PinTheme(
                activeColor: Color(0xFF496D47),
                inactiveColor: Colors.grey,
                selectedColor: Color(0xFF496D47),
              ),
              appContext: context,
              length: 4,
              onChanged: (value) async {
                if (value.length >= 4) {
                  if (value == widget.user.pinCode) {
                    if (widget.onCorrect != null) {
                      widget.onCorrect!();
                    }
                  } else {
                    if (widget.onWrong != null) {
                      widget.onWrong!();
                    }
                    setState(() {
                      isPinCodeWrong = true;
                    });
                  }
                } else {
                  if (widget.onWrong != null) {
                    widget.onWrong!();
                  }
                  setState(() {
                    isPinCodeWrong = false;
                  });
                }
              },
            ),
            Visibility(
              visible: isPinCodeWrong,
              child: Text(
                'Wrong Pin Code',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}