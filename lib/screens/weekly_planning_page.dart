import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/blocs/weekly_planning_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
                  offset: Offset(0, 3),
                ),
              ],
              color: Centre.bgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            margin: EdgeInsets.only(
                left: Centre.safeBlockHorizontal * 7,
                right: Centre.safeBlockHorizontal * 7,
                top: Centre.safeBlockVertical * 2),
            width: Centre.screenWidth - Centre.safeBlockHorizontal * 14,
            height: Centre.safeBlockVertical * 8,
            padding: EdgeInsets.all(Centre.safeBlockHorizontal * 3),
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
                        width: Centre.safeBlockHorizontal * (currentWeekRanges.length / 2 == 3 ? 20 : 35),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal * 3),
                          decoration: BoxDecoration(
                            color: selected == i ? const Color.fromARGB(255, 218, 180, 197) : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Center(
                            child: Text(
                              "${currentWeekRanges[i * 2].day} - ${currentWeekRanges[i * 2 + 1].day}",
                              style: TextStyle(
                                  fontSize: Centre.safeBlockVertical * (currentWeekRanges.length / 2 == 3 ? 1.7 : 2)),
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
        margin: EdgeInsets.only(bottom: Centre.safeBlockVertical * 0.5),
        height: Centre.safeBlockVertical * 4,
        decoration: BoxDecoration(
          color: mealName.isEmpty
              ? const Color.fromARGB(255, 188, 188, 188)
              : Color(context.read<SettingsBloc>().state.recipeCategoriesMap[category] ?? Colors.blueGrey.value),
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: RDottedLineBorder.all(
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            mealName,
            style: TextStyle(fontSize: Centre.safeBlockVertical * 1.8),
          ),
        ),
      ),
    );
  }

  Widget dayTile(
      String dayText, List<String> mealsInDay, Map<String, Recipe> recipeTitlestoRecipeMap, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal * 5),
      width: Centre.safeBlockHorizontal * 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dayText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: Centre.safeBlockVertical * 2),
          ),
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
                  padding: EdgeInsets.only(top: Centre.safeBlockVertical * 13),
                  crossAxisCount: 2,
                  mainAxisSpacing: Centre.safeBlockVertical * 4,
                  crossAxisSpacing: Centre.safeBlockHorizontal,
                  itemCount: 9, // 7 days + a space widget to appear staggered
                  itemBuilder: (unUsedContext, index) {
                    if (index == 1) {
                      return SizedBox(height: Centre.safeBlockVertical * 5);
                    } else if (index == 8) {
                      return SizedBox(height: Centre.safeBlockVertical * 30);
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
