// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroceryItemAdapter extends TypeAdapter<GroceryItem> {
  @override
  final typeId = 1;

  @override
  GroceryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroceryItem(
      name: fields[0] as String,
      isChecked: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GroceryItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
