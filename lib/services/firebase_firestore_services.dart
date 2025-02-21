import 'package:cloud_firestore/cloud_firestore.dart';
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
    required String message,
    required String recipientPublicKey,
  }) async {
    final String currentUserID = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final DocumentReference<Map<String, dynamic>> receiverDoc = _db.collection(usersCollection).doc(receiverID);

    try {
      final data = (await receiverDoc.get()).data()!;

      // Parse the recipient's RSA public key from PEM format.
      RsaKeyHelper helper = RsaKeyHelper();
      final RSAPublicKey publicKey = helper.parsePublicKeyFromPem(recipientPublicKey);

      // Encrypt the message using AES
      final result = await MessageEncrptionService().messageEncryption(message: message);

      // Encrypt AES Key & IV using the recipient's public RSA key
      String encryptedAESKey = MessageEncrptionService().rsaEncrypt(data: result.aesKey.bytes, publicKey: publicKey);
      String encryptedIV = MessageEncrptionService().rsaEncrypt(data: result.iv.bytes, publicKey: publicKey);

      MessageModel newMessage = MessageModel(
        senderID: currentUserID,
        reciverID: receiverID,
        isVideoCall: null,
        message: result.encryptedMessage,
        encryptedAESKey: encryptedAESKey,
        encryptedIV: encryptedIV,
        isSeen: true,
        timestamp: timestamp,
      );

      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join("_");

      await _db.collection(usersCollection).doc(chatRoomID).collection(messagesCollection).add(newMessage.toMap());
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

            final String decryptedMessage = await MessageEncrptionService().messageDecryption(
              currentUserID: _auth.currentUser!.uid,
              senderID: senderID,
              encryptedMessage: encryptedMessage,
              encryptedAESKey: encryptedAESKey,
              encryptedIV: encryptedIV,
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
}
