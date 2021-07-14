import 'package:cadence_mtb/models/models.dart';
import 'package:cadence_mtb/pages/body_conditioning.dart';
import 'package:cadence_mtb/pages/organizations.dart';
import 'package:cadence_mtb/pages/preparation.dart';
import 'package:cadence_mtb/pages/repair_and_maintenance.dart';
import 'package:cadence_mtb/pages/tips_and_benefits.dart';

List<GuidesList> guidesItem = [
  GuidesList(
    title: 'Preparations',
    iconPath: 'assets/icons/guides_dashboard/preparations.svg',
    page: Preparation(),
  ),
  GuidesList(
    title: '',
    iconPath: 'assets/icons/guides_dashboard/body_conditioning.svg',
    page: BodyConditioning(),
  ),
  GuidesList(
    title: '',
    iconPath: 'assets/icons/guides_dashboard/repair_and_maintenance.svg',
    page: RepairAndMaintenance(),
  ),
  GuidesList(
    title: 'Tips and Benefits',
    iconPath: 'assets/icons/guides_dashboard/tips_and_benefits.svg',
    page: TipsAndBenefits(),
  ),
  GuidesList(
    title: 'Organizations',
    iconPath: 'assets/icons/guides_dashboard/organizations.svg',
    page: Organizations(),
  ),
];

final List<RulesOfTheTrail> rOTTItem = [
  RulesOfTheTrail(
    rule: 'Ride on Open Trails Only',
    description:
        'Respect trail and road closures - ask a land manager for clarification if you are uncertain about the status of a trail.\n\nDo not trespass on private land. Obtain permits or other authorization as may be required.\n\nBe aware that bicycles are not permitted in areas protected as state or federal Wilderness.',
  ),
  RulesOfTheTrail(
    rule: 'Leave No Trace',
    description:
        "Be sensitive to the dirt beneath you. Wet and muddy trails are more vulnerable to damage than dry ones.\n\nWhen the trail is soft, consider other riding options. This also means staying on existing trails and not creating new ones.\n\nDon't cut switchbacks. Be sure to pack out at least as much as you pack in.",
  ),
  RulesOfTheTrail(
    rule: 'Control Your Bicycle',
    description:
        'Inattention for even a moment could put yourself and others at risk.\n\nObey all bicycle speed regulations and recommendations, and ride within your limits.',
  ),
  RulesOfTheTrail(
    rule: 'Yield to Others',
    description:
        "Do your utmost to let your fellow trail users know you're coming -- a friendly greeting or bell ring are good methods.\n\nTry to anticipate other trail users as you ride around corners. Bicyclists should yield to all other trail users, unless the trail is clearly signed for bike-only travel.\n\nBicyclists traveling downhill should yield to ones headed uphill, unless the trail is clearly signed for one-way or downhill-only traffic.\n\nStrive to make each pass a safe and courteous one.",
  ),
  RulesOfTheTrail(
    rule: 'Never Scare Animals',
    description:
        'Animals are easily startled by an unannounced approach, a sudden movement or a loud noise. \n\nGive animals enough room and time to adjust to you. When passing horses, use special care and follow directions from the horseback riders (ask if uncertain).\n\nRunning farm animals and disturbing wildlife are serious offenses.',
  ),
  RulesOfTheTrail(
    rule: 'Plan Ahead',
    description:
        'Know your equipment, your ability and the area in which you are riding -- and prepare accordingly.\n\nStrive to be self-sufficient: keep your equipment in good repair and carry necessary supplies for changes in weather or other conditions.\n\nAlways wear a helmet and appropriate safety gear.',
  ),
];
