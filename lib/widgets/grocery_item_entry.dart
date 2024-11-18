import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sizer/sizer.dart';

class GroceryAddEntry extends StatefulWidget {
  final String category;
  const GroceryAddEntry({super.key, required this.category});

  @override
  State<GroceryAddEntry> createState() => GroceryAddEntryState();
}

class GroceryAddEntryState extends State<GroceryAddEntry>
    with TickerProviderStateMixin {
  late final AnimationController animController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  late Animation<double> animation;

  @override
  initState() {
    super.initState();
    animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: animController,
      curve: Curves.fastOutSlowIn,
    );
    // widget.focusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animController.forward();
    });
  }

  @override
  void dispose() {
    animController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        key: const ValueKey(12345),
        animation: animation,
        builder: (_, child) => ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: animation.value,
                widthFactor: null,
                child: child,
              ),
            ),
        child: GestureDetector(
            onLongPress: () {},
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
                height: 5.h,
                width: 90.w,
                child: Row(children: [
                  GestureDetector(
                    onTap: () {
                      context.read<GroceryAddEntryCubit>().update("");
                    },
                    child: Container(
                      padding: EdgeInsets.all(1.5.w),
                      child: Icon(
                        Icons.delete,
                        color: Centre.primaryColor,
                        size: 5.5.w,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        context.read<GroceryBloc>().add(AddIngredient(
                            GroceryItem(
                                name: controller.text, isChecked: false),
                            widget.category));
                        context.read<GroceryAddEntryCubit>().update("");
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 1.w, right: 2.w),
                      padding: EdgeInsets.all(1.5.w),
                      child: Icon(
                        Icons.check,
                        color: Centre.primaryColor,
                        size: 5.5.w,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Form(
                    key: formKey,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return 'Can\'t be empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(height: 0.5),
                        hintText: "Ingredient name",
                        hintStyle:
                            Centre.listText.copyWith(color: Colors.blueGrey),
                        isDense: true,
                      ),
                      controller: controller,
                      style: Centre.listText,
                    ),
                  ))
                ]))));
  }
}

Widget draggableItemEntry(
    {required GroceryItem item,
    required int? draggingIndex,
    required int? hoveringIndex,
    required int index,
    required bool inDeleteMode,
    required BuildContext context,
    required String hoveredCategory,
    required String category,
    required Function(GroceryItem item) onReorder}) {
  return LongPressDraggable<Map<String, List<GroceryItem>>>(
    hitTestBehavior: HitTestBehavior.translucent,
    delay: const Duration(milliseconds: 100),
    data: {
      category: [item]
    },
    onDragStarted: () {
      context.read<GroceryDraggingItemCubit>().update(
          draggingIndex: index, hoveringIndex: index, originCategory: category);
    },
    onDragCompleted: () {
      context.read<GroceryDraggingItemCubit>().update(
          draggingIndex: null, hoveringIndex: null, originCategory: category);
    },
    onDraggableCanceled: (velocity, offset) {
      context.read<GroceryDraggingItemCubit>().update(
          draggingIndex: null, hoveringIndex: null, originCategory: category);
    },
    feedback: Material(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      color: const Color.fromARGB(175, 143, 177, 236),
      child: itemEntry(
          draggingIndex: draggingIndex,
          item: item,
          index: index,
          inDeleteMode: inDeleteMode,
          context: context,
          category: category,
          isFeedback: true),
    ),
    child: DragTarget<Map<String, List<GroceryItem>>>(
      onWillAcceptWithDetails: (data) {
        if (data.data.keys.first != category) {
          context.read<GroceryDraggingItemCubit>().update(
              draggingIndex: draggingIndex,
              hoveringIndex: null,
              originCategory: category);
          return false;
        }
        context.read<GroceryDraggingItemCubit>().update(
            draggingIndex: draggingIndex,
            hoveringIndex: index,
            originCategory: category);
        return data.data.values.first.first != item;
      },
      onAcceptWithDetails: (data) {
        context.read<GroceryDraggingItemCubit>().update(
            draggingIndex: null, hoveringIndex: null, originCategory: category);
        onReorder(data.data.values.first.first);
      },
      onLeave: (data) {
        context.read<GroceryDraggingItemCubit>().update(
            draggingIndex: draggingIndex,
            hoveringIndex: null,
            originCategory: category);
      },
      builder: (context, candidateData, rejectedData) {
        return hoveringIndex == null && draggingIndex == null
            ? itemEntry(
                draggingIndex: draggingIndex,
                item: item,
                index: index,
                inDeleteMode: inDeleteMode,
                context: context,
                category: category)
            : AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: hoveringIndex == null && draggingIndex != null
                    ? (index > draggingIndex && hoveredCategory.isNotEmpty
                        ? Matrix4.translationValues(0, -5.h, 0)
                        : Matrix4.translationValues(0, 0, 0))
                    : hoveringIndex != null && (draggingIndex! > hoveringIndex)
                        ? Matrix4.translationValues(
                            0,
                            (index >= hoveringIndex)
                                ? ((index >= draggingIndex))
                                    ? 0
                                    : 5.h
                                : 0,
                            0)
                        : (hoveringIndex != null &&
                                (draggingIndex! < hoveringIndex))
                            ? Matrix4.translationValues(
                                0,
                                (index <= hoveringIndex)
                                    ? ((index <= draggingIndex))
                                        ? 0
                                        : -(5.h)
                                    : 0,
                                0)
                            : Matrix4.translationValues(0, 0, 0),
                child: itemEntry(
                    draggingIndex: draggingIndex,
                    item: item,
                    index: index,
                    inDeleteMode: inDeleteMode,
                    context: context,
                    category: category),
              );
      },
    ),
  );
}

Widget itemEntry(
    {required GroceryItem item,
    required int? draggingIndex,
    required int index,
    required bool inDeleteMode,
    required BuildContext context,
    required String category,
    bool isFeedback = false}) {
  return SizedBox(
    key: ValueKey(item),
    height: 5.h,
    width: 88.w,
    child: draggingIndex == index
        ? null
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      if (inDeleteMode) {
                        context
                            .read<GroceryBloc>()
                            .add(DeleteIngredients(items: {
                              category: [item]
                            }, clearAll: false));
                      } else {
                        context.read<GroceryBloc>().add(
                            UpdateIngredientsChecked(
                                !item.isChecked, index, category));
                      }
                    },
                    child: inDeleteMode
                        ? const Icon(Icons.delete)
                        : item.isChecked
                            ? const Icon(Icons.check_box_rounded)
                            : const Icon(Icons.check_box_outline_blank)),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!inDeleteMode) {
                        context.read<GroceryBloc>().add(
                            UpdateIngredientsChecked(
                                !item.isChecked, index, category));
                      }
                    },
                    child: Text(
                      item.name,
                      style: Centre.listText.copyWith(
                          decoration: item.isChecked
                              ? TextDecoration.lineThrough
                              : null),
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}
