import 'package:encryptify_demo_application/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Border Properties
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(
      width: 2,
      color: Colors.deepPurple[200]!,
    ),
  );

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
      body: StreamBuilder(
        stream: null,
        builder: (context, snapshot) {
          // if snapshot data is loading, then we show the loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // if snapshot has data, show it
          if (snapshot.hasData) {
            return Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter text to encrypt",
                ),
                onChanged: (value) {
                  // Encrypt the text
                },
              ),
            );
          }

          // if snapshot has error, show it
          if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
            );
          }

          // if snapshot is empty, show this
          // return Center(
          //   child: Text(
          //     "Snapshot is empty",
          //     style: TextStyle(
          //       fontSize: 16,
          //     ),
          //   ),
          // );

          return Column(
            children: [
              Spacer(flex: 2),
              Text("Encrypted Data: "),
              Spacer(flex: 1),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter message",
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  // Encrypt the text
                  // EncryptionDecryption.encryptText("Hello World");
                },
                child: const Text(
                  "Send Message",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Spacer(flex: 1),
            ],
          );
        },
      ),
    );
  }
}
