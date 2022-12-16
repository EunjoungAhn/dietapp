import 'package:flutter/material.dart';

Color mainColor = Color(0xFF81d0d6);
Color bgColor = Colors.white;
Color ibgColor = Colors.grey.withOpacity(0.1);
Color txtColor = Colors.black;
Color iTxtColor = Colors.black38;
double cardSize = 150;

TextStyle smallTS = TextStyle(fontSize: 12);
TextStyle middleTS = TextStyle(fontSize: 16);
TextStyle largeTS = TextStyle(fontSize: 20);

void changeToDarkMode(){
  bgColor = Color(0xFF3a3a3c);
  txtColor = Colors.white;
}
// 앱 메인 컬러 전체적으로 적용
MaterialColor mainMColor = MaterialColor(
mainColor.value,
  <int, Color>{
  50: mainColor,
  100: mainColor,
  200: mainColor,
  300: mainColor,
  400: mainColor,
  500: mainColor,
  600: mainColor,
  700: mainColor,
  800: mainColor,
  900: mainColor,
  },
);