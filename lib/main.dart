import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/ui/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini AI',
      home: const WelcomeScreen(),
      theme: ThemeData.dark(),
    );
  }
}
