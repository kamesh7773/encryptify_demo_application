import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageID;
  final String message;
  final String senderID;
  final String reciverID;
  final Timestamp timestamp;
  final String encryptedAESKey;
  final String encryptedIV;
  final bool isEncrypted;

  MessageModel({
    required this.messageID,
    required this.message,
    required this.senderID,
    required this.reciverID,
    required this.timestamp,
    required this.encryptedAESKey,
    required this.encryptedIV,
    required this.isEncrypted,
  });

  // Convert to a Map
  Map<String, dynamic> toMap() {
    return {
      "messageID": messageID,
      "message": message,
      "senderID": senderID,
      "reciverID": reciverID,
      "timestamp": timestamp,
      "encryptedAESKey": encryptedAESKey,
      "encryptedIV": encryptedIV,
      "isEncrypted": isEncrypted,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        messageID: json["messageID"],
        message: json["message"],
        senderID: json["senderID"],
        reciverID: json["reciverID"],
        timestamp: json["timestamp"],
        encryptedAESKey: json["encryptedAESKey"],
        encryptedIV: json["encryptedIV"],
        isEncrypted: json["isEncrypted"],
      );

  Map<String, dynamic> toJson() => {
        "messageID": messageID,
        "message": message,
        "senderID": senderID,
        "reciverID": reciverID,
        "timestamp": timestamp,
        "encryptedAESKey": encryptedAESKey,
        "encryptedIV": encryptedIV,
        "isEncrypted": isEncrypted,
      };
}
