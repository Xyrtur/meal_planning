import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/screens/all_recipes_page.dart';
import 'package:meal_planning/utils/centre.dart';
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
            height: 50.h,
            width: 69.w,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilterArea(),
                  GenericMealPicker(),
                  RecipeSearchbar(),
                  RecipeListview(isWeeklyPlanning: true)
                ],
              ),
            )));
  }
}

class GenericMealPicker extends StatelessWidget {
  const GenericMealPicker({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, int> genericCategoriesMap =
        context.read<SettingsBloc>().state.genericCategoriesMap;
    return Column(
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
