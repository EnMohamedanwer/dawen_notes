import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/note_category.dart';
import '../../../../core/constants/hive_constants.dart';

part 'note_category_model.g.dart';

@HiveType(typeId: HiveTypeIds.noteCategoryModel)
class NoteCategoryModel extends HiveObject {
  NoteCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.noteCount = 0,
  });

  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String icon;
  @HiveField(3) int colorValue;
  @HiveField(4) int noteCount;

  Color get color => Color(colorValue);

  NoteCategory toEntity() => NoteCategory(
        id: id, name: name, icon: icon,
        color: Color(colorValue), noteCount: noteCount,
      );

  factory NoteCategoryModel.fromEntity(NoteCategory cat) =>
      NoteCategoryModel(
        id: cat.id, name: cat.name, icon: cat.icon,
        colorValue: cat.color.value, noteCount: cat.noteCount,
      );
}
