import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class AddToGroceryListDialog extends StatelessWidget {
  final List<String> ingredients;
  const AddToGroceryListDialog({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    Map<String, int> groceryCategoriesMap = context.read<SettingsBloc>().state.groceryCategoriesMap;
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        backgroundColor: Centre.shadowbgColor,
        elevation: 0,
        content: SizedBox(
            height: 55.h,
            width: 69.w,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Add to Grocery List",
                      style: Centre.semiTitleText,
                    ),
                    Divider(
                      height: 0.5.h,
                      color: Centre.primaryColor,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (String ingredient in ingredients)
                                  Draggable<String>(
                                      data: ingredient,
                                      onDragCompleted: () {
                                        if (context.read<MultiSelectIngredientsCubit>().state.contains(ingredient)) {
                                          for (String item in context.read<MultiSelectIngredientsCubit>().state) {
                                            context.read<IngredientsAlreadyDraggedCubit>().add(item: item);
                                          }
                                          context.read<MultiSelectIngredientsCubit>().clear();
                                        } else {
                                          context.read<IngredientsAlreadyDraggedCubit>().add(item: ingredient);
                                        }
                                      },
                                      feedback: BlocBuilder<MultiSelectIngredientsCubit, List<String>>(
                                          bloc: context.read<MultiSelectIngredientsCubit>(),
                                          builder: (_, multiSelectList) {
                                            return Padding(
                                              padding: EdgeInsets.all(3.w),
                                              child: multiSelectList.contains(ingredient)
                                                  ? Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        for (String item in multiSelectList)
                                                          Text('\u2022 $item', style: Centre.listText)
                                                      ],
                                                    )
                                                  : Text('\u2022 $ingredient', style: Centre.listText),
                                            );
                                          }),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          context
                                              .read<MultiSelectIngredientsCubit>()
                                              .toggleMultiSelect(item: ingredient);
                                        },
                                        child: BlocBuilder<MultiSelectIngredientsCubit, List<String>>(
                                            builder: (context, multiSelectList) {
                                          return Container(
                                            padding: EdgeInsets.all(3.w),
                                            decoration: BoxDecoration(
                                                color: multiSelectList.contains(ingredient)
                                                    ? Centre.primaryColor.withAlpha(130)
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(10)),
                                            child: BlocBuilder<IngredientsAlreadyDraggedCubit, List<String>>(
                                                builder: (context, state) {
                                              return Text(
                                                '\u2022 $ingredient',
                                                style: Centre.listText.copyWith(
                                                    decoration:
                                                        state.contains(ingredient) ? TextDecoration.lineThrough : null),
                                              );
                                            }),
                                          );
                                        }),
                                      ))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (String category in groceryCategoriesMap.keys)
                                  Expanded(
                                    child: DragTarget<String>(onAcceptWithDetails: (details) {
                                      if (context.read<MultiSelectIngredientsCubit>().state.contains(details.data)) {
                                        for (String item in context.read<MultiSelectIngredientsCubit>().state) {
                                          context.read<GroceryBloc>().add(AddIngredient(item, category));
                                        }
                                      } else {
                                        context.read<GroceryBloc>().add(AddIngredient(details.data, category));
                                      }
                                    }, onWillAcceptWithDetails: (details) {
                                      return true;
                                    }, builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: Color(groceryCategoriesMap[category]!),
                                            borderRadius: BorderRadius.circular(20)),
                                        child: Center(
                                            child: Text(
                                          category,
                                          style: Centre.semiTitleText,
                                          textAlign: TextAlign.center,
                                        )),
                                      );
                                    }),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
