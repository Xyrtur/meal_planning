import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/blocs/import_export_bloc.dart';
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
    items = context.read<GroceryBloc>().state.items;
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
          builder: (_, groceryState) => Stack(
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
                            BlocProvider.value(
                                value: context.read<GroceryCategoryHover>()),
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
                      List<String> tempList = List.from(categoryOrderState);
                      final String category = tempList.removeAt(oldIndex);
                      tempList.insert(newIndex, category);

                      context
                          .read<GroceryCategoryOrderCubit>()
                          .update(tempList);
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
    items = context.read<GroceryBloc>().state.items;
  }

  Widget clearButton(
      {required void Function() onTap, required ClearButton type}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(left: 4.w),
          padding: EdgeInsets.all(2.w),
          decoration: ShapeDecoration(
            shadows: [
              BoxShadow(
                color: Centre.shadowbgColor,
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
            color: Centre.bgColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<ImportExportBloc, ImportExportState>(
          listener: (context, state) {
            if (state is ImportFinished) {
              context.read<GroceryBloc>().add(const IngredientsImported());
            }
          },
        ),
        BlocListener<GroceryBloc, GroceryState>(
          listener: (context, state) {
            if (state is GroceryListUpdated) {
              items = state.props[0] as Map<String, List<GroceryItem>>;
            }
          },
        )
      ],
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
              selectedColor: Colors.white,
              color: Colors.black,
              fillColor: Colors.black,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              children: <Widget>[
                Icon(
                  Icons.checklist_rounded,
                  size: 2.5.h,
                ),
                Icon(
                  Icons.delete,
                  size: 2.5.h,
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Centre.bgColor,
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Text(
                        "Grocery List",
                        style: Centre.titleText,
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          deleteToggle(context),
                          SizedBox(
                            height: 1.h,
                          ),
                          const ClearButtons()
                        ],
                      )
                    ],
                  ),
                ),
                CategoryBoxes()
              ],
            )));
  }
}
