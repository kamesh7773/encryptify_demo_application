import 'dart:convert';

List<UserModel> userModelFromJson(String str) => List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

String userModelToJson(List<UserModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModel {
  String userID;
  String name;
  String email;
  String provider;
  String rsaPublicKey;
  String encryptedRsaPrivateKey;
  String encryptedAesKey;
  String encryptedIV;

  UserModel({
    required this.userID,
    required this.name,
    required this.email,
    required this.provider,
    required this.rsaPublicKey,
    required this.encryptedRsaPrivateKey,
    required this.encryptedAesKey,
    required this.encryptedIV,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userID: json["userID"] ?? '',
        name: json["name"] ?? '',
        email: json["email"] ?? '',
        provider: json["provider"] ?? '',
        rsaPublicKey: json["rsaPublicKey"] ?? '',
        encryptedRsaPrivateKey: json["encryptedRsaPrivateKey"] ?? '',
        encryptedAesKey: json["encryptedAesKey"] ?? '',
        encryptedIV: json["encryptedIV"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "userID": userID,
        "name": name,
        "email": email,
        "provider": provider,
        "rsaPublicKey": rsaPublicKey,
        "encryptedRsaPrivateKey": encryptedRsaPrivateKey,
        "encryptedAesKey": encryptedAesKey,
        "encryptedIV": encryptedIV,
      };
}
