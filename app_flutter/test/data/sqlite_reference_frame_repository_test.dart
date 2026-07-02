import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/data/sqlite_reference_frame_repository.dart';
import 'package:pipeline_app/domain/reference_frame.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteReferenceFrameRepository', () {
    late SqliteReferenceFrameRepository repository;

    setUp(() async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
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
            await db.insert('reference_frame', {
              'astronomical_body': 'earth',
            });
          },
        ),
      );
      repository = SqliteReferenceFrameRepository(db);
    });

    test('get returns default reference frame', () async {
      final rf = await repository.get();

      expect(rf, isNotNull);
      expect(rf!.astronomicalBody, 'earth');
      expect(rf.alternateSystem, isNull);
    });

    test('save and get round-trips full reference frame', () async {
      final rf = ReferenceFrame(
        astronomicalBody: 'mars',
        alternateSystem: 'stargate-grid-7',
      );

      await repository.save(rf);
      final retrieved = await repository.get();

      expect(retrieved, isNotNull);
      expect(retrieved!.astronomicalBody, 'mars');
      expect(retrieved.alternateSystem, 'stargate-grid-7');
    });

    test('save updates existing row without creating duplicates', () async {
      await repository.save(ReferenceFrame(astronomicalBody: 'mars'));

      final count = await repository.database.rawQuery(
        'SELECT COUNT(*) as cnt FROM reference_frame',
      );
      expect(count.first['cnt'], 1);
      final rf = await repository.get();
      expect(rf!.astronomicalBody, 'mars');
    });

    test('exists returns true after save', () async {
      final existsBefore = await repository.exists();
      expect(existsBefore, isTrue);

      await repository.save(ReferenceFrame(astronomicalBody: 'ceres'));
      final existsAfter = await repository.exists();
      expect(existsAfter, isTrue);
    });

    test('delete removes the reference frame', () async {
      await repository.delete();

      final rf = await repository.get();
      expect(rf, isNull);
      final exists = await repository.exists();
      expect(exists, isFalse);
    });

    test('save null alternateSystem round-trips correctly', () async {
      await repository.save(ReferenceFrame(astronomicalBody: 'enceladus'));

      final rf = await repository.get();
      expect(rf!.astronomicalBody, 'enceladus');
      expect(rf.alternateSystem, isNull);
    });

    test('watch emits updated value after save', () async {
      final future = repository.watch().first;
      await repository.save(ReferenceFrame(astronomicalBody: 'titan'));

      final rf = await future.timeout(const Duration(seconds: 5));
      expect(rf, isNotNull);
      expect(rf!.astronomicalBody, 'titan');
    });

    test('watch emits null after delete', () async {
      await repository.save(ReferenceFrame(astronomicalBody: 'ceres'));
      final future = repository.watch().first;

      await repository.delete();
      final rf = await future.timeout(const Duration(seconds: 5));
      expect(rf, isNull);
    });
  });
}
