part of '../../screens/login_screen.dart';

class DeleteProfile extends StatelessWidget {
  DeleteProfile({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Deleting profile data, please wait.'),
          SpinKitCircle(
            color: Color(0xFF496D47),
          ),
        ],
      ),
    );
  }
}