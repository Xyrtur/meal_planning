import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/blocs/weekly_planning_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sizer/sizer.dart';

class WeeklyPlanningPage extends StatelessWidget {
  const WeeklyPlanningPage({super.key});

  Widget weekRangeHeader(BuildContext context, List<DateTime> currentWeekRanges) {
    // on initial on weekRangepressed, rebuild
    return BlocBuilder<WeeklyPlanningBloc, WeeklyPlanningState>(
        buildWhen: (previous, current) => current is WeeklyPlanningWeekRangeUpdated,
        builder: (context, state) {
          int selected = state is WeeklyPlanningInitial
              ? state.initialSelected
              : (state as WeeklyPlanningWeekRangeUpdated).selected;
          return Container(
            decoration: ShapeDecoration(
              shadows: [
                BoxShadow(
                  color: Centre.shadowbgColor,
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
              color: Centre.bgColor,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            margin: EdgeInsets.only(left: 7.w, right: 7.w, top: 2.h),
            width: 86.w,
            height: 8.h,
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < currentWeekRanges.length / 2; i++)
                  GestureDetector(
                    onTap: () {
                      context.read<WeeklyPlanningBloc>().add(WeeklyPlanningWeekRangePressed(i));
                    },
                    child: SizedBox(
                        width: (currentWeekRanges.length / 2 == 3 ? 20 : 35).w,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: selected == i ? const Color.fromARGB(255, 218, 180, 197) : Colors.transparent,
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Center(
                            child: Text(
                              "${currentWeekRanges[i * 2].day} - ${currentWeekRanges[i * 2 + 1].day}",
                              style: TextStyle(fontSize: (currentWeekRanges.length / 2 == 3 ? 1.7 : 2).h),
                            ),
                          ),
                        )),
                  )
              ],
            ),
          );
        });
  }

  Widget mealTile({required String mealName, required String category, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        //TODO: Open dialog
        // Provide the all recipes bloc
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 0.5.h),
        height: 4.h,
        decoration: BoxDecoration(
          color: mealName.isEmpty
              ? const Color.fromARGB(255, 188, 188, 188)
              : Color(context.read<SettingsBloc>().state.recipeCategoriesMap[category] ?? Colors.blueGrey.value),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: RDottedLineBorder.all(
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            mealName,
            style: TextStyle(fontSize: 5.sp),
          ),
        ),
      ),
    );
  }

  Widget dayTile(
      String dayText, List<String> mealsInDay, Map<String, Recipe> recipeTitlestoRecipeMap, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      width: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dayText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp, color: Colors.black)),
          for (int i = 0; i < 5; i++)
            mealTile(
                mealName: mealsInDay[i],
                category: recipeTitlestoRecipeMap[mealsInDay[i]]?.category ?? "",
                context: context)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WeeklyPlanningInitial initialState = context.read<WeeklyPlanningBloc>().state as WeeklyPlanningInitial;
    List<List<String>> mealsList = initialState.mealsList;
    int selectedWeekRange = initialState.initialSelected;
    List<DateTime> currentWeekRanges = initialState.currentWeekRanges;
    Map<String, Recipe> recipeTitlestoRecipeMap = initialState.recipeTitlestoRecipeMap;

    const List<String> dayTexts = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"];

    return SafeArea(
        child: Scaffold(
            backgroundColor: Centre.bgColor,
            body: Stack(children: [
              BlocConsumer<WeeklyPlanningBloc, WeeklyPlanningState>(listener: (unUsedContext, state) {
                if (state is WeeklyPlanningWeekRangeUpdated) {
                  selectedWeekRange = state.selected;
                }
                if (state is WeeklyPlanningMealsUpdated) {
                  mealsList = state.mealsList;
                }
              }, builder: (unUsedContext, state) {
                return MasonryGridView.count(
                  padding: EdgeInsets.only(top: 13.h),
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.h,
                  crossAxisSpacing: 1.w,
                  itemCount: 9, // 7 days + a space widget to appear staggered
                  itemBuilder: (unUsedContext, index) {
                    if (index == 1) {
                      return SizedBox(height: 5.h);
                    } else if (index == 8) {
                      return SizedBox(height: 30.h);
                    } else {
                      index = index - 1 < 0 ? index : index - 1;
                      return dayTile(
                          dayTexts[index], mealsList[selectedWeekRange * 7 + index], recipeTitlestoRecipeMap, context);
                    }
                  },
                );
              }),
              weekRangeHeader(context, currentWeekRanges),
            ])));
  }
}
