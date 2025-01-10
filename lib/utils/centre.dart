import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Centre {
  static Color bgColor = const Color.fromARGB(255, 240, 229, 228);
  static Color primaryColor = const Color.fromARGB(255, 88, 105, 219);
  static Color shadowbgColor = const Color.fromARGB(255, 198, 191, 190);
  static Color dialogBgColor = const Color.fromARGB(255, 219, 210, 209);

  static const List<Color> colors = [
    // First row
    Color.fromARGB(255, 243, 124, 149),
    Color.fromARGB(255, 255, 140, 198),
    Color.fromARGB(255, 244, 165, 105),
    Color.fromARGB(255, 211, 170, 186),
    Color.fromARGB(255, 206, 128, 232),
    Color.fromARGB(255, 253, 183, 145),
    Color.fromARGB(255, 172, 216, 170),
    Color.fromARGB(255, 168, 247, 246),
    Color.fromARGB(255, 255, 217, 125),

    // Second row
    Color.fromARGB(255, 86, 205, 132),
    Color.fromARGB(255, 139, 168, 248),
    Color.fromARGB(255, 126, 213, 224),
    Color.fromARGB(255, 177, 190, 220),
    Color.fromARGB(255, 244, 223, 88),
    Color.fromARGB(255, 226, 174, 221),
    Color.fromARGB(255, 193, 251, 164),
    Color.fromARGB(255, 251, 188, 207),
    Color.fromARGB(255, 255, 155, 133),
  ];

  static final titleText =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20.sp, fontFamily: 'Raleway');

  static final semiTitleText =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 17.sp, fontFamily: 'Raleway');
  static final listText =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15.sp, fontFamily: 'Raleway');
  static final ingredientText =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14.sp, fontFamily: 'Raleway');

  static final recipeText = TextStyle(
      color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14.sp, fontFamily: 'Raleway', height: 0.15.h);
}
