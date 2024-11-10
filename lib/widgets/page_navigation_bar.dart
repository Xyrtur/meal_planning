import 'package:flutter/material.dart';
import 'package:meal_planning/utils/centre.dart';

class PageNavigationBar extends StatelessWidget {
  final PageController pageController;
  const PageNavigationBar({super.key, required this.pageController});

  Widget pageNavButton({required int index, required IconData icon}) {
    return GestureDetector(
        onTap: () {
          pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        child: Icon(
          icon,
          size: Centre.safeBlockHorizontal * 8,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: Centre.screenHeight,
        width: Centre.screenWidth,
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: Centre.safeBlockHorizontal * 12,
                ),
                Container(
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Centre.shadowbgColor,
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Centre.bgColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  width: Centre.safeBlockHorizontal * 60,
                  padding: EdgeInsets.all(Centre.safeBlockHorizontal * 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      pageNavButton(index: 0, icon: Icons.first_page),
                      pageNavButton(index: 1, icon: Icons.pages),
                      pageNavButton(index: 2, icon: Icons.last_page),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //TODO: open settings page
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          color: Centre.shadowbgColor,
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Centre.bgColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    width: Centre.safeBlockHorizontal * 10,
                    padding: EdgeInsets.all(Centre.safeBlockHorizontal),
                    margin:
                        EdgeInsets.only(left: Centre.safeBlockHorizontal * 2),
                    child: Icon(
                      Icons.settings,
                      size: Centre.safeBlockHorizontal * 7,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: Centre.safeBlockVertical * 3,
            )
          ],
        ));
  }
}
