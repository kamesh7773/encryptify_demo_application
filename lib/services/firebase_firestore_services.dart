import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encryptify/encryptify.dart';
import 'package:encryptify_demo_application/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFireStoreMethods {
  // Firebase instance variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String usersCollection = "users";
  final String chatRoomsCollection = "chatRooms";
  final String messagesCollection = "messages";

  //! Sends a message to a user.
  Future<void> sendMessage({
    required String receiverID,
    required String messageID,
    required String message,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> receiverDoc = _db.collection(usersCollection).doc(receiverID);

      final data = (await receiverDoc.get()).data()!;

      final recipientPublicKey = data["rsaPublicKey"];

      final encryptedData = await Encryptify.encryptMessage(message: message, recipientRSAPublicKey: recipientPublicKey);

      MessageModel newMessage = MessageModel(
        messageID: messageID,
        message: encryptedData.encryptedMessage,
        senderID: _auth.currentUser!.uid,
        reciverID: receiverID,
        timestamp: Timestamp.now(),
        encryptedAESKey: encryptedData.encryptedAesKey,
        encryptedIV: encryptedData.encryptedIV,
        isEncrypted: true,
      );

      List<String> ids = [_auth.currentUser!.uid, receiverID];
      ids.sort();
      String chatRoomID = ids.join("_");

      await _db.collection(chatRoomsCollection).doc(chatRoomID).collection("messages").doc(messageID).set(newMessage.toJson());
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  //! Retrieves messages from a chat room.
  Stream<List<MessageModel>> getMessages({required String otherUserID}) {
    List<String> ids = [_auth.currentUser!.uid, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    final CollectionReference messages = _db.collection(chatRoomsCollection).doc(chatRoomID).collection(messagesCollection);

    try {
      return messages.orderBy("timestamp", descending: false).snapshots().asyncMap((snapshot) async {
        final List<MessageModel> messageList = await Future.wait(
          snapshot.docs.map((doc) async {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            final String senderID = data['senderID'];
            final String encryptedMessage = data['message'];
            final String encryptedAESKey = data['encryptedAESKey'];
            final String encryptedIV = data['encryptedIV'];

            final String decryptedMessage = await Encryptify.decryptMessage(
              currentUserID: _auth.currentUser!.uid,
              senderID: senderID,
              encryptedMessage: encryptedMessage,
              recipientencryptedAESKey: encryptedAESKey,
              recipientencryptedIV: encryptedIV,
            );

            data['message'] = decryptedMessage;

            return MessageModel.fromJson(data);
          }).toList(),
        );

        return messageList;
      });
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  //! Method that update the message isEncrypted feild to false
  Future<void> updateMessage({
    required String otherUserID,
    required String messageID, // The document ID of the message
  }) async {
    try {
      // Generate the chatRoomID
      List<String> ids = [_auth.currentUser!.uid, otherUserID];
      ids.sort();
      String chatRoomID = ids.join("_");

      // Reference the specific message document
      final DocumentReference messageDoc = _db.collection(chatRoomsCollection).doc(chatRoomID).collection(messagesCollection).doc(messageID);

      // Update the document
      await messageDoc.update({
        "isEncrypted": false,
      });
    } catch (error) {
      throw Exception("Failed to update message: ${error.toString()}");
    }
  }
}
