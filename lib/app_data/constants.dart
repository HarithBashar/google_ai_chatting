
import 'package:flutter/material.dart';

Map<int, String> daysOfWeek = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

String formatDateTime(DateTime time, {bool isHourShown = true, bool isDayShown = false}){
  return "${isDayShown? "${daysOfWeek[time.weekday]!}  " : ""}${time.day.toString().padLeft(2, '0')}-${time.month.toString().padLeft(2, '0')}-${time.year}${isHourShown? " | ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}": ''}";
}

Color mainColor = Colors.redAccent;
String mainFont = "NotoSansArabic";
