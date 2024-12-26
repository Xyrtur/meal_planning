import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/all_recipes_bloc.dart';
import 'package:meal_planning/blocs/import_export_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/blocs/weekly_planning_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:meal_planning/widgets/dialogs/choose_recipe_dialog.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class WeeklyPlanningPage extends StatelessWidget {
  WeeklyPlanningPage({super.key});

  final ValueNotifier<String?> mealChosen = ValueNotifier<String?>(null);

  // This is updated every time a meal is chosen
  int indexToUpdate = 0;

  Widget weekRangeHeader(
      BuildContext context, List<DateTime> currentWeekRanges) {
    // on initial on weekRangepressed, rebuild
    return BlocBuilder<WeeklyPlanningBloc, WeeklyPlanningState>(
        buildWhen: (previous, current) =>
            current is WeeklyPlanningWeekRangeUpdated,
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
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            margin: EdgeInsets.only(left: 7.w, right: 7.w, top: 2.h),
            width: 86.w,
            height: 8.h,
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < currentWeekRanges.length / 2; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      context
                          .read<WeeklyPlanningBloc>()
                          .add(WeeklyPlanningWeekRangePressed(i));
                    },
                    child: Container(
                      width: (currentWeekRanges.length / 2 == 3 ? 26.5 : 40).w,
                      decoration: BoxDecoration(
                        color: selected == i
                            ? const Color.fromARGB(255, 218, 180, 197)
                            : Colors.transparent,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Center(
                        child: Text(
                          "${currentWeekRanges[i * 2].day} - ${currentWeekRanges[i * 2 + 1].day}",
                          style: TextStyle(
                              fontSize:
                                  (currentWeekRanges.length / 2 == 3 ? 1.7 : 2)
                                      .h),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        });
  }

  Widget mealTile(
      {required String mealName,
      required String category,
      required int mealsListIndex,
      required BuildContext context}) {
    return GestureDetector(
      onLongPress: () {
        // TODO: do the multi-select
      },
      onTap: () async {
        indexToUpdate = mealsListIndex;
        mealChosen.value = await showDialog<String>(
            context: context,
            builder: (_) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<AllRecipesBloc>(
                      create: (_) =>
                          AllRecipesBloc(context.read<HiveRepository>())),
                  BlocProvider.value(value: context.read<SettingsBloc>())
                ],
                child: const ChooseRecipeDialog(),
              );
            });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 0.5.h),
        height: 4.h,
        decoration: BoxDecoration(
          color: mealName.isEmpty
              ? const Color.fromARGB(255, 188, 188, 188)
              : Color(context
                      .read<SettingsBloc>()
                      .state
                      .recipeCategoriesMap[category] ??
                  context
                      .read<SettingsBloc>()
                      .state
                      .genericCategoriesMap[mealName]!),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: RDottedLineBorder.all(
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            mealName,
            style: Centre.listText,
          ),
        ),
      ),
    );
  }

  Widget dayTile(String dayText, List<String> mealsInDay, int mealsListDayIndex,
      Map<String, Recipe> recipeTitlestoRecipeMap, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      width: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dayText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                  color: Colors.black)),
          for (int i = 0; i < 5; i++)
            mealTile(
                mealName: mealsInDay[i],
                mealsListIndex: mealsListDayIndex * 5 + i,
                category:
                    recipeTitlestoRecipeMap[mealsInDay[i]]?.categories.first ??
                        "",
                context: context)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WeeklyPlanningInitial initialState =
        context.read<WeeklyPlanningBloc>().state as WeeklyPlanningInitial;
    List<List<String>> mealsList = initialState.mealsList;
    int selectedWeekRange = initialState.initialSelected;
    List<DateTime> currentWeekRanges = initialState.currentWeekRanges;
    Map<String, Recipe> recipeTitlestoRecipeMap =
        initialState.recipeTitlestoRecipeMap;

    mealChosen.addListener(() {
      if (mealChosen.value != null) {
        context
            .read<WeeklyPlanningBloc>()
            .add(WeeklyPlanningUpdateMeal(mealChosen.value!, indexToUpdate));
        mealChosen.value = null;
      }
    });

    const List<String> dayTexts = [
      "Mon",
      "Tues",
      "Wed",
      "Thurs",
      "Fri",
      "Sat",
      "Sun"
    ];

    return SafeArea(
        child: Scaffold(
            backgroundColor: Centre.bgColor,
            body: Stack(children: [
              BlocListener<ImportExportBloc, ImportExportState>(
                listener: (context, state) {
                  if (state is ImportFinished) {
                    context
                        .read<WeeklyPlanningBloc>()
                        .add(const WeeklyPlanningImported());
                  }
                },
                child: BlocConsumer<WeeklyPlanningBloc, WeeklyPlanningState>(
                    listener: (_, state) {
                  if (state is WeeklyPlanningWeekRangeUpdated) {
                    selectedWeekRange = state.selected;
                  }
                  if (state is WeeklyPlanningMealsUpdated) {
                    mealsList = state.mealsList;
                  }
                }, builder: (_, state) {
                  return MasonryGridView.count(
                    padding: EdgeInsets.only(top: 13.h),
                    crossAxisCount: 2,
                    mainAxisSpacing: 4.h,
                    crossAxisSpacing: 1.w,
                    itemCount: 9, // 7 days + a space widget to appear staggered
                    itemBuilder: (_, index) {
                      if (index == 1) {
                        return SizedBox(height: 5.h);
                      } else if (index == 8) {
                        return SizedBox(height: 30.h);
                      } else {
                        index = index - 1 < 0 ? index : index - 1;
                        return dayTile(
                            dayTexts[index],
                            mealsList[selectedWeekRange * 7 + index],
                            selectedWeekRange * 7 + index,
                            recipeTitlestoRecipeMap,
                            context);
                      }
                    },
                  );
                }),
              ),
              weekRangeHeader(context, currentWeekRanges),
            ])));
  }
}
