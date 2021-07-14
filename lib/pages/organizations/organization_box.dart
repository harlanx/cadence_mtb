part of '../../pages/organizations.dart';

class OrganizationBox extends StatelessWidget {
  OrganizationBox({Key? key, required this.item}) : super(key: key);
  final OrganizationsItem item;

  @override
  Widget build(BuildContext context) {
    return Ink.image(
      image: CachedNetworkImageProvider(item.logo),
      fit: BoxFit.contain,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Color(0xFF496D47).withOpacity(0.8),
        onTap: () {
          showModal(
            context: context,
            configuration: FadeScaleTransitionConfiguration(
              barrierDismissible: true,
            ),
            builder: (context) => OrganizationDialog(item: item),
          );
        },
      ),
    );
  }
}