import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class FilterCategoryDialog extends StatelessWidget {
  final Map<String, int> categoriesMap;
  const FilterCategoryDialog({super.key, required this.categoriesMap});

  @override
  Widget build(BuildContext context) {
    Widget categoryCheckbox({required String category, required int color, required bool checked}) {
      return GestureDetector(
        onTap: () {
          context.read<RecipeCategoriesSelectedCubit>().addDeleteCategory(category: category);
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Row(
            children: [
              checked ? const Icon(Icons.check_box_rounded) : const Icon(Icons.check_box_outline_blank),
              Text(category)
            ],
          ),
        ),
      );
    }

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
