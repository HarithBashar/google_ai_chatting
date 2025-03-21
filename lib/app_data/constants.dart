import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/APIs.dart';
import 'package:google_ai_chat/ui/settings/settings_class.dart';

Color mainColor = Colors.redAccent;
String mainFont = "NotoSansArabic";
String version = '1.0.0';

// String geminiModel = 'gemini-1.5-pro-001';
String geminiModule = 'gemini-1.5-flash';
String chatGPTModule = "gpt-4o-mini";

String geminiModuleName = "Google Gemini";
String chatGPTModuleName = 'openAI chatGPT';

Map<int, String> daysOfWeek = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

String formatDateTime(DateTime time, {bool isHourShown = true, bool isDayShown = false}) {
  return "${isDayShown ? "${daysOfWeek[time.weekday]!}  " : ""}${time.day.toString().padLeft(2, '0')}-${time.month.toString().padLeft(2, '0')}-${time.year}${isHourShown ? " | ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}" : ''}";
}

Widget get backgroundImage {
  return GetBuilder(
      init: SettingsClass(),
      builder: (controller) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/background white.png'),
              repeat: ImageRepeat.repeat,
              opacity: controller.backgroundImageOpacity,
            ),
          ),
        );
      });
}

String generateId({int length = 20}) {
  const String chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
}

// Helper function to determine text direction
TextDirection getTextDirection(String text) {
  text = text.replaceAll(RegExp(r'[*_~`#">+\-!\[\]()]'), '');
  text = text.trim();

  if (text.isEmpty) return TextDirection.ltr;

  // RTL language character set (Arabic, Hebrew, etc.)
  final rtlLanguages = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u0590-\u05FF]');

  if (rtlLanguages.hasMatch(text)) {
    return TextDirection.rtl;
  } else {
    return TextDirection.ltr;
  }
}
