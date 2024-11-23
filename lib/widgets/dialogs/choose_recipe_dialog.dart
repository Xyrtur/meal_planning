import 'package:flutter/material.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class ChooseRecipeDialog extends StatelessWidget {
  const ChooseRecipeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        color: Centre.shadowbgColor,
        elevation: 0,
        child: SizedBox(
            height: 15.8.h,
            width: 69.w,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              child: BlocBuilder<RecipeCategoriesSelectedCubit, List<String>>(builder: (context, currentSelected) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (String category in categoriesMap.keys)
                      categoryCheckbox(
                          category: category,
                          color: categoriesMap[category]!,
                          checked: currentSelected.contains(category))
                  ],
                );
              }),
            )));
  }
}
