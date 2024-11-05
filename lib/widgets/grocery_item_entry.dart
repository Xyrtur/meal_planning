import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';

class GroceryAddEntry extends StatefulWidget {
  late final AnimationController animController;
  final String category;
  GroceryAddEntry({super.key, required this.category});

  @override
  State<GroceryAddEntry> createState() => _GroceryAddEntryState();
}

class _GroceryAddEntryState extends State<GroceryAddEntry>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  initState() {
    widget.animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    widget.animController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = CurvedAnimation(
      parent: widget.animController,
      curve: Curves.fastOutSlowIn,
    );
    focusNode.requestFocus();
    return AnimatedBuilder(
        key: const ValueKey(12345),
        animation: animation,
        builder: (_, child) => ClipRect(
              child: Form(
                key: formKey,
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: animation.value,
                  widthFactor: null,
                  child: child,
                ),
              ),
            ),
        child: GestureDetector(
          onLongPress: () {},
          child: SizedBox(
              height: Centre.safeBlockVertical * 5,
              width: Centre.safeBlockHorizontal * 90,
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    context.read<GroceryAddEntryCubit>().update("");
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: Centre.safeBlockHorizontal * 2),
                    padding: EdgeInsets.all(Centre.safeBlockHorizontal * 1.5),
                    child: Icon(
                      Icons.delete,
                      color: Centre.primaryColor,
                      size: Centre.safeBlockHorizontal * 5.5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      context.read<GroceryBloc>().add(AddIngredient(
                          GroceryItem(name: controller.text, isChecked: false),
                          widget.category));
                      context.read<GroceryAddEntryCubit>().update("");
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: Centre.safeBlockHorizontal * 2),
                    padding: EdgeInsets.all(Centre.safeBlockHorizontal * 1.5),
                    child: Icon(
                      Icons.check,
                      color: Centre.primaryColor,
                      size: Centre.safeBlockHorizontal * 5.5,
                    ),
                  ),
                ),
                Expanded(
                    child: TextFormField(
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    counterText: "",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  controller: controller,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLength: 50,
                  focusNode: focusNode,
                  style: Centre.listText,
                ))
              ])),
        ));
  }
}

Widget draggableItemEntry(
    {required GroceryItem item,
    required int? draggingIndex,
    required int? hoveringIndex,
    required int index,
    required bool inDeleteMode,
    required BuildContext context,
    required String category,
    required Function(GroceryItem item) onReorder}) {
  return LongPressDraggable<GroceryItem>(
    data: item,
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
      child: itemEntry(
          draggingIndex: draggingIndex,
          item: item,
          index: index,
          inDeleteMode: inDeleteMode,
          context: context,
          category: category,
          isFeedback: true),
    ),
    child: DragTarget<GroceryItem>(
      onWillAcceptWithDetails: (data) {
        if (data.data != item) {
          context.read<GroceryDraggingItemCubit>().update(
              draggingIndex: draggingIndex,
              hoveringIndex: index,
              originCategory: category);
          return true;
        }
        context.read<GroceryDraggingItemCubit>().update(
            draggingIndex: draggingIndex,
            hoveringIndex: index,
            originCategory: category);
        return false;
      },
      onAcceptWithDetails: (data) {
        context.read<GroceryDraggingItemCubit>().update(
            draggingIndex: null, hoveringIndex: null, originCategory: category);
        onReorder(data.data);
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
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: hoveringIndex == null && draggingIndex != null
                    ? (index > draggingIndex
                        ? Matrix4.translationValues(0, -100, 0)
                        : Matrix4.translationValues(0, 0, 0))
                    : hoveringIndex != null && (draggingIndex! > hoveringIndex)
                        ? Matrix4.translationValues(
                            0,
                            (index >= hoveringIndex)
                                ? ((index >= draggingIndex))
                                    ? 0
                                    : 100.0
                                : 0,
                            0)
                        : (hoveringIndex != null &&
                                (draggingIndex! < hoveringIndex))
                            ? Matrix4.translationValues(
                                0,
                                (index <= hoveringIndex)
                                    ? ((index <= draggingIndex))
                                        ? 0
                                        : -100.0
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
    height: 100,
    child: draggingIndex == index
        ? null
        : Row(
            children: [
              GestureDetector(
                  onTap: () {
                    if (inDeleteMode) {
                      context.read<GroceryBloc>().add(DeleteIngredients({
                            category: [item]
                          }));
                    } else {
                      context.read<GroceryBloc>().add(
                              UpdateIngredientsChecked(!item.isChecked, index, {
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
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null),
                ),
              )
            ],
          ),
  );
}
