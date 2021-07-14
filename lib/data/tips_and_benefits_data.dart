import 'package:auto_size_text/auto_size_text.dart';
import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/app_browser.dart';
import 'package:cadence_mtb/utilities/function_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> tabKey = GlobalKey<ScaffoldState>();
List<ArticleItem> tipsItems = [
  //TIPS LIST
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/body_position.jpg',
    title: 'Body Position',
    subtitle:
        'The variable terrain and the potential obstacles are all part of the fun but can be unnerving to beginners. Being in the right body position helps you get through tricky sections of trail.',
    widget: ListView(
      //Body Position
      children: [
        Hero(
          tag: 'tipsItem0',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/body_position.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Louise Kande Pedersen',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/mtb-mountain-bike-sports-active-2844377',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Perhaps the biggest key to successful mountain biking is your body position. \n\nMountain bike trail surfaces include rocks, roots, ruts, sand or mud. The variable terrain and the potential obstacles are all part of the fun but can be unnerving to beginners. Being in the right body position helps you get through tricky sections of trail.\n\nThere are two primary body positions: neutral and ready.\n\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Neutral Position',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          child: AutoSizeText(
            '\nWhen you’re riding non-technical sections of trail, you want to be in a neutral position on the bike. This keeps you rolling along efficiently and comfortably while allowing you to easily transition into the ready position for technical terrain.\nThe neutral position includes: \n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: AutoSizeText(
            '•Level pedals that are evenly weighted\n•A slight bend in the knees and elbows\n•Index fingers on the brake levers 100% of the time (rim brakes often require 2 fingers).\n•Eyes looking forward about 15 to 20 ft. ahead; look where you want to go, not where you don’t.\n\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Ready Position',
            textAlign: TextAlign.left,
            maxLines: 1,
            minFontSize: 20,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          child: AutoSizeText(
            '\nWhen the trail gets steeper or rockier, it’s time to move into the ready position (sometimes called the attack position). The ready position gets you mentally and physically prepared to take on technical sections of trail.\nThe ready position includes: \n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: AutoSizeText(
            '•Level pedals that are evenly weighted\n•A deep bend in the knees and elbows (think of making chicken wings with your arms with a 90-degree bend.)\n•Rear end off the seat and hips shifted back\n•Your back is flat and nearly parallel to the ground\n•Index fingers on the brake levers 100% of the time (rim brakes often require 2 fingers)\n•Eyes forward looking about 15 to 20 ft. ahead; look where you want to go, not where you don’t',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/adjusting_seat_position.jpg',
    title: 'Adjusting Your Seat Position',
    subtitle: 'Positioning your seat properly can help you get in the correct body position for climbing and descending.',
    widget: ListView(
      //Adjusting Your Seat Position
      children: [
        Hero(
          tag: 'tipsItem1',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/adjusting_seat_position.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by stux',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/mountain-bike-bike-wheel-cycling-1204868',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(
                  text: ' / Cropped bike seat and added adjustment indication from original',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Positioning your seat properly can help you get in the correct body position for climbing and descending.\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Climbing: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      'For climbing, position your seat for maximum efficiency while pedaling. With your foot at the bottom of the pedal stroke, you should see a slight bend in the leg, reaching about 80-90 percent of full leg extension. This helps you pedal efficiently and powerfully using your major leg muscles.\n',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
        Container(
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Descending: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      'When it’s time to descend, drop your seat about 2 or 3 inches from the height you set it at for climbing hills. Lowering your seat lowers your center of gravity, which gives you better control and more confidence through steep descents. You may need to experiment with different seat heights to find what feels best.',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/picking_a_line.jpg',
    title: 'Picking a Line',
    subtitle:
        'A beginner\'s mistake is looking at spots you want to avoid rather than focusing on where you want to go. Pick a path and stick to it to get over and around tricky sections of trail.',
    widget: ListView(
      //Picking a Line
      children: [
        Hero(
          tag: 'tipsItem2',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/picking_a_line.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Photo by Marcello Gamez',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://unsplash.com/photos/WUEZUtjIHZQ',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' on '),
                TextSpan(
                  text: 'Unsplash',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://unsplash.com/license',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(
                  text: ' / Colored lines added from original',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'A beginner\'s mistake is looking at spots you want to avoid rather than focusing on where you want to go. Pick a path and stick to it to get over and around tricky sections of trail.\n\nWhat hazards should you look for? That depends on your skill level. A log that will stop one cyclist may be a fun bunnyhop for another. Generally, look for loose rocks, deep sand, water, wet roots, logs and other cyclists, hikers, and animals.\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'To find your line:  ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      'scan ahead for hazards by looking about 15 – 20 ft. down the trail. Then, move your eyes back toward your tire. Doing this up-and-back action allows your eyes to take in lots of information. Knowing hazards ahead of time can help you adjust your balance and pick a line around them.',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/braking.jpg',
    title: 'Braking',
    subtitle: 'Learning more about how to brake goes a long way in making you more comfortable and secure on the bike.',
    widget: ListView(
      //Braking
      children: [
        Hero(
          tag: 'tipsItem3',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/braking.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Bearded cyclist riding bicycle by Roman Pashkovsky',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://depositphotos.com/126064748/stock-photo-bearded-cyclist-riding-bicycle.html',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' on '),
                TextSpan(
                  text: 'DepositPhotos',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://depositphotos.com/free-license-with-attribution.html',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Braking seems simple: you squeeze the levers and the bike slows down. That is the gist of it, but learning more about how to brake goes a long way in making you more comfortable and secure on the bike.\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText(
            'How to Brake',
            textAlign: TextAlign.left,
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Braking should be consistent and controlled. Most of your braking power comes from your front brake, but grabbing a handful of front brake will send you over the bars. Instead, lightly apply the brakes, and do so evenly on the front and back brakes. Avoid sudden, fast squeezes to help prevent skidding.\n\nWhile braking, brace yourself by moving your hips back, dropping your heels down and keeping a slight bend in your knees and elbows. This body position helps you stay in control and from getting too far forward on the bike.\n\nIf your mountain bike has disc brakes, keep the index finger of each hand on the brake levers and your other three fingers on the handlebar grips. This gives you sufficient braking power and control while riding. If you have rim brakes, try two fingers on the brake levers since they typically require more force to engage the brakes\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText(
            'When to Brake',
            textAlign: TextAlign.left,
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          child: AutoSizeText(
            'When approaching a turn, brake before you hit the turn, and then let your momentum carry you through. This allows you to focus on your technique through the turn and exit the turn with speed.\n\nMomentum can also be your friend when getting up and over obstacles in the trail. Beginner riders often slow way down when approaching obstacles. Controlled momentum can help you get through these tricky sections of trail.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/shifting.jpg',
    title: 'Shifting',
    subtitle: 'Since most mountain biking involves at least some ups and downs, it’s good to know how to shift your gears properly.',
    widget: ListView(
      //Shifting
      children: [
        Hero(
          tag: 'tipsItem4',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/shifting.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: AutoSizeText(
            'Since most mountain biking involves at least some ups and downs, it’s good to know how to shift your gears properly. Proper shifting habits not only save wear and tear on your bike (especially your chain, front cassette and rear cogs), they enable you to power yourself more efficiently up and down hills.\n',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        Container(
          child: AutoSizeText.rich(
            TextSpan(
              text: 'Shift often:  ',
              style: TextStyle(fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text:
                      'Beginning riders should practice frequent gear shifting. This builds muscle memory so you can intuitively shift up or down as needed without having to think about whether you’re shifting to an easier or more difficult gear.\n',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
        Container(
          child: AutoSizeText.rich(
            TextSpan(
              text: 'Shift early:  ',
              style: TextStyle(fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text:
                      'Don’t wait to shift until you’ve already started up that big hill. Always shift to the gear you will need before you hit the steep terrain. This allows you to keep a steady cycling cadence for maximum power. It also prevents awkward shifting under a load that is hard on your gears and could cause your chain to pop off.\n\nIf you have trouble finding the right gear for the terrain you’re riding, err on the side of spinning in an easier gear than mashing in a hard gear.\n',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
        Container(
          child: AutoSizeText.rich(
            TextSpan(
              style: TextStyle(fontWeight: FontWeight.w400),
              children: [
                TextSpan(
                  text: 'Another important rule is to prevent ',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                TextSpan(
                  text: 'cross-chaining. ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      'This occurs when your chain is stretched awkwardly across from the small chainring in the front to the small cog in the rear, or the big chainring in the front to the big cog in the rear. This holds true for double and triple chainring setups. Cross-chaining can result in your chain popping off from the strain; it also stretches your chain over time, shortening its lifespan.\n',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Finally, always remember to keep pedaling as you are shifting. Not pedaling as you shift can damage or break the chain.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/falling_off.jpg',
    title: 'Falling Off',
    subtitle: 'No one likes to fall off a bike, but if you’re mountain biking, it’ll probably happen at some point.',
    widget: ListView(
      //Falling Off
      children: [
        Hero(
          tag: 'tipsItem5',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/falling_off.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Martin Vorel',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://libreshot.com/en/bicycle-accident',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'CC0',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://creativecommons.org/licenses/publicdomain/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ', from Libreshot'),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'No one likes to fall off a bike, but if you’re mountain biking, it’ll probably happen at some point.\n\nWhen you fall off your bike, try to keep your arms in. Your instinct may be to reach out to brace your fall, but this can result in a broken wrist or collarbone.\n\nDuring a fall, most damage is limited to personal pride. Pick yourself up, dust off and check to make sure you’re not injured. Then check your bike. The seat or handlebar may have twisted and the chain may have come off.\n\nCheck your brakes and gears, too, before charging on. A trailside repair or adjustment may be needed, so it’s wise to carry a multi-tool and a small first-aid kit to patch any personal scrapes.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/tips/hiking_the_bike.jpg',
    title: 'Hiking the Bike',
    subtitle: 'As you ride the trails, you’re bound to get into a tight spot eventually. If you get in a rut on the trail, don\'t "fight the bike."',
    widget: ListView(
      //Hiking the Bike
      children: [
        Hero(
          tag: 'tipsItem6',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/tips/hiking_the_bike.jpg',
            fit: BoxFit.cover,
            height: 300,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Rear view of trial bikers carrying bikes by ',
                ),
                TextSpan(
                  text: 'Artur Verkhovetskiy',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://depositphotos.com/199793150/stock-photo-rear-view-trial-bikers-carrying.html',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' on '),
                TextSpan(
                  text: 'DepositPhotos',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://depositphotos.com/free-license-with-attribution.html',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'As you ride the trails, you’re bound to get into a tight spot eventually. If you get in a rut on the trail, don\'t "fight the bike." Just do your best to ride it out. Impossible? There’s no shame in stopping and walking it out. Walking is absolutely an accepted part of mountain biking. Many trails feature mandatory hike-a-bike sections that are too difficult to ride through, up or down.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
];

final List<ArticleItem> benefitsItems = [
  //BENEFITS LIST
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/improved_heart_health.jpg',
    title: 'Improved Heart Health',
    subtitle: 'Regular exercise is known to improve cardiovascular fitness. ',
    widget: ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: Hero(
            tag: 'benefitsItem0',
            child: Image.asset(
              'assets/images/tips_and_benefits_previews/benefits/improved_heart_health.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Regular exercise is known to improve cardiovascular fitness. The British Medical Association studied 10,000 people and showed that riding a bicycle for at least 20 miles a week lessened the risk of coronary heart disease by almost 50%.\n\nMountain biking uses large muscle groups that require a lot of oxygen. This makes the heart work steadily, increasing your heart’s fitness by 3-7%.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/less_stress_on_the_joints.jpg',
    title: 'Less Stress on the Joints',
    subtitle: 'Mountain biking is a low impact sport, meaning it puts less stress on your joints than other aerobic activities such as running.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem1',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/less_stress_on_the_joints.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Laboratoires Servier',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          tabKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Joints_1_--_Smart-Servier.png',
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 3.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          tabKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/3.0',
                            ),
                          ),
                        );
                      }),
                TextSpan(
                  text: ', via Wikimedia Commons',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Mountain biking is a low impact sport, meaning it puts less stress on your joints than other aerobic activities such as running. Cycling is also considered a non-load bearing sport, which means that the act of sitting takes pressure off of your joints and reduces the risk of injuring them.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/decreased_risk_of_diseases.jpg',
    title: 'Decreased Risk of Diseases',
    subtitle: 'Regular moderate exercise is known to strengthen your immune system and keep you healthy.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem2',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/decreased_risk_of_diseases.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Ian Furst',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          tabKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://commons.wikimedia.org/wiki/File:Immunity_graphic.png',
                            ),
                          ),
                        );
                      }),
                TextSpan(text: ', '),
                TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          tabKey.currentContext!,
                          CustomRoutes.fadeThrough(
                            page: AppBrowser(
                              link: 'https://creativecommons.org/licenses/by-sa/4.0',
                            ),
                          ),
                        );
                      }),
                TextSpan(
                  text: ', via Wikimedia Commons',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Regular moderate exercise is known to strengthen your immune system and keep you healthy. Researchers at the University of North Carolina found that people who cycle for 30 minutes, 5 days a week take half as many sick days off work compared to their sedentary counterparts!\n\nAnother study published in the European Journal of Epidemiology reported that women who exercised regularly, including cycling to work, reduced their incidence of breast cancer.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/reduced_stress_and_improved_mood.jpg',
    title: 'Reduced Stress and Improved Mood',
    subtitle:
        'The vigorous demands of mountain biking stimulate your body to release natural endorphins, which are the body’s way of feeling good and getting more energy.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem3',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/reduced_stress_and_improved_mood.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Maurice Müller',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/man-human-face-person-eyes-1053676/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'The vigorous demands of mountain biking stimulate your body to release natural endorphins, which are the body’s way of feeling good and getting more energy. Exercise also boosts serotonin, an important neurotransmitter in the brain which helps to prevent depression and anxiety.\n\nThe focus and attention needed to ride a challenging single-track can become a form of moving meditation; ultimately helping to relax and weather life’s stressors by acting as a distraction from negative thoughts that may contribute to anxiety and depression. Gaining new skills and improving your mountain biking abilities also helps to build confidence and self-esteem.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/increased_brain_power.jpg',
    title: 'Increased Brain Power',
    subtitle:
        'Researchers at Illinois University found that a 5% improvement in cardio-respiratory fitness from cycling led to an improvement of up to 15% on mental tests.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem4',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/increased_brain_power.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Gerd Altmann',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/illustrations/artificial-intelligence-brain-think-5261742/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Researchers at Illinois University found that a 5% improvement in cardio-respiratory fitness from cycling led to an improvement of up to 15% on mental tests. This is in part due to building brain cells in the hippocampus – the region of the brain responsible for memory. “It boosts blood flow and oxygen to the brain, which fires and regenerates receptors, explaining how exercise helps ward off Alzheimer’s,” Professor Arthur Kramer said.\n\nCreative professionals and executives often use their sharpened brain function during exercise time to come up with ideas and solve problems.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/improved_balance_and_coordination.jpg',
    title: 'Improved balance and coordination',
    subtitle:
        'Unlike plodding on a treadmill or stair stepper, mountain biking is a dynamic activity that requires the rider to constantly adjust to varying terrain, pitch, and elevation.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem5',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/improved_balance_and_coordination.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Pexels',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/action-adventure-bicycle-bicyclist-1839225/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'Unlike plodding on a treadmill or stair stepper, mountain biking is a dynamic activity that requires the rider to constantly adjust to varying terrain, pitch, and elevation. Staying steady and secure on a mountain bike not only keeps you from crashing, but strengthens neural pathways and reinforces muscle memory.\n\nBalance and coordination requires the combined resources of the brain, senses, muscles and nervous system. Keeping these systems active as we get older staves off disability from aging and reduces the risk of injury from falls.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/whole_body_workout.jpg',
    title: 'Whole Body Workout',
    subtitle:
        'It’s no doubt you’ll recognize the defined calf muscles of an avid cyclist, but you may not realize that mountain biking uses the muscles of your whole body.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem6',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/whole_body_workout.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Fabricio Macedo FGMsp',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/bike-mountain-mountain-biking-trail-1541037/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'It’s no doubt you’ll recognize the defined calf muscles of an avid cyclist, but you may not realize that mountain biking uses the muscles of your whole body. Of course, cycling builds strong legs, thighs and calves and helps you get that nice tight butt.\n\nThe balance required to stay upright strengthens your abdominal and core muscles. Climbing and maneuvering turns also strengthens your upper body. And as an added bonus, mountain biking doesn’t require an expensive gym membership or a personal trainer to get a good workout.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/sleep_better.jpg',
    title: 'Sleep Better',
    subtitle:
        'You may immediately feel tired and worn out after a ride, but it will ultimately lead to improved regenerative sleep when you need it at night.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem7',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/sleep_better.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Hatice EROL',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/illustrations/sleep-man-bed-asleep-sleeping-5823849/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'You may immediately feel tired and worn out after a ride, but it will ultimately lead to improved regenerative sleep when you need it at night. The exercise of riding decreases cortisol, a hormone that keeps us awake. Being an outdoor activity, mountain biking exposes you to daylight which helps to maintain the body’s natural circadian sleep/wake cycle, not to mention raising your body’s production of vitamin D.\n\nMake sure you avoid vigorous rides too late in the day, which can have the opposite effect of releasing stimulating endorphins that can keep you awake.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/social_benefits.jpg',
    title: 'Social Benefits',
    subtitle:
        'The newer field of happiness psychology has shown that healthy relationships and social interactions are key to being happy and finding meaning in life.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem8',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/social_benefits.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Martin Vorel',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: '',
                          ),
                        ),
                      );
                      AppBrowser(
                        link: 'https://libreshot.com/en/three-bikers-on-the-top-the-hill/',
                      );
                    },
                ),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'CC0',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://creativecommons.org/licenses/publicdomain/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(
                  text: ', from Libreshot',
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'The newer field of happiness psychology has shown that healthy relationships and social interactions are key to being happy and finding meaning in life. Mountain biking is often a social activity shared by clubs and groups who get out to ride together. It provides a perfect opportunity to build personal bonds and make new friends with people who enjoy the same activities that you do.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
  ArticleItem(
    image: 'assets/images/tips_and_benefits_previews/benefits/enjoy_nature.jpg',
    title: 'Enjoy Nature',
    subtitle: 'Spend more time on your bike and you may also become more likely to be more green and friendly to the environment.',
    widget: ListView(
      children: [
        Hero(
          tag: 'benefitsItem9',
          child: Image.asset(
            'assets/images/tips_and_benefits_previews/benefits/enjoy_nature.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Image by Simon Steinberger',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/photos/break-rest-view-bank-sit-woman-55353/',
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' from '),
                TextSpan(
                  text: 'Pixabay',
                  style: TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        tabKey.currentContext!,
                        CustomRoutes.fadeThrough(
                          page: AppBrowser(
                            link: 'https://pixabay.com/service/license',
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ),
        Container(
          child: AutoSizeText(
            'What better way to experience the great outdoors than to eat some dust and get intimate with thorny bushes on the trail? Seriously though, mountain biking, more than any other activity, allows you to quickly get off the beaten path and enjoy the solitude and majesty of nature.\n\nJapanese researchers have shown that being out in nature (what they refer to as “forest bathing”) improves relaxation and reduces stress. A busy urban environment has exactly the opposite effects of stimulating the fear and anxiety centers in the brain. Spend more time on your bike and you may also become more likely to be more green and friendly to the environment.\n\nSo instead of turning on the football game and reaching for a beer, (in the immortal words of Freddy Mercury) “Get on your bikes and ride.” There’s no better way I can think of to improve your overall physical, mental, and emotional health.',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ),
  ),
];
