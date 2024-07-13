import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pokedexapp/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'mytextfield.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  LoginForm({
    required this.usernameController,
    required this.passwordController,
  });

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  //Signing User in
  void signuserin() async {
    // Add your sign-in logic here
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.usernameController.text,
        password: widget.passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username TextField
        myTextfield(
          controller: widget.usernameController,
          hintText: 'Username',
          obscureText: false,
        ),
        const SizedBox(height: 20),
        // Password TextField
        myTextfield(
          controller: widget.passwordController,
          hintText: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 20),
        // Forgot Password Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  // Add functionality here
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.black38,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        //Sign in button
        Mybutton(onTap: signuserin),
      ],
    );
  }
}
