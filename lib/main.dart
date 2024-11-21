import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokedexapp/Pages/auth_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  //Reading the api key
  Gemini.init(apiKey: 'AIzaSyBsvyh6-PXyQ_DIQXKp3sBd8p07ZVM28xs');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const AuthPage(),
    );
  }
}
