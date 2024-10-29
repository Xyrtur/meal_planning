/*
 * String name
 * bool checked
 * Don't need to store category
 */

import 'package:hive_ce/hive.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 1)
class GroceryItem extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  bool isChecked;
  @HiveField(2)
  int index;

  /*
   * Name - Name of the grocery item
   * Checked - Whether or not the grocery item is currently checked off
   */
  GroceryItem({required this.name, required this.isChecked, required this.index});

  GroceryItem toggleCheckbox() {
    isChecked = !isChecked;
    return this;
  }

  GroceryItem updateIndex(int index) {
    this.index = index;
    return this;
  }

  @override
  toString() {
    return {'name': name, 'isChecked': isChecked, 'index': index}.toString();
  }
}
