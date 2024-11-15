import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/app_data/constants.dart';
import 'package:google_ai_chat/ui/chats/all_chats.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    // Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          // background photo
          backgroundImage,

          Column(
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
                              color: mainColor.withOpacity(.1),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText('Talk with',
                                textStyle: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                speed: const Duration(milliseconds: 100),
                                textAlign: TextAlign.center),
                            ColorizeAnimatedText(
                              'GEMINI PRO',
                              textStyle: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              speed: const Duration(milliseconds: 500),
                              colors: colorizeColors,
                            ),
                            TypewriterAnimatedText('MADE BY:',
                                textStyle: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                speed: const Duration(milliseconds: 100),
                                textAlign: TextAlign.center),
                            ColorizeAnimatedText(
                              '@HARITH.BASHAR',
                              textStyle: const TextStyle(
                                fontSize: 30,
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
                    ),
                    const Text('Sign in with Google before using the app.'),
                    CupertinoButton(
                      child: Container(
                        height: 60,
                        width: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/icons/google.png', height: 30),
                            const Text("Sign in with Google", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      onPressed: () => signInWithGoogle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);

    Get.offAll(() => const AllChats());
  }
}
