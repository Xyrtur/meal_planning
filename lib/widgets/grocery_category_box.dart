import 'dart:math';

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

class _GroceryCategoryBoxState extends State<GroceryCategoryBox> with TickerProviderStateMixin {
  final GlobalKey<GroceryAddEntryState> groceryAddEntryKey = GlobalKey<GroceryAddEntryState>();
  late AnimationController arrowController;

  @override
  void initState() {
    arrowController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    if (widget.isExpanded) {
      arrowController.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    arrowController.dispose();
    super.dispose();
  }

  Widget circularButton({required void Function() onTap, required Color categoryColor, required IconData icon}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(left: 1.w),
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
              border: Border.all(color: categoryColor, width: 0.5.w),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Icon(icon),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroceryCategoryHover, String>(builder: (context, hoveredCategory) {
      return BlocBuilder<GroceryDraggingItemCubit, List<dynamic>>(buildWhen: (previous, current) {
        // Prevents other category boxes from updating their drag indices as well
        return (current[2] as String) == widget.categoryName;
      }, builder: (context, dragHoverInfo) {
        return BlocBuilder<GroceryAddEntryCubit, String>(
          buildWhen: (previous, current) {
            if (current == widget.categoryName) {
              // Add tile created
              groceryAddEntryKey.currentState?.animController.forward();
              if (!widget.isExpanded) {
                context.read<GroceryBloc>().add(ToggleGroceryCategory(widget.categoryName));
              }
              return true;
            } else if (previous == widget.categoryName && (current != widget.categoryName || current.isEmpty)) {
              // Add tile removed
              groceryAddEntryKey.currentState?.animController.reverse();
              return true;
            }
            return false;
          },
          builder: (context, state) => DragTarget<Map<String, List<GroceryItem>>>(
            onWillAcceptWithDetails: (itemMap) {
              if (!widget.categoryItems.contains(itemMap.data.values.first[0])) {
                context.read<GroceryCategoryHover>().update(hoveredCategory: widget.categoryName);
                return true;
              }
              return false;
            },
            onAcceptWithDetails: (itemMap) {
              context.read<GroceryCategoryHover>().update(hoveredCategory: "");
              context.read<GroceryBloc>().add(UpdateIngredientsCategory(
                  items: itemMap.data, newCategory: widget.categoryName, onlyItemOrderChanged: false));
              for (String category in itemMap.data.keys) {
                context
                    .read<GroceryDraggingItemCubit>()
                    .update(draggingIndex: null, hoveringIndex: null, originCategory: category);
              }
            },
            onLeave: (data) {
              if (hoveredCategory == widget.categoryName) {
                context.read<GroceryCategoryHover>().update(hoveredCategory: "");
              }
            },
            builder: (context, accepted, rejected) => Opacity(
              opacity: hoveredCategory == widget.categoryName ? 0.5 : 1,
              child: AnimatedContainer(
                clipBehavior: Clip.antiAlias,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,

                height: (7.5.h +
                    (widget.isExpanded
                        ? widget.categoryItems.length * 5.h + (state == widget.categoryName ? 6.h : 0)
                        : 0)),
                margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.5.h),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: hoveredCategory == widget.categoryName ? widget.categoryColor.withAlpha(230) : Centre.bgColor,
                  border: Border.all(color: widget.categoryColor, width: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                ),
                // the scrollview prevents a render overflow due to animated container changing size but the content not changing
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          children: [
                            const Icon(Icons.drag_handle),
                            SizedBox(
                              width: 2.w,
                            ),
                            Text(
                              widget.categoryName,
                              style: Centre.semiTitleText,
                            ),
                            const Spacer(),
                            circularButton(
                                onTap: () {
                                  context
                                      .read<GroceryBloc>()
                                      .add(UpdateIngredientsChecked(null, null, widget.categoryName));
                                },
                                categoryColor: widget.categoryColor,
                                icon: Icons.check_circle_outline),
                            circularButton(
                                onTap: () {
                                  context.read<GroceryAddEntryCubit>().update(widget.categoryName);
                                },
                                categoryColor: widget.categoryColor,
                                icon: Icons.add),
                            GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  arrowController.toggle();
                                  context.read<GroceryBloc>().add(ToggleGroceryCategory(widget.categoryName));
                                  if (state == widget.categoryName) {
                                    context.read<GroceryAddEntryCubit>().update("");
                                  }
                                },
                                child: SizedBox(
                                  height: 3.h,
                                  width: 8.w,
                                  child: Center(
                                    child: AnimatedBuilder(
                                        animation: arrowController,
                                        builder: (_, child) {
                                          return Transform.rotate(
                                            origin: Offset(0.7.w, 0.9.w),
                                            angle: pi + arrowController.value * -1 * pi / 2,
                                            child: Icon(Icons.arrow_right_rounded, color: Colors.black, size: 4.5.h),
                                          );
                                        }),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Column(children: [
                        for (int i = 0; i < widget.categoryItems.length; i++)
                          draggableItemEntry(
                            hoveredCategory: hoveredCategory,
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
                              context.read<GroceryBloc>().add(UpdateIngredientsCategory(
                                  items: {widget.categoryName: tempList},
                                  newCategory: widget.categoryName,
                                  onlyItemOrderChanged: true));
                            },
                          )
                      ]),
                      state == widget.categoryName
                          ? GroceryAddEntry(
                              key: groceryAddEntryKey,
                              category: widget.categoryName,
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
