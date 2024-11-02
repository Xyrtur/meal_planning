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
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';

class GroceryListPage extends StatelessWidget {
  const GroceryListPage({super.key});

  Widget deleteToggle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ToggleGroceryDeletingCubit>().toggle();
      },
      child: Container(),
    ); // TODO:
  }

  Widget clearButton({required void Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(),
    ); //TODO:
  }

  Widget circularButton({required void Function() onTap}) {
    return GestureDetector(onTap: onTap, child: Container());
  }

  Widget categoryBox(
      {required String categoryName,
      required List<GroceryItem> categoryItems,
      required bool inDeleteMode}) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(categoryName),
              Spacer(),
              circularButton(onTap: () {}),
              circularButton(onTap: () {})
            ],
          ),
          for (GroceryItem item in categoryItems)
            itemEntry(item: item, inDeleteMode: inDeleteMode)
        ],
      ),
    );
  }

  Widget itemEntry({required GroceryItem item, required bool inDeleteMode}) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: inDeleteMode
              ? Icon(Icons.delete)
              : Container(
                  width: Centre.safeBlockHorizontal * 5,
                  height: Centre.safeBlockHorizontal * 5,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  child: item.isChecked ? Icon(Icons.check) : null,
                ),
        ),
        GestureDetector(
          onTap: () {
            if (!inDeleteMode) {
              // TODO: set to checked
            }
          },
          child: Text(
            item.name,
            style: TextStyle(
                decoration: item.isChecked ? TextDecoration.lineThrough : null),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Centre().init(context);
    Map<String, List<GroceryItem>> items =
        (context.read<GroceryBloc>().state as GroceryInitial).items;

    return SafeArea(
        child: Scaffold(
            backgroundColor: Centre.bgColor,
            body: Column(
              children: [
                Row(
                  children: [
                    Text("Grocery List"),
                    Column(
                      children: [
                        deleteToggle(context),
                        Row(
                          children: [
                            clearButton(onTap: () {
                              Map<String, List<GroceryItem>> itemsToDelete = {};
                              context
                                  .read<GroceryBloc>()
                                  .add(DeleteIngredients(itemsToDelete));
                            }),
                            clearButton(onTap: () {/*TODO: send event */})
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
                                        inDeleteMode: toggleState)
                                ],
                              )),
                ))
              ],
            )));
  }
}
