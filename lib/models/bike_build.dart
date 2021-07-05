import 'dart:convert';

class BikeBuild {
  String name;
  DateTime buildDate;

  String brakeClprCode;
  PartPosition brakeClprPosFront;
  PartPosition brakeClprPosRear;
  double brakeClprAngleFront;
  double brakeClprAngleRear;

  String cassetteCode;
  PartPosition cassettePos;
  double cassetteAngle;

  String cranksetCode;
  PartPosition cranksetPos;
  double cranksetAngle;

  String frameCode;
  PartPosition framePos;
  double frameAngle;

  String frontDlrCode;
  PartPosition frontDlrPos;
  double frontDlrAngle;

  String frontForkCode;
  PartPosition frontForkPos;
  double frontForkAngle;

  String handlebarCode;
  PartPosition handlebarPos;
  double handlebarAngle;

  String pedalCode;
  PartPosition pedalPos;
  double pedalAngle;

  String rearDlrCode;
  PartPosition rearDlrPos;
  double rearDlrAngle;

  String rimCode;
  PartPosition rimPosFront;
  PartPosition rimPosRear;
  double rimAngleFront;
  double rimAngleRear;

  String saddleCode;
  PartPosition saddlePos;
  double saddleAngle;

  String tireCode;
  PartPosition tirePosFront;
  PartPosition tirePosRear;
  double tireAngleFront;
  double tireAngleRear;

  String bellCode;
  PartPosition bellPos;
  double bellAngle;

  String bottleCageCode;
  PartPosition bottleCagePos;
  double bottleCageAngle;

  String fenderCode;
  PartPosition fenderPosFront;
  PartPosition fenderPosRear;
  double fenderAngleFront;
  double fenderAngleRear;

  String kickstandCode;
  PartPosition kickstandPos;
  double kickstandAngle;

  String lightCode;
  PartPosition lightPosFront;
  PartPosition lightPosRear;
  double lightAngleFront;
  double lightAngleRear;

  String phoneHolderCode;
  PartPosition phoneHoldePos;
  double phoneHoldeAngle;

  PartPosition chainAdvancedPos;
  double chainAdvancedAngle;

  PartPosition brakeDiscPosFront;
  PartPosition brakeDiscPosRear;
  double brakeDiscAngleFront;
  double brakeDiscAngleRear;

  BikeBuild({
    required this.name,
    required this.buildDate,
    required this.brakeClprCode,
    required this.brakeClprPosFront,
    required this.brakeClprPosRear,
    required this.brakeClprAngleFront,
    required this.brakeClprAngleRear,
    required this.cassetteCode,
    required this.cassettePos,
    required this.cassetteAngle,
    required this.cranksetCode,
    required this.cranksetPos,
    required this.cranksetAngle,
    required this.frameCode,
    required this.framePos,
    required this.frameAngle,
    required this.frontDlrCode,
    required this.frontDlrPos,
    required this.frontDlrAngle,
    required this.frontForkCode,
    required this.frontForkPos,
    required this.frontForkAngle,
    required this.handlebarCode,
    required this.handlebarPos,
    required this.handlebarAngle,
    required this.pedalCode,
    required this.pedalPos,
    required this.pedalAngle,
    required this.rearDlrCode,
    required this.rearDlrPos,
    required this.rearDlrAngle,
    required this.rimCode,
    required this.rimPosFront,
    required this.rimPosRear,
    required this.rimAngleFront,
    required this.rimAngleRear,
    required this.saddleCode,
    required this.saddlePos,
    required this.saddleAngle,
    required this.tireCode,
    required this.tirePosFront,
    required this.tirePosRear,
    required this.tireAngleFront,
    required this.tireAngleRear,
    required this.bellCode,
    required this.bellPos,
    required this.bellAngle,
    required this.bottleCageCode,
    required this.bottleCagePos,
    required this.bottleCageAngle,
    required this.fenderCode,
    required this.fenderPosFront,
    required this.fenderPosRear,
    required this.fenderAngleFront,
    required this.fenderAngleRear,
    required this.kickstandCode,
    required this.kickstandPos,
    required this.kickstandAngle,
    required this.lightCode,
    required this.lightPosFront,
    required this.lightPosRear,
    required this.lightAngleFront,
    required this.lightAngleRear,
    required this.phoneHolderCode,
    required this.phoneHoldePos,
    required this.phoneHoldeAngle,
    required this.chainAdvancedPos,
    required this.chainAdvancedAngle,
    required this.brakeDiscPosFront,
    required this.brakeDiscPosRear,
    required this.brakeDiscAngleFront,
    required this.brakeDiscAngleRear,
  });

  //Use json_annotation and jsonserializable package if you don't know how to create your own toJson and fromJson method
  factory BikeBuild.fromJson(String str) => BikeBuild.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  BikeBuild.fromMap(Map<String, dynamic> json)
      : name = json['name'],
        buildDate = DateTime.fromMillisecondsSinceEpoch(json['buildDate']),
        brakeClprCode = json['brakeClprCode'],
        brakeClprPosFront = PartPosition.fromJson(json['brakeClprPosFront']),
        brakeClprPosRear = PartPosition.fromJson(json['brakeClprPosRear']),
        brakeClprAngleFront = json['brakeClprAngleFront'],
        brakeClprAngleRear = json['brakeClprAngleRear'],
        cassetteCode = json['cassetteCode'],
        cassettePos = PartPosition.fromJson(json['cassettePos']),
        cassetteAngle = json['cassetteAngle'],
        cranksetCode = json['cranksetCode'],
        cranksetPos = PartPosition.fromJson(json['cranksetPos']),
        cranksetAngle = json['cranksetAngle'],
        frameCode = json['frameCode'],
        framePos = PartPosition.fromJson(json['framePos']),
        frameAngle = json['frameAngle'],
        frontDlrCode = json['frontDlrCode'],
        frontDlrPos = PartPosition.fromJson(json['frontDlrPos']),
        frontDlrAngle = json['frontDlrAngle'],
        frontForkCode = json['frontForkCode'],
        frontForkPos = PartPosition.fromJson(json['frontForkPos']),
        frontForkAngle = json['frontForkAngle'],
        handlebarCode = json['handlebarCode'],
        handlebarPos = PartPosition.fromJson(json['handlebarPos']),
        handlebarAngle = json['handlebarAngle'],
        pedalCode = json['pedalCode'],
        pedalPos = PartPosition.fromJson(json['pedalPos']),
        pedalAngle = json['pedalAngle'],
        rearDlrCode = json['rearDlrCode'],
        rearDlrPos = PartPosition.fromJson(json['rearDlrPos']),
        rearDlrAngle = json['rearDlrAngle'],
        rimCode = json['rimCode'],
        rimPosFront = PartPosition.fromJson(json['rimPosFront']),
        rimPosRear = PartPosition.fromJson(json['rimPosRear']),
        rimAngleFront = json['rimAngleFront'],
        rimAngleRear = json['rimAngleRear'],
        saddleCode = json['saddleCode'],
        saddlePos = PartPosition.fromJson(json['saddlePos']),
        saddleAngle = json['saddleAngle'],
        tireCode = json['tireCode'],
        tirePosFront = PartPosition.fromJson(json['tirePosFront']),
        tirePosRear = PartPosition.fromJson(json['tirePosRear']),
        tireAngleFront = json['tireAngleFront'],
        tireAngleRear = json['tireAngleRear'],
        bellCode = json['bellCode'],
        bellPos = PartPosition.fromJson(json['bellPos']),
        bellAngle = json['bellAngle'],
        bottleCageCode = json['bottleCageCode'],
        bottleCagePos = PartPosition.fromJson(json['bottleCagePos']),
        bottleCageAngle = json['bottleCageAngle'],
        fenderCode = json['fenderCode'],
        fenderPosFront = PartPosition.fromJson(json['fenderPosFront']),
        fenderPosRear = PartPosition.fromJson(json['fenderPosRear']),
        fenderAngleFront = json['fenderAngleFront'],
        fenderAngleRear = json['fenderAngleRear'],
        kickstandCode = json['kickstandCode'],
        kickstandPos = PartPosition.fromJson(json['kickstandPos']),
        kickstandAngle = json['kickstandAngle'],
        lightCode = json['lightCode'],
        lightPosFront = PartPosition.fromJson(json['lightPosFront']),
        lightPosRear = PartPosition.fromJson(json['lightPosRear']),
        lightAngleFront = json['lightAngleFront'],
        lightAngleRear = json['lightAngleRear'],
        phoneHolderCode = json['phoneHolderCode'],
        phoneHoldePos = PartPosition.fromJson(json['phoneHoldePos']),
        phoneHoldeAngle = json['phoneHoldeAngle'],
        chainAdvancedPos = PartPosition.fromJson(json['chainAdvancedPos']),
        chainAdvancedAngle = json['chainAdvancedAngle'],
        brakeDiscPosFront = PartPosition.fromJson(json['brakeDiscPosFront']),
        brakeDiscPosRear = PartPosition.fromJson(json['brakeDiscPosRear']),
        brakeDiscAngleFront = json['brakeDiscAngleFront'],
        brakeDiscAngleRear = json['brakeDiscAngleRear'];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['buildDate'] = buildDate.millisecondsSinceEpoch;
    data['brakeClprCode'] = brakeClprCode;
    data['brakeClprPosFront'] = brakeClprPosFront.toJson();
    data['brakeClprPosRear'] = brakeClprPosRear.toJson();
    data['brakeClprAngleFront'] = brakeClprAngleFront;
    data['brakeClprAngleRear'] = brakeClprAngleRear;
    data['cassetteCode'] = cassetteCode;
    data['cassettePos'] = cassettePos.toJson();
    data['cassetteAngle'] = cassetteAngle;
    data['cranksetCode'] = cranksetCode;
    data['cranksetPos'] = cranksetPos.toJson();
    data['cranksetAngle'] = cranksetAngle;
    data['frameCode'] = frameCode;
    data['framePos'] = framePos.toJson();
    data['frameAngle'] = frameAngle;
    data['frontDlrCode'] = frontDlrCode;
    data['frontDlrPos'] = frontDlrPos.toJson();
    data['frontDlrAngle'] = frontDlrAngle;
    data['frontForkCode'] = frontForkCode;
    data['frontForkPos'] = frontForkPos.toJson();
    data['frontForkAngle'] = frontForkAngle;
    data['handlebarCode'] = handlebarCode;
    data['handlebarPos'] = handlebarPos.toJson();
    data['handlebarAngle'] = handlebarAngle;
    data['pedalCode'] = pedalCode;
    data['pedalPos'] = pedalPos.toJson();
    data['pedalAngle'] = pedalAngle;
    data['rearDlrCode'] = rearDlrCode;
    data['rearDlrPos'] = rearDlrPos.toJson();
    data['rearDlrAngle'] = rearDlrAngle;
    data['rimCode'] = rimCode;
    data['rimPosFront'] = rimPosFront.toJson();
    data['rimPosRear'] = rimPosRear.toJson();
    data['rimAngleFront'] = rimAngleFront;
    data['rimAngleRear'] = rimAngleRear;
    data['saddleCode'] = saddleCode;
    data['saddlePos'] = saddlePos.toJson();
    data['saddleAngle'] = saddleAngle;
    data['tireCode'] = tireCode;
    data['tirePosFront'] = tirePosFront.toJson();
    data['tirePosRear'] = tirePosRear.toJson();
    data['tireAngleFront'] = tireAngleFront;
    data['tireAngleRear'] = tireAngleRear;
    data['bellCode'] = bellCode;
    data['bellPos'] = bellPos.toJson();
    data['bellAngle'] = bellAngle;
    data['bottleCageCode'] = bottleCageCode;
    data['bottleCagePos'] = bottleCagePos.toJson();
    data['bottleCageAngle'] = bottleCageAngle;
    data['fenderCode'] = fenderCode;
    data['fenderPosFront'] = fenderPosFront.toJson();
    data['fenderPosRear'] = fenderPosRear.toJson();
    data['fenderAngleFront'] = fenderAngleFront;
    data['fenderAngleRear'] = fenderAngleRear;
    data['kickstandCode'] = kickstandCode;
    data['kickstandPos'] = kickstandPos.toJson();
    data['kickstandAngle'] = kickstandAngle;
    data['lightCode'] = lightCode;
    data['lightPosFront'] = lightPosFront.toJson();
    data['lightPosRear'] = lightPosRear.toJson();
    data['lightAngleFront'] = lightAngleFront;
    data['lightAngleRear'] = lightAngleRear;
    data['phoneHolderCode'] = phoneHolderCode;
    data['phoneHoldePos'] = phoneHoldePos.toJson();
    data['phoneHoldeAngle'] = phoneHoldeAngle;
    data['chainAdvancedPos'] = chainAdvancedPos.toJson();
    data['chainAdvancedAngle'] = chainAdvancedAngle;
    data['brakeDiscPosFront'] = brakeDiscPosFront.toJson();
    data['brakeDiscPosRear'] = brakeDiscPosRear.toJson();
    data['brakeDiscAngleFront'] = brakeDiscAngleFront;
    data['brakeDiscAngleRear'] = brakeDiscAngleRear;
    return data;
  }
}

class PartPosition {
  double x;
  double y;

  ///-1.0 (Left Most or Top Most) to 1.0 (Right Most or Bottom Most) only.
  ///PartPosition(x , y)
  PartPosition(this.x, this.y);

  factory PartPosition.fromJson(String str) => PartPosition.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  PartPosition.fromMap(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['x'] = x;
    data['y'] = y;
    return data;
  }
}

class BrakeCaliper {
  final String code;
  final String frontImage;
  final String rearImage;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;

  BrakeCaliper({
    required this.code,
    required this.frontImage,
    required this.rearImage,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class Cassette {
  final String code;
  final String image;
  final String speed;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;

  Cassette({
    required this.code,
    required this.image,
    required this.speed,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
  });
}

class Crankset {
  final String code;
  final String image;
  final String speed;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;

  Crankset({
    required this.code,
    required this.image,
    required this.speed,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
  });
}

class Frame {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;
  final List<String> frontDerailleurTypes;

  Frame(
      {required this.code,
      required this.image,
      required this.sizeFactor,
      required this.name,
      required this.brand,
      required this.price,
      required this.link,
      required this.type,
      required this.frontDerailleurTypes});
}

class FrontDerailleur {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;

  FrontDerailleur({
    required this.code,
    required this.image,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class FrontFork {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String sizeType;

  FrontFork({
    required this.code,
    required this.image,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.sizeType,
  });
}

class Handlebar {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;

  Handlebar({
    required this.code,
    required this.image,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class Pedal {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;

  Pedal({
    required this.code,
    required this.image,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class RearDerailleur {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;

  RearDerailleur({
    required this.code,
    required this.image,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class Rim {
  final String code;
  final String frontImage;
  final String rearImage;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String sizeType;

  Rim({
    required this.code,
    required this.frontImage,
    required this.rearImage,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.sizeType,
  });
}

class Saddle {
  final String code;
  final String image;
  final double sizeFactor;
  final String name;
  final String brand;
  final double price;
  final String /*!*/ link;
  final String type;

  Saddle({
    required this.code,
    required this.image,
    required this.sizeFactor,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class Tire {
  final String code;
  final String frontImage;
  final String rearImage;
  final String name;
  final String brand;
  final double price;
  final String link;
  final String type;

  Tire({
    required this.code,
    required this.frontImage,
    required this.rearImage,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
    required this.type,
  });
}

class Accessory {
  final String code;
  final String frontImage;
  final String rearImage;
  final double sizeFactorFront;
  final double? sizeFactorRear;
  final String name;
  final String brand;
  final double price;
  final String link;

  Accessory({
    required this.code,
    required this.frontImage,
    required this.rearImage,
    required this.sizeFactorFront,
    this.sizeFactorRear,
    required this.name,
    required this.brand,
    required this.price,
    required this.link,
  });
}
