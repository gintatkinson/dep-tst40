import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'core/app_theme.dart';
import 'data/sqlite_reference_frame_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = join(appDir.path, 'pipeline.db');

  final db = await databaseFactoryFfi.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reference_frame (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            astronomical_body TEXT NOT NULL DEFAULT 'earth',
            alternate_system TEXT
          )
        ''');
      },
    ),
  );

  final repository = SqliteReferenceFrameRepository(db);
  final themeController = AppTheme();

  runApp(PipelineApp(
    repository: repository,
    themeController: themeController,
  ));
}
