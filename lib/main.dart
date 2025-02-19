import 'package:encryptify/encryptify.dart';
import 'package:encryptify_demo_application/pages/home_page.dart';
import 'services/firebase_options.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      routes: {
        '/login_page': (context) => const LoginPage(),
        '/home_page': (context) => const HomePage(),
      },
      title: 'Encryptify Example',
      home: LoginPage(),
    );
  }
}
