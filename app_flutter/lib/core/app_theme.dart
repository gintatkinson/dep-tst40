import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF1a73e8),
      fontFamily: 'Outfit',
      scaffoldBackgroundColor: const Color(0xFFf1f3f4),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      dividerTheme: DividerThemeData(
        space: 0,
        thickness: 1,
        color: Colors.grey.shade300,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 28,
        dataRowMinHeight: 24,
        dataRowMaxHeight: 24,
        horizontalMargin: 8,
        columnSpacing: 12,
        dividerThickness: 0.5,
        headingTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
        dataTextStyle: const TextStyle(fontSize: 11, height: 1.2),
      ),
      textTheme: const TextTheme(
        bodySmall: TextStyle(fontSize: 11, height: 1.2),
        bodyMedium: TextStyle(fontSize: 12, height: 1.3),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF1a73e8),
      fontFamily: 'Outfit',
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      dividerTheme: DividerThemeData(
        space: 0,
        thickness: 1,
        color: Colors.grey.shade800,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 28,
        dataRowMinHeight: 24,
        dataRowMaxHeight: 24,
        horizontalMargin: 8,
        columnSpacing: 12,
        dividerThickness: 0.5,
        headingTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
        ),
        dataTextStyle: const TextStyle(fontSize: 11, height: 1.2),
      ),
      textTheme: const TextTheme(
        bodySmall: TextStyle(fontSize: 11, height: 1.2),
        bodyMedium: TextStyle(fontSize: 12, height: 1.3),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
