// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'note_model.dart';

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      contentJson: fields[2] as String,
      categoryId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
      isArchived: fields[7] as bool,
      wordCount: fields[8] as int,
      imagePaths: (fields[9] as List).cast<String>(),
      isLocked: fields[10] == null ? false : fields[10] as bool,
      notePin: fields[11] == null ? '' : fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.contentJson)
      ..writeByte(3)..write(obj.categoryId)
      ..writeByte(4)..write(obj.createdAt)
      ..writeByte(5)..write(obj.updatedAt)
      ..writeByte(6)..write(obj.isFavorite)
      ..writeByte(7)..write(obj.isArchived)
      ..writeByte(8)..write(obj.wordCount)
      ..writeByte(9)..write(obj.imagePaths)
      ..writeByte(10)..write(obj.isLocked)
      ..writeByte(11)..write(obj.notePin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
