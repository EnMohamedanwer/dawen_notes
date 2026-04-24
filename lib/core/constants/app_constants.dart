class AppConstants {
  AppConstants._();

  static const String appName = 'Notes_App';
  static const String dbName = 'notes_database.db';
  static const int dbVersion = 1;

  // Table names
  static const String notesTable = 'notes';
  static const String categoriesTable = 'categories';

  // Default categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'id': 'work', 'name': 'العمل', 'icon': '💼', 'color': 0xFFFF9800},
    {'id': 'personal', 'name': 'شخصي', 'icon': '🏠', 'color': 0xFF4CAF50},
    {'id': 'ideas', 'name': 'أفكار', 'icon': '💡', 'color': 0xFF9C27B0},
    {'id': 'shopping', 'name': 'تسوق', 'icon': '🛒', 'color': 0xFF03A9F4},
  ];
}
