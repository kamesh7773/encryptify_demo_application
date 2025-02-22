import 'package:encryptify_demo_application/models/message_model.dart';
import 'package:encryptify_demo_application/services/firebase_auth_services.dart';
import 'package:encryptify_demo_application/services/firebase_firestore_services.dart';
import 'package:encryptify_demo_application/widgets/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String otherUserId;
  const HomePage({super.key, required this.otherUserId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // variables declartions
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final TextEditingController _sendMessageController;
  late final ScrollController _scrollController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFireStoreMethods fireStoreMethods = FirebaseFireStoreMethods();

  // Border Properties
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(
      width: 2,
      color: Colors.deepPurple[200]!,
    ),
  );

  @override
  void initState() {
    super.initState();
    _sendMessageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _sendMessageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "E N C R Y P T I F Y   P A C K A G E",
          style: TextStyle(fontSize: 19),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
        actions: [
          IconButton(
            onPressed: () {
              // Sign out the user
              FirebaseAuthMethod.signOut(context: context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: fireStoreMethods.getMessages(otherUserID: widget.otherUserId),
        builder: (context, snapshot) {
          // if snapshot data is loading, then we show the loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // if snapshot has data, show it
          if (snapshot.hasData) {
            // Convert the snapshot data into a List<MessageModel>
            final List<MessageModel> data = snapshot.data as List<MessageModel>;

            return Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.deepPurple[200]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            key: _listKey,
                            // Set reverse to true so the ListView starts from the bottom, automatically scrolling to the last message when the user enters the chat page.
                            reverse: true,
                            padding: EdgeInsets.zero,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              // When reverse: true is used, adjust the data indexing to match the reversed scroll order, ensuring the most recent messages are displayed correctly.
                              final reverseIndex = data.length - 1 - index;

                              // Get messages by index.
                              final message = data[reverseIndex];

                              // Check if the current user is the sender.
                              var isCurrentUser = message.senderID == _auth.currentUser!.uid;

                              // Render regular chat bubbles for non-call messages
                              return Chatbubble(
                                messageID: message.messageID,
                                otherUserID: widget.otherUserId,
                                message: message.message,
                                isCurrentUser: isCurrentUser,
                                isEncrypted: message.isEncrypted,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _sendMessageController,
                      decoration: InputDecoration(
                        hintText: "Enter message",
                        enabledBorder: border,
                        focusedBorder: border,
                        suffixIcon: IconButton(
                          onPressed: () async {
                            // Send the message
                            await fireStoreMethods.sendMessage(
                              messageID: DateTime.now().millisecondsSinceEpoch.toString(),
                              receiverID: widget.otherUserId,
                              message: _sendMessageController.text.trim(),
                            );

                            // after sending the message clear the textfeild
                            _sendMessageController.clear();
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.deepPurple[400],
                            size: 26.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.deepPurple[200]!,
                      width: 2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      "Users sign up by generating an RSA key pair and an AES key with an Initialization Vector (IV). The RSA private key, AES key, and IV are securely stored locally, while the RSA public key is uploaded to Firebase Firestore. Sensitive keys are encrypted using a user-derived custom string and also stored in Firestore. When sending a message, the sender encrypts it with the AES key and IV, then encrypts the AES key and IV using the recipient’s RSA public key from Firestore. The encrypted message, AES key, and IV are sent to the recipient. To decrypt, the recipient uses their RSA private key to decrypt the AES key and IV, then decrypts the message. If the app is reinstalled or data is lost, the user retrieves the encrypted keys from Firestore, decrypts them using the custom string, and restores them to continue messaging seamlessly.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // if snapshot has error, show it
          if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
            );
          }

          // if snapshot is empty, show this
          return Center(
            child: Text(
              "Snapshot is empty",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
