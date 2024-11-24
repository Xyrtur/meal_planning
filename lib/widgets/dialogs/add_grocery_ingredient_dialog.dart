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
    Map<String, int> groceryCategoriesMap =
        context.read<SettingsBloc>().state.groceryCategoriesMap;
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
                child: Row(
                  children: [
                    Column(
                      children: [
                        for (String ingredient in ingredients)
                          Draggable(
                              onDragCompleted: () {
                                context
                                    .read<IngredientsAlreadyDraggedCubit>()
                                    .add(item: ingredient);
                              },
                              feedback: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: Text(ingredient),
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  //TODO: add ot multiselect cubit thing
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: BlocBuilder<
                                      IngredientsAlreadyDraggedCubit,
                                      List<String>>(builder: (context, state) {
                                    return Text(
                                      ingredient,
                                      style: Centre.listText.copyWith(
                                          decoration: state.contains(ingredient)
                                              ? TextDecoration.lineThrough
                                              : null),
                                    );
                                  }),
                                ),
                              ))
                      ],
                    ),
                    Column(
                      children: [
                        for (String category in groceryCategoriesMap.keys)
                          DragTarget<String>(onAcceptWithDetails: (details) {
                            context
                                .read<GroceryBloc>()
                                .add(AddIngredient(details.data, category));
                          }, onWillAcceptWithDetails: (details) {
                            //TODO: change color
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
                              )),
                            );
                          })
                      ],
                    )
                  ],
                ))));
  }
}
