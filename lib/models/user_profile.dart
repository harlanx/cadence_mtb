import 'dart:convert';

UserProfile? currentUser;

class UserProfile {
  int profileNumber;
  String avatarCode;
  String profileName;
  String pinCode;

  UserProfile({
    required this.profileNumber,
    required this.avatarCode,
    required this.profileName,
    required this.pinCode,
  });

  factory UserProfile.fromJson(String str) => UserProfile.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  UserProfile.fromMap(Map<String, dynamic> json)
      : profileNumber = json['profileNumber'],
        avatarCode = json['avatarCode'],
        profileName = json['profileName'],
        pinCode = json['pinCode'];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};
    data['profileNumber'] = profileNumber;
    data['avatarCode'] = avatarCode;
    data['profileName'] = profileName;
    data['pinCode'] = pinCode;
    return data;
  }
}
