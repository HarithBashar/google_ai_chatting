import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_ai_chat/app_data/constants.dart';
import 'package:google_ai_chat/firebase_options.dart';
import 'package:google_ai_chat/ui/chats/all_chats.dart';
import 'package:google_ai_chat/ui/chats/chats_class.dart';
import 'package:google_ai_chat/ui/settings/settings_class.dart';
import 'package:google_ai_chat/ui/welcome_screen.dart';


void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Get.put(ChatsClass()).getAllChats();
    Get.put(SettingsClass()).loadSettingsFromMemory();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        if(kDebugMode) print('User is currently signed out!');
        Get.offAll(() => const WelcomeScreen());
      } else {
        if(kDebugMode) print('User is signed in!');
        Get.offAll(() => const AllChats());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini AI',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const WelcomeScreen(),
      theme: ThemeData(
        fontFamily: mainFont,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          toolbarHeight: 40,
          foregroundColor: Colors.white,
          centerTitle: true,
        )
      ),



    );
  }
}
