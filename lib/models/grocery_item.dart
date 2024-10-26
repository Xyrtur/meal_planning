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

  /*
   * Name - Name of the grocery item
   * Checked - Whether or not the grocery item is currently checked off
   */
  GroceryItem({required this.name, required this.isChecked});

  GroceryItem toggleCheckbox() {
    isChecked = !isChecked;
    return this;
  }

  @override
  toString() {
    return {'name': name, 'isChecked': isChecked}.toString();
  }
}
