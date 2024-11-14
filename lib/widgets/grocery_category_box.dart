import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/grocery_item_entry.dart';
import 'package:sizer/sizer.dart';

class GroceryCategoryBox extends StatefulWidget {
  final bool isExpanded;
  final ScrollController parentScrollController;
  final String categoryName;
  final Color categoryColor;
  final List<GroceryItem> categoryItems;
  final bool inDeleteMode;
  const GroceryCategoryBox(
      {super.key,
      required this.isExpanded,
      required this.parentScrollController,
      required this.categoryColor,
      required this.categoryName,
      required this.categoryItems,
      required this.inDeleteMode});

  @override
  State<GroceryCategoryBox> createState() => _GroceryCategoryBoxState();
}

class _GroceryCategoryBoxState extends State<GroceryCategoryBox>
    with TickerProviderStateMixin {
  final GlobalKey<GroceryAddEntryState> groceryAddEntryKey =
      GlobalKey<GroceryAddEntryState>();
  Widget circularButton(
      {required void Function() onTap,
      required Color categoryColor,
      required IconData icon}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
              border: Border.all(color: categoryColor, width: 0.5.w),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Icon(icon),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroceryDraggingItemCubit, List<dynamic>>(
        buildWhen: (previous, current) {
      // Prevents other category boxes from updating their drag indices as well
      return (current[2] as String) == widget.categoryName;
    }, builder: (context, dragHoverInfo) {
      return BlocBuilder<GroceryAddEntryCubit, String>(
        buildWhen: (previous, current) {
          if (current == widget.categoryName) {
            // Add tile created
            groceryAddEntryKey.currentState?.animController.forward();
            if (!widget.isExpanded) {
              context
                  .read<GroceryBloc>()
                  .add(ToggleGroceryCategory(widget.categoryName));
            }
            return true;
          } else if (previous == widget.categoryName &&
              (current != widget.categoryName || current.isEmpty)) {
            // Add tile removed
            groceryAddEntryKey.currentState?.animController.reverse();
            return true;
          }
          return false;
        },
        builder: (context, state) => DragTarget<Map<String, List<GroceryItem>>>(
          onWillAcceptWithDetails: (itemMap) {
            return !widget.categoryItems.contains(itemMap.data.values.first[0]);
          },
          onAcceptWithDetails: (itemMap) {
            context.read<GroceryBloc>().add(UpdateIngredientsCategory(
                items: itemMap.data,
                newCategory: widget.categoryName,
                onlyItemOrderChanged: false));
            for (String category in itemMap.data.keys) {
              context.read<GroceryDraggingItemCubit>().update(
                  draggingIndex: null,
                  hoveringIndex: null,
                  originCategory: category);
            }
          },
          onLeave: (data) {
            // TODO: take off the category container shade color thing
          },
          builder: (context, accepted, rejected) => AnimatedContainer(
            clipBehavior: Clip.antiAlias,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,

            height: (7.5.h +
                (widget.isExpanded
                    ? widget.categoryItems.length * 6.5.h +
                        (state == widget.categoryName ? 10.h : 0)
                    : 0)),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            padding: EdgeInsets.all(4.w),
            //TODO: put a color over it if going to accept, take off when leaving
            decoration: BoxDecoration(
              border: Border.all(color: widget.categoryColor, width: 1.w),
              borderRadius: const BorderRadius.all(Radius.circular(40)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.categoryName,
                      style: Centre.semiTitleText,
                    ),
                    const Spacer(),
                    circularButton(
                        onTap: () {
                          context.read<GroceryBloc>().add(
                              UpdateIngredientsChecked(
                                  null, null, widget.categoryName));
                        },
                        categoryColor: widget.categoryColor,
                        icon: Icons.check_circle_outline),
                    circularButton(
                        onTap: () {
                          context
                              .read<GroceryAddEntryCubit>()
                              .update(widget.categoryName);
                        },
                        categoryColor: widget.categoryColor,
                        icon: Icons.add),
                    circularButton(
                        onTap: () {
                          context
                              .read<GroceryBloc>()
                              .add(ToggleGroceryCategory(widget.categoryName));
                          if (state == widget.categoryName) {
                            context.read<GroceryAddEntryCubit>().update("");
                          }
                        },
                        categoryColor: widget.categoryColor,
                        icon: Icons.expand)
                  ],
                ),
                Column(children: [
                  for (int i = 0; i < widget.categoryItems.length; i++)
                    draggableItemEntry(
                      draggingIndex: (dragHoverInfo[0] as int?),
                      hoveringIndex: (dragHoverInfo[1] as int?),
                      item: widget.categoryItems[i],
                      index: i,
                      inDeleteMode: widget.inDeleteMode,
                      context: context,
                      category: widget.categoryName,
                      onReorder: (item) {
                        List<GroceryItem> tempList = widget.categoryItems;
                        tempList.remove(item);
                        tempList.insert(i, item);
                        context.read<GroceryBloc>().add(
                            UpdateIngredientsCategory(
                                items: {widget.categoryName: tempList},
                                newCategory: widget.categoryName,
                                onlyItemOrderChanged: true));
                      },
                    )
                ]),
                AddEntryStateless(
                    isAdding: state == widget.categoryName,
                    addKey: groceryAddEntryKey,
                    name: widget.categoryName)
                // state == widget.categoryName
                //     ? GroceryAddEntry(
                //         key: groceryAddEntryKey,
                //         category: widget.categoryName,
                //       )
                //     : const SizedBox()
              ],
            ),
          ),
        ),
      );
    });
  }
}

class AddEntryStateless extends StatelessWidget {
  final bool isAdding;
  final Key addKey;
  final String name;
  const AddEntryStateless(
      {super.key,
      required this.isAdding,
      required this.addKey,
      required this.name});

  @override
  Widget build(BuildContext context) {
    print("rebuilding parent entry stateless");
    return isAdding
        ? GroceryAddEntry(
            key: addKey,
            category: name,
          )
        : const SizedBox();
  }
}
