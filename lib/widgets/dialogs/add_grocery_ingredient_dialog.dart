import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class AddToGroceryListDialog extends StatelessWidget {
  final List<String> ingredients;
  final ScrollController scrollController = ScrollController();

  AddToGroceryListDialog({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    Map<String, int> groceryCategoriesMap = context.read<SettingsBloc>().state.groceryCategoriesMap;
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        backgroundColor: Centre.dialogBgColor,
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
                            flex: 2,
                            child: RawScrollbar(
                              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                              trackVisibility: true,
                              thumbVisibility: true,
                              controller: scrollController,
                              thumbColor: const Color.fromARGB(199, 121, 181, 156),
                              radius: const Radius.circular(8),
                              scrollbarOrientation: ScrollbarOrientation.left,
                              thickness: 0.8.w,
                              child: Container(
                                margin: EdgeInsets.only(left: 4.w, right: 2.w),
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Centre.shadowbgColor,
                                    ),
                                    BoxShadow(
                                      color: Centre.dialogBgColor,
                                      spreadRadius: -2.0,
                                      blurRadius: 10.0,
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (String ingredient in ingredients)
                                        LongPressDraggable<String>(
                                            data: ingredient,
                                            dragAnchorStrategy: (Draggable<Object> _, BuildContext __, Offset ___) =>
                                                const Offset(50, 40),
                                            onDragCompleted: () {
                                              if (context
                                                  .read<MultiSelectIngredientsCubit>()
                                                  .state
                                                  .contains(ingredient)) {
                                                for (String item in context.read<MultiSelectIngredientsCubit>().state) {
                                                  context.read<IngredientsAlreadyDraggedCubit>().add(item: item);
                                                }
                                                context.read<MultiSelectIngredientsCubit>().clear();
                                              } else {
                                                context.read<IngredientsAlreadyDraggedCubit>().add(item: ingredient);
                                              }
                                            },
                                            feedback: Material(
                                              color: Colors.transparent,
                                              child: BlocBuilder<MultiSelectIngredientsCubit, List<String>>(
                                                  bloc: context.read<MultiSelectIngredientsCubit>(),
                                                  builder: (_, multiSelectList) {
                                                    return multiSelectList.contains(ingredient)
                                                        ? Container(
                                                            width: 8.w,
                                                            height: 8.w,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(50),
                                                                border: Border.all(color: Centre.primaryColor),
                                                                color: Centre.primaryColor.withAlpha(150)),
                                                          )
                                                        : Text(
                                                            '\u2022 $ingredient',
                                                            style: Centre.recipeText,
                                                            overflow: TextOverflow.ellipsis,
                                                          );
                                                  }),
                                            ),
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
                                                  padding:
                                                      EdgeInsets.only(top: 0.5.h, bottom: 0.5.h, left: 2.w, right: 2.w),
                                                  margin: EdgeInsets.only(right: 5.w, top: 1.h),
                                                  decoration: BoxDecoration(
                                                      color: multiSelectList.contains(ingredient)
                                                          ? Centre.primaryColor.withAlpha(130)
                                                          : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(10)),
                                                  child: BlocBuilder<IngredientsAlreadyDraggedCubit, List<String>>(
                                                      builder: (context, state) {
                                                    return Row(
                                                      children: [
                                                        Text(
                                                          '\u2022 ',
                                                          style: Centre.recipeText,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            ingredient,
                                                            style: Centre.recipeText.copyWith(
                                                                decoration: state.contains(ingredient)
                                                                    ? TextDecoration.lineThrough
                                                                    : null),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                );
                                              }),
                                            ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (String category in groceryCategoriesMap.keys)
                                  Expanded(
                                    child: BlocBuilder<IngredientToGroceryCategoryHover, String>(
                                        builder: (context, hoveredCategory) {
                                      return DragTarget<String>(onAcceptWithDetails: (details) {
                                        context.read<IngredientToGroceryCategoryHover>().update(hoveredCategory: "");
                                        if (context.read<MultiSelectIngredientsCubit>().state.contains(details.data)) {
                                          for (String item in context.read<MultiSelectIngredientsCubit>().state) {
                                            context.read<GroceryBloc>().add(AddIngredient(item, category));
                                          }
                                        } else {
                                          context.read<GroceryBloc>().add(AddIngredient(details.data, category));
                                        }
                                      }, onWillAcceptWithDetails: (details) {
                                        context
                                            .read<IngredientToGroceryCategoryHover>()
                                            .update(hoveredCategory: category);
                                        return true;
                                      }, onLeave: (data) {
                                        if (hoveredCategory == category) {
                                          context.read<IngredientToGroceryCategoryHover>().update(hoveredCategory: "");
                                        }
                                      }, builder: (context, candidateData, rejectedData) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(vertical: 1.h),
                                          padding: EdgeInsets.symmetric(vertical: 0.2.h, horizontal: 2.w),
                                          decoration: BoxDecoration(
                                            color: Color(groceryCategoriesMap[category]!)
                                                .withAlpha(hoveredCategory == category ? 235 : 120),
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            border: Border.all(
                                              color: Color(groceryCategoriesMap[category]!),
                                              width: 0.5.w,
                                            ),
                                          ),
                                          child: Center(
                                              child: AutoSizeText(
                                            category,
                                            minFontSize: 7,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Centre.listText,
                                            textAlign: TextAlign.center,
                                          )),
                                        );
                                      });
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
