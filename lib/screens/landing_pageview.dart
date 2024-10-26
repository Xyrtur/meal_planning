import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planning/screens/all_recipes_page.dart';
import 'package:meal_planning/screens/grocery_list_page.dart';
import 'package:meal_planning/screens/weekly_planning_page.dart';
import '../utils/centre.dart';

class LandingPageView extends StatefulWidget {
  LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  PageController controller = PageController(
    initialPage: 0,
  );
  double _visible = 1;
  bool finishedAnimating = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Wait 100ms before fading out
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _visible = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Centre().init(context);

    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Material(
        child: Scaffold(
          backgroundColor: Centre.bgColor,
          body: Stack(
            children: [
              PageView(
                controller: controller,
                children: [
                  //TODO: Provide RecipeSearchbarBloc
                  const WeeklyPlanningPage(),

                  //TODO: Provide GroceryListBloc
                  const GroceryListPage(),

                  //TODO: Provide FilterBloc, RecipeSearchbarBloc
                  const AllRecipesPage()
                ],
              ),
              !finishedAnimating
                  ? AnimatedOpacity(
                      onEnd: () {
                        setState(() {
                          finishedAnimating = true;
                        });
                      },
                      opacity: _visible,
                      duration: const Duration(milliseconds: 1000),
                      child: Container(
                        color: Centre.bgColor,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: LottieBuilder.asset(
                                    "assets/splash_animation.json")),
                            SizedBox(
                              height: Centre.safeBlockVertical * 5.5,
                            )
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
