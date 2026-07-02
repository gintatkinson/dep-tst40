import '../domain/reference_frame.dart';

abstract class ReferenceFrameRepository {
  Future<ReferenceFrame?> get();

  Future<void> save(ReferenceFrame frame);

  Future<void> delete();

  Future<bool> exists();

  Stream<ReferenceFrame?> watch();
}
