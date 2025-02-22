import '../services/firebase_firestore_services.dart';
import 'package:flutter/material.dart';

class Chatbubble extends StatefulWidget {
  final String messageID;
  final String message;
  final String otherUserID;
  final bool isCurrentUser;
  final bool isEncrypted;

  const Chatbubble({
    super.key,
    required this.messageID,
    required this.message,
    required this.otherUserID,
    required this.isCurrentUser,
    required this.isEncrypted,
  });

  @override
  State<Chatbubble> createState() => _ChatbubbleState();
}

class _ChatbubbleState extends State<Chatbubble> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: widget.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                margin: widget.isCurrentUser ? const EdgeInsets.only(right: 0, top: 2, bottom: 2, left: 100) : const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 100),
                padding: widget.isCurrentUser
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                    : widget.isEncrypted
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isCurrentUser ? const Color.fromARGB(255, 158, 126, 211) : const Color.fromARGB(255, 220, 212, 212),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.isCurrentUser
                    ? GestureDetector(
                        onLongPress: () {
                          FirebaseFireStoreMethods().deleteMessage(otherUserID: widget.otherUserID, messageID: widget.messageID);
                        },
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : widget.isEncrypted
                        ? GestureDetector(
                            onDoubleTap: () {
                              FirebaseFireStoreMethods().updateMessage(otherUserID: widget.otherUserID, messageID: widget.messageID);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Encrypted Message 🔒",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Double Tap to Decrypt ",
                                    style: TextStyle(fontSize: 13, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onLongPress: () {
                              FirebaseFireStoreMethods().deleteMessage(otherUserID: widget.otherUserID, messageID: widget.messageID);
                            },
                            child: Text(
                              widget.message,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
