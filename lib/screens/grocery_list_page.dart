import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/grocery_category_box.dart';

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

  Widget clearButton({required void Function() onTap, required ClearButton type}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 248, 172, 197), width: Centre.safeBlockHorizontal),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: type == ClearButton.clearAll
              ? Text("clear all")
              : Row(
                  children: [Text("clear"), Icon(Icons.check_box_outlined)],
                ),
        ));
  }

  @override
  Widget build(BuildContext topContext) {
    Centre().init(topContext);
    Map<String, List<GroceryItem>> items = (topContext.read<GroceryBloc>().state as GroceryInitial).items;
    List<String> collapsedCategories = items.keys.toList();

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
                                  Map<String, List<GroceryItem>> itemsToDelete = {};
                                  for (String category in items.keys) {
                                    for (GroceryItem item in items[category]!) {
                                      if (itemsToDelete.containsKey(category)) {
                                        itemsToDelete[category]!.add(item);
                                      } else {
                                        itemsToDelete[category] = [item];
                                      }
                                    }
                                  }
                                  topContext.read<GroceryBloc>().add(DeleteIngredients(itemsToDelete));
                                },
                                type: ClearButton.clearChecked),
                            clearButton(
                                onTap: () {
                                  topContext.read<GroceryBloc>().add(DeleteIngredients(items));
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
                  builder: (context, toggleState) => BlocConsumer<GroceryBloc, GroceryState>(
                      listener: ((context, state) {
                        if (state is GroceryInitial || state is GroceryListUpdated) {
                          items = state.props[0] as Map<String, List<GroceryItem>>;
                        } else if (state is GroceryCategoryToggled) {
                          if (collapsedCategories.contains(state.category)) {
                            collapsedCategories.remove(state.category);
                          } else {
                            collapsedCategories.add(state.category);
                          }
                        }
                      }),
                      builder: (context, groceryState) => Column(
                            children: [
                              for (String category in items.keys)
                                GroceryCategoryBox(
                                  isExpanded: !collapsedCategories.contains(category),
                                  categoryName: category,
                                  categoryItems: items[category]!,
                                  inDeleteMode: toggleState,
                                  categoryColor:
                                      Color(context.read<SettingsBloc>().state.groceryCategoriesMap[category]!),
                                )
                            ],
                          )),
                ))
              ],
            )));
  }
}
