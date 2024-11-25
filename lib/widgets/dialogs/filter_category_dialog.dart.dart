import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/all_recipes_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class FilterCategoryDialog extends StatelessWidget {
  final bool isWeeklyPlanning;
  final Map<String, int> categoriesMap;
  const FilterCategoryDialog({super.key, required this.categoriesMap, required this.isWeeklyPlanning});

  @override
  Widget build(BuildContext context) {
    Widget categoryCheckbox({required String category, required int color, required bool checked}) {
      return GestureDetector(
        onTap: () {
          if (isWeeklyPlanning) {
            context.read<AllRecipesBloc>().add(FilterToggle(category));
          }
          context.read<RecipeCategoriesSelectedCubit>().addDeleteCategory(category: category);
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Row(
            children: [
              checked ? const Icon(Icons.check_box_rounded) : const Icon(Icons.check_box_outline_blank),
              Expanded(
                  child: Text(
                category,
                maxLines: 2,
              ))
            ],
          ),
        ),
      );
    }

    return Material(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        color: Centre.shadowbgColor,
        elevation: isWeeklyPlanning ? 3 : 0,
        child: SizedBox(
            height: isWeeklyPlanning ? categoriesMap.keys.length * 5.1.h : categoriesMap.keys.length * 5.1.h,
            width: 50.w,
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
