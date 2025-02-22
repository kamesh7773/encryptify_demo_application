import 'package:encryptify_demo_application/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "E N C R Y P T I F Y   P A C K A G E",
          style: TextStyle(fontSize: 18.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  enabledBorder: border,
                  focusedBorder: border,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: "Password",
                  enabledBorder: border,
                  focusedBorder: border,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/sign_up_page");
                  },
                  child: Text(
                    " Sign up",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 120, 87, 182),
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                FirebaseAuthMethod.signInWithEmail(
                  email: _emailController.text,
                  password: _passwordController.text,
                  context: context,
                );
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
