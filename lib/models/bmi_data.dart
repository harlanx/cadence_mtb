import 'dart:convert';
import 'package:hive/hive.dart';
part 'bmi_data.g.dart';

@HiveType(typeId: 1)
class BMIData {
  @HiveField(0)
  double weightInKg;
  @HiveField(1)
  double heightInCm;
  @HiveField(2)
  double bmi;
  @HiveField(3)
  DateTime date;

  BMIData({
    required this.weightInKg,
    required this.heightInCm,
    required this.bmi,
    required this.date,
  });

  factory BMIData.fromJson(String str) => BMIData.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  BMIData.fromMap(Map<String, dynamic> json) :
    weightInKg = json['weightInKg'],
    heightInCm = json['heightInCm'],
    bmi = json['bmi'],
    date = json['date'];

  Map<String, dynamic> toMap() => {
        'weightInKg': weightInKg,
        'heightInCm': heightInCm,
        'bmi': bmi,
        'date': date,
      };
}
