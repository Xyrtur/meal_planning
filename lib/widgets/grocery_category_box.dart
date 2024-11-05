import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/grocery_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/widgets/grocery_item_entry.dart';

class GroceryCategoryBox extends StatefulWidget {
  final bool isExpanded;
  final String categoryName;
  final Color categoryColor;
  final List<GroceryItem> categoryItems;
  final bool inDeleteMode;
  const GroceryCategoryBox(
      {super.key,
      required this.isExpanded,
      required this.categoryColor,
      required this.categoryName,
      required this.categoryItems,
      required this.inDeleteMode});

  @override
  State<GroceryCategoryBox> createState() => _GroceryCategoryBoxState();
}

class _GroceryCategoryBoxState extends State<GroceryCategoryBox> with TickerProviderStateMixin {
  late GroceryAddEntry addEntry;

  late final AnimationController animController;
  @override
  initState() {
    animController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Widget circularButton({required void Function() onTap, required Color categoryColor, required IconData icon}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: categoryColor, width: Centre.safeBlockHorizontal),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Icon(icon),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = CurvedAnimation(
      parent: animController,
      curve: Curves.fastOutSlowIn,
    );

    return BlocBuilder<GroceryAddEntryCubit, String>(
      buildWhen: (previous, current) {
        if (current == widget.categoryName) {
          // Add tile created
          addEntry = GroceryAddEntry(category: widget.categoryName);
          addEntry.animController.forward();
        } else if (previous == widget.categoryName && current != widget.categoryName) {
          // Add tile removed
          addEntry.animController.reverse();
        }
        return previous == widget.categoryName && current.isEmpty || current == widget.categoryName;
      },
      builder: (context, state) => AnimatedBuilder(
        key: const ValueKey(23456),
        animation: animation,
        builder: (_, child) => ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: animation.value,
            widthFactor: null,
            child: child,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: widget.categoryColor, width: Centre.safeBlockHorizontal),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    widget.categoryName,
                    style: Centre.semiTitleText,
                  ),
                  Spacer(),
                  circularButton(
                      onTap: () {
                        context.read<GroceryAddEntryCubit>().update(widget.categoryName);
                      },
                      categoryColor: widget.categoryColor,
                      icon: Icons.add),
                  circularButton(
                      onTap: () {
                        if (widget.isExpanded) {
                          animController.reverse();
                        } else {
                          animController.forward();
                        }
                        context.read<GroceryBloc>().add(ToggleGroceryCategory(widget.categoryName));
                      },
                      categoryColor: widget.categoryColor,
                      icon: Icons.expand)
                ],
              ),
              for (int i = 0; i < widget.categoryItems.length; i++)
                itemEntry(
                    item: widget.categoryItems[i],
                    index: i,
                    inDeleteMode: widget.inDeleteMode,
                    context: context,
                    category: widget.categoryName),
              state == widget.categoryName ? addEntry : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
