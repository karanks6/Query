import 'package:drift/drift.dart';
import '../app_database.dart';

part 'level_notes_dao.g.dart';

@DriftAccessor(tables: [LevelNotes])
class LevelNotesDao extends DatabaseAccessor<AppDatabase> with _$LevelNotesDaoMixin {
  LevelNotesDao(super.db);

  Future<LevelNote?> getNoteForLevel(String levelId) {
    return (select(levelNotes)..where((n) => n.levelId.equals(levelId))).getSingleOrNull();
  }

  Future<void> saveNote(String levelId, String noteText) {
    return into(levelNotes).insertOnConflictUpdate(
      LevelNote(
        levelId: levelId,
        noteText: noteText,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Stream<List<LevelNote>> watchAllNotes() {
    return select(levelNotes).watch();
  }
}
