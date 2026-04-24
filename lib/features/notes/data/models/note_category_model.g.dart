// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_category_model.dart';

class NoteCategoryModelAdapter extends TypeAdapter<NoteCategoryModel> {
  @override
  final int typeId = 1;

  @override
  NoteCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteCategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      colorValue: fields[3] as int,
      noteCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NoteCategoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.noteCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
