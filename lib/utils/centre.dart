import 'package:flutter/material.dart';

class Centre {
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double screenWidth;
  static late double screenHeight;

  static Color bgColor = const Color.fromARGB(255, 221, 212, 211);
  static Color shadowbgColor = const Color.fromARGB(255, 198, 191, 190);

  static final titleText = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: Centre.safeBlockHorizontal * 5,
      fontFamily: 'Raleway');

  static final semiTitleText = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: Centre.safeBlockHorizontal * 4,
      fontFamily: 'Raleway');
  static final listText = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: Centre.safeBlockHorizontal * 3.5,
      fontFamily: 'Raleway');

  void init(BuildContext buildContext) {
    MediaQueryData mediaQueryData;
    double safeAreaHorizontal;
    double safeAreaVertical;
    mediaQueryData = MediaQuery.of(buildContext);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    safeAreaHorizontal =
        mediaQueryData.padding.left + mediaQueryData.padding.right;
    safeAreaVertical =
        mediaQueryData.padding.top + mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }
}
