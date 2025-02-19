import 'package:encryptify/encryptify.dart';
import 'package:flutter/material.dart';

void main() async {
  // When application starts, generate RSA keys
  EncryptionDecryption.generateKeys(); // Generate RSA keys

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Encryptify Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Encryptify Package"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
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
              child: Text(
                snapshot.data.toString(),
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
