import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/grocery_category_box.dart';
import 'package:sizer/sizer.dart';

enum ClearButton { clearAll, clearChecked }

class CategoryBoxes extends StatefulWidget {
  const CategoryBoxes({super.key});

  @override
  State<CategoryBoxes> createState() => _CategoryBoxesState();
}

class _CategoryBoxesState extends State<CategoryBoxes> {
  late Map<String, List<GroceryItem>> items;

  @override
  void initState() {
    super.initState();
    items = (context.read<GroceryBloc>().state as GroceryInitial).items;
  }

  List<String> collapsedCategories = [];
  final ScrollController scrollController = ScrollController();
  moveUp() {
    scrollController.animateTo(scrollController.offset - 100,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  moveDown() {
    scrollController.animateTo(scrollController.offset + 100,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Builder(builder: (context) {
      final settingsState = context.watch<SettingsBloc>().state;
      final isDragging = context.watch<GroceryScrollDraggingCubit>().state;
      final categoryOrderState =
          context.watch<GroceryCategoryOrderCubit>().state;
      final toggleState = context.watch<ToggleGroceryDeletingCubit>().state;

      return BlocConsumer<GroceryBloc, GroceryState>(
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
          builder: (unUsedContext, groceryState) => Stack(
                children: [
                  ReorderableListView(
                    scrollController: scrollController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      for (String category in categoryOrderState)
                        MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                                value:
                                    context.read<GroceryDraggingItemCubit>()),
                            BlocProvider<GroceryAddEntryCubit>(
                              create: (_) => GroceryAddEntryCubit(),
                            ),
                          ],
                          key: ValueKey(category),
                          child: GroceryCategoryBox(
                            parentScrollController: scrollController,
                            isExpanded: !collapsedCategories.contains(category),
                            categoryName: category,
                            categoryItems: items[category]!,
                            inDeleteMode: toggleState,
                            categoryColor: Color(
                                settingsState.groceryCategoriesMap[category]!),
                          ),
                        )
                    ],
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final String category =
                          categoryOrderState.removeAt(oldIndex);
                      categoryOrderState.insert(newIndex, category);
                      context
                          .read<GroceryCategoryOrderCubit>()
                          .update(categoryOrderState);
                    },
                  ),
                  isDragging && scrollController.offset != 0
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: DragTarget<GroceryItem>(
                            builder: (context, accepted, rejected) => Container(
                              height: 20,
                              width: double.infinity,
                              color: Colors.transparent,
                            ),
                            onWillAcceptWithDetails: (data) {
                              moveUp();
                              return false;
                            },
                          ),
                        )
                      : const SizedBox(),
                  isDragging &&
                          scrollController.offset !=
                              scrollController.position.maxScrollExtent
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: DragTarget<GroceryItem>(
                            builder: (context, accepted, rejected) => Container(
                              height: 20,
                              width: double.infinity,
                              color: Colors.transparent,
                            ),
                            onWillAcceptWithDetails: (data) {
                              moveDown();
                              return false;
                            },
                          ),
                        )
                      : const SizedBox()
                ],
              ));
    }));
  }
}

class ClearButtons extends StatefulWidget {
  const ClearButtons({super.key});

  @override
  State<ClearButtons> createState() => _ClearButtonsState();
}

class _ClearButtonsState extends State<ClearButtons> {
  late Map<String, List<GroceryItem>> items;

  @override
  void initState() {
    super.initState();
    items = (context.read<GroceryBloc>().state as GroceryInitial).items;
  }

  Widget clearButton(
      {required void Function() onTap, required ClearButton type}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 248, 172, 197), width: 1.w),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: type == ClearButton.clearAll
              ? const Text("clear all")
              : const Row(
                  children: [Text("clear"), Icon(Icons.check_box_outlined)],
                ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroceryBloc, GroceryState>(
      listener: (context, state) {
        if (state is GroceryListUpdated) {
          items = state.props[0] as Map<String, List<GroceryItem>>;
        }
      },
      child: Row(
        children: [
          clearButton(
              onTap: () {
                Map<String, List<GroceryItem>> itemsToDelete = {};
                for (String category in items.keys) {
                  for (GroceryItem item in items[category]!) {
                    if (item.isChecked) {
                      if (itemsToDelete.containsKey(category)) {
                        itemsToDelete[category]!.add(item);
                      } else {
                        itemsToDelete[category] = [item];
                      }
                    }
                  }
                }
                context.read<GroceryBloc>().add(
                    DeleteIngredients(items: itemsToDelete, clearAll: false));
              },
              type: ClearButton.clearChecked),
          clearButton(
              onTap: () {
                Map<String, List<GroceryItem>> itemsToDelete = items;

                context.read<GroceryBloc>().add(
                    DeleteIngredients(items: itemsToDelete, clearAll: true));
              },
              type: ClearButton.clearAll)
        ],
      ),
    );
  }
}

class GroceryListPage extends StatelessWidget {
  const GroceryListPage({super.key});

  Widget deleteToggle(BuildContext context) {
    return BlocBuilder<ToggleGroceryDeletingCubit, bool>(
        builder: (context, toggleState) => ToggleButtons(
              onPressed: (int index) {
                context.read<ToggleGroceryDeletingCubit>().toggle();
              },
              isSelected: [!toggleState, toggleState], // list, in delete mode
              selectedColor: const Color.fromARGB(255, 237, 107, 151),
              color: Centre.primaryColor,
              fillColor: Centre.bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              borderWidth: 1.w,
              borderColor: Colors.blue,
              selectedBorderColor: Colors.blue,
              children: <Widget>[
                Icon(
                  Icons.checklist_rounded,
                  size: 3.h,
                ),
                Icon(
                  Icons.delete,
                  size: 3.h,
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    print("Building Grocery list page");

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
                      children: [deleteToggle(context), const ClearButtons()],
                    )
                  ],
                ),
                CategoryBoxes()
              ],
            )));
  }
}
