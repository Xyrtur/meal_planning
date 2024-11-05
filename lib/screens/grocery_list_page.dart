/*
 *
 * 
 * 
 * for each categories make the right coloured box
 *  for each of the values in its list, the ingredients
 *    make a text line with checkbox 
 * 
 * onClearCheckedClicked
 * 
 * onClearAllClicked
 * 
 * onDeleteClicked
 * 
 * For each item 
 * 
 * onClick() sendGrcoeryItemUpdate checked
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';

enum ClearButton { clearAll, clearChecked }

class GroceryListPage extends StatelessWidget {
  const GroceryListPage({super.key});

  Widget deleteToggle(BuildContext context) {
    return BlocBuilder<ToggleGroceryDeletingCubit, bool>(
        builder: (context, toggleState) => ToggleButtons(
              onPressed: (int index) {
                context.read<ToggleGroceryDeletingCubit>().toggle();
              },
              isSelected: [!toggleState, toggleState], // list, in delete mode
              selectedColor: const Color.fromARGB(255, 248, 172, 197),
              color: Centre.bgColor,
              fillColor: Centre.bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              borderWidth: Centre.safeBlockHorizontal,
              borderColor: Colors.blue,
              selectedBorderColor: Colors.blue,
              children: <Widget>[
                Icon(
                  Icons.checklist_rounded,
                  size: Centre.safeBlockVertical * 3,
                ),
                Icon(
                  Icons.delete,
                  size: Centre.safeBlockVertical * 3,
                ),
              ],
            ));
  }

  Widget clearButton(
      {required void Function() onTap, required ClearButton type}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 248, 172, 197),
                width: Centre.safeBlockHorizontal),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: type == ClearButton.clearAll
              ? Text("clear all")
              : Row(
                  children: [Text("clear"), Icon(Icons.check_box_outlined)],
                ),
        )); //TODO:
  }

  Widget circularButton(
      {required void Function() onTap,
      required Color categoryColor,
      required IconData icon}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: categoryColor, width: Centre.safeBlockHorizontal),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Icon(icon),
        ));
  }

  Widget categoryBox(
      {required String categoryName,
      required List<GroceryItem> categoryItems,
      required bool inDeleteMode,
      required BuildContext context}) {
    Color categoryColor = Color(
        context.read<SettingsBloc>().state.groceryCategoriesMap[categoryName]!);
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: categoryColor, width: Centre.safeBlockHorizontal),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                categoryName,
                style: Centre.semiTitleText,
              ),
              Spacer(),
              circularButton(
                  onTap: () {}, categoryColor: categoryColor, icon: Icons.add),
              circularButton(
                  onTap: () {},
                  categoryColor: categoryColor,
                  icon: Icons.expand)
            ],
          ),
          for (int i = 0; i < categoryItems.length; i++)
            itemEntry(
                item: categoryItems[i],
                index: i,
                inDeleteMode: inDeleteMode,
                context: context,
                category: categoryName)
        ],
      ),
    );
  }

  Widget itemEntry(
      {required GroceryItem item,
      required int index,
      required bool inDeleteMode,
      required BuildContext context,
      required String category}) {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              if (inDeleteMode) {
                context.read<GroceryBloc>().add(DeleteIngredients({
                      category: [item]
                    }));
              } else {
                context
                    .read<GroceryBloc>()
                    .add(UpdateIngredientsChecked(!item.isChecked, index, {
                      category: [item]
                    }));
              }
            },
            child: inDeleteMode
                ? Icon(Icons.delete)
                : item.isChecked
                    ? Icon(Icons.check_box_rounded)
                    : Icon(Icons.check_box_outline_blank)),
        GestureDetector(
          onTap: () {
            if (!inDeleteMode) {
              context
                  .read<GroceryBloc>()
                  .add(UpdateIngredientsChecked(!item.isChecked, index, {
                    category: [item]
                  }));
            }
          },
          child: Text(
            item.name,
            style: Centre.listText.copyWith(
                decoration: item.isChecked ? TextDecoration.lineThrough : null),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext topContext) {
    Centre().init(topContext);
    Map<String, List<GroceryItem>> items =
        (topContext.read<GroceryBloc>().state as GroceryInitial).items;

    return SafeArea(
        child: Scaffold(
            backgroundColor: Centre.bgColor,
            body: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Grocery List",
                      style: Centre.titleText,
                    ),
                    Column(
                      children: [
                        deleteToggle(topContext),
                        Row(
                          children: [
                            clearButton(
                                onTap: () {
                                  Map<String, List<GroceryItem>> itemsToDelete =
                                      {};
                                  for (String category in items.keys) {
                                    for (GroceryItem item in items[category]!) {
                                      if (itemsToDelete.containsKey(category)) {
                                        itemsToDelete[category]!.add(item);
                                      } else {
                                        itemsToDelete[category] = [item];
                                      }
                                    }
                                  }
                                  topContext
                                      .read<GroceryBloc>()
                                      .add(DeleteIngredients(itemsToDelete));
                                },
                                type: ClearButton.clearChecked),
                            clearButton(
                                onTap: () {
                                  topContext
                                      .read<GroceryBloc>()
                                      .add(DeleteIngredients(items));
                                },
                                type: ClearButton.clearAll)
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                Expanded(
                    child: BlocBuilder<ToggleGroceryDeletingCubit, bool>(
                  builder: (context, toggleState) =>
                      BlocConsumer<GroceryBloc, GroceryState>(
                          listener: ((context, state) {
                            if (state is GroceryInitial ||
                                state is GroceryListUpdated) {
                              items = state.props[0]
                                  as Map<String, List<GroceryItem>>;
                            }
                          }),
                          builder: (context, groceryState) => Column(
                                children: [
                                  for (String category in items.keys)
                                    categoryBox(
                                        categoryName: category,
                                        categoryItems: items[category]!,
                                        inDeleteMode: toggleState,
                                        context: topContext)
                                ],
                              )),
                ))
              ],
            )));
  }
}
