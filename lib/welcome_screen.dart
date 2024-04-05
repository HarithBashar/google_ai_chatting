import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/chat_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  final colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(
        children: [
          // robot icon
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: .7,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(200)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red[400]!.withOpacity(.2),
                          offset: const Offset(0, 150),
                          blurRadius: 100,
                          spreadRadius: 5,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.red[200]!,
                          Colors.red[300]!,
                          Colors.red[500]!,
                          Colors.red[500]!,
                        ],
                        stops: const [0.1, 0.3, 0.9, 1.0],
                      ),
                    ),
                  ),
                ),
                Image.asset('assets/images/robot2.png'),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Talk with',
                        textStyle: TextStyle(
                          fontSize: size.width * .1,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 100),
                        textAlign: TextAlign.center
                      ),
                      ColorizeAnimatedText(
                        'GEMINI PRO',
                        textStyle: TextStyle(
                          fontSize: size.width * .1,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 500),
                        colors: colorizeColors,
                      ),
                    ],

                    isRepeatingAnimation: true,
                    repeatForever: true,
                    pause: const Duration(milliseconds: 100),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Get.to(() => const ChatScreen());
                  },
                  icon: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(.7),
                    radius: 30,
                    child: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
