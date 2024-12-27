import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planning/blocs/all_recipes_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/blocs/weekly_planning_bloc.dart';
import 'package:meal_planning/screens/all_recipes_page.dart';
import 'package:meal_planning/screens/grocery_list_page.dart';
import 'package:meal_planning/screens/weekly_planning_page.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:meal_planning/widgets/page_navigation_bar.dart';
import 'package:sizer/sizer.dart';
import '../utils/centre.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

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
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Scaffold(
        backgroundColor: Centre.bgColor,
        body: Stack(
          children: [
            PageView(
              controller: controller,
              children: [
                MultiBlocProvider(providers: [
                  BlocProvider<WeeklyPlanningBloc>(
                    create: (_) =>
                        WeeklyPlanningBloc(context.read<HiveRepository>()),
                  ),
                ], child: WeeklyPlanningPage()),
                MultiBlocProvider(providers: [
                  BlocProvider.value(
                    value: context.read<GroceryBloc>(),
                  ),
                  BlocProvider<ToggleGroceryDeletingCubit>(
                    create: (_) => ToggleGroceryDeletingCubit(),
                  ),
                  BlocProvider<GroceryCategoryOrderCubit>(
                    create: (_) => GroceryCategoryOrderCubit(
                        context.read<HiveRepository>()),
                  ),
                  BlocProvider<GroceryDraggingItemCubit>(
                    create: (_) => GroceryDraggingItemCubit(),
                  ),
                  BlocProvider<GroceryScrollDraggingCubit>(
                    create: (_) => GroceryScrollDraggingCubit(),
                  ),
                  BlocProvider<GroceryCategoryHover>(
                    create: (_) => GroceryCategoryHover(),
                  ),
                  BlocProvider.value(value: context.read<SettingsBloc>())
                ], child: const GroceryListPage()),
                MultiBlocProvider(providers: [
                  BlocProvider<AllRecipesBloc>(
                    create: (_) =>
                        AllRecipesBloc(context.read<HiveRepository>()),
                  ),
                  BlocProvider.value(
                    value: context.read<GroceryBloc>(),
                  ),
                ], child: const AllRecipesPage())
              ],
            ),
            PageNavigationBar(
              pageController: controller,
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
                            height: 5.h,
                          )
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
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
