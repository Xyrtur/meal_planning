import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/all_recipes_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/screens/all_recipes_page.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/dialogs/filter_category_dialog.dart.dart';
import 'package:sizer/sizer.dart';

class ChooseRecipeDialog extends StatelessWidget {
  const ChooseRecipeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        backgroundColor: Centre.shadowbgColor,
        elevation: 0,
        content: SizedBox(
            height: 55.h,
            width: 75.w,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (_) => RecipeCategoriesSelectedCubit([])),
                      BlocProvider.value(value: context.read<SettingsBloc>())
                    ],
                    child: WeeklyPlanningFilterArea(),
                  ),
                  GenericMealPicker(),
                  RecipeSearchbar(),
                  RecipeListview(isWeeklyPlanning: true)
                ],
              ),
            )));
  }
}

class WeeklyPlanningFilterArea extends StatelessWidget {
  const WeeklyPlanningFilterArea({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeCategoriesSelectedCubit, List<String>>(
        builder: (anotherContext, categoriesSelected) {
      return Wrap(
        alignment: WrapAlignment.start,
        spacing: 2.w,
        runSpacing: 0.5.h,
        children: [
          Text(
            "Filters: ",
            style: Centre.semiTitleText,
          ),
          for (String category in categoriesSelected)
            Container(
              padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: Color(context
                        .read<SettingsBloc>()
                        .state
                        .recipeCategoriesMap[category]!)
                    .withAlpha(100),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                border: Border.all(
                  color: Color(context
                      .read<SettingsBloc>()
                      .state
                      .recipeCategoriesMap[category]!),
                  width: 0.5.w,
                ),
              ),
              child: Text(category),
            ),
          GestureDetector(
            onTap: () {
              showAlignedDialog(
                barrierColor: Colors.transparent,
                followerAnchor: Alignment.topCenter,
                targetAnchor: Alignment.bottomCenter,
                offset: Offset(25.w, 2.h),
                context: anotherContext,
                builder: (BuildContext dialogContext) => GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                            value:
                                context.read<RecipeCategoriesSelectedCubit>(),
                          ),
                          BlocProvider.value(
                            value: context.read<AllRecipesBloc>(),
                          )
                        ],
                        child: FilterCategoryDialog(
                            isWeeklyPlanning: true,
                            categoriesMap: context
                                .read<SettingsBloc>()
                                .state
                                .recipeCategoriesMap),
                      )),
                ),
              );
            },
            child: Container(
                padding: EdgeInsets.all(2.w),
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
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                child: const Icon(Icons.add)),
          )
        ],
      );
    });
  }
}

class GenericMealPicker extends StatelessWidget {
  const GenericMealPicker({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, int> genericCategoriesMap =
        context.read<SettingsBloc>().state.genericCategoriesMap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Generic Meals",
          style: Centre.semiTitleText,
        ),
        Row(
          children: [
            for (String category in genericCategoriesMap.keys)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, category);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color:
                        Color(genericCategoriesMap[category]!).withAlpha(100),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    border: Border.all(
                      color: Color(genericCategoriesMap[category]!),
                      width: 0.5.w,
                    ),
                  ),
                  child: Text(category),
                ),
              )
          ],
        )
      ],
    );
  }
}
