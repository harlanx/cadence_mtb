import 'package:cadence_mtb/models/models.dart';

final List<BikeProjectItem> bikeParts = [
  BikeProjectItem(
    part: 'Brake Caliper',
    types: ['Disc Brake Caliper'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Cassette',
    types: [
      '7 Speed',
      '8 Speed',
      '9 Speed',
      '10 Speed',
    ],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Crankset',
    types: ['1 Speed', '2 Speed', '3 Speed'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Frame Types and Rear Suspension',
    types: ['Full Suspension', 'Hard Tail'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Front Derailleur',
    types: ['Clamp On', 'Direct Mount', 'E Type', 'None'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Front Fork',
    types: ['Suspension'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Handlebars',
    types: ['Flat Bar', 'Riser Bar'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Pedal',
    types: ['Flat', 'Clipless'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Rear Derailleur',
    types: ['Long Cage'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Saddle',
    types: ['Racing', 'Cutaway'],
    //preview: '',
  ),
  BikeProjectItem(
    part: 'Wheel',
    types: ['Rim', 'Tire'],
    subtypes: [
      ['27.5"', '29"'],
      ['All Mountain', 'Cross Country', 'Trail Riding']
    ],
    //preview: '',
  ),
];
