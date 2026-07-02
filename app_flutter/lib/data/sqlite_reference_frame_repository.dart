import 'dart:async';

import 'package:sqflite_common/sqlite_api.dart';
import '../domain/reference_frame.dart';
import 'reference_frame_repository.dart';

class SqliteReferenceFrameRepository implements ReferenceFrameRepository {
  final Database _database;
  final StreamController<ReferenceFrame?> _controller =
      StreamController<ReferenceFrame?>.broadcast();

  SqliteReferenceFrameRepository(this._database);

  Database get database => _database;

  @override
  Future<ReferenceFrame?> get() async {
    final rows = await _database.query('reference_frame', limit: 1);
    if (rows.isEmpty) return null;
    return ReferenceFrame.fromJson(_rowToJson(rows.first));
  }

  @override
  Future<void> save(ReferenceFrame frame) async {
    final rows = await _database.rawQuery('SELECT COUNT(*) as cnt FROM reference_frame');
    final count = rows.first['cnt'] as int;
    if (count == 0) {
      await _database.insert('reference_frame', _frameToRow(frame));
    } else {
      await _database.update('reference_frame', _frameToRow(frame));
    }
    _controller.add(frame);
  }

  @override
  Future<void> delete() async {
    await _database.delete('reference_frame');
    _controller.add(null);
  }

  @override
  Future<bool> exists() async {
    final rows = await _database.rawQuery('SELECT COUNT(*) as cnt FROM reference_frame');
    final count = rows.first['cnt'] as int;
    return count > 0;
  }

  @override
  Stream<ReferenceFrame?> watch() {
    return _controller.stream;
  }

  Map<String, dynamic> _frameToRow(ReferenceFrame frame) {
    return {
      'astronomical_body': frame.astronomicalBody,
      'alternate_system': frame.alternateSystem,
    };
  }

  Map<String, dynamic> _rowToJson(Map<String, dynamic> row) {
    return {
      'astronomical_body': row['astronomical_body'],
      if (row['alternate_system'] != null)
        'alternate_system': row['alternate_system'],
    };
  }
}
