import 'package:drift/drift.dart';
import '../app_database.dart';

part 'concept_dao.g.dart';

@DriftAccessor(tables: [BookmarkedConcepts])
class ConceptDao extends DatabaseAccessor<AppDatabase> with _$ConceptDaoMixin {
  ConceptDao(super.db);

  /// Toggle bookmark for a concept.
  Future<void> toggleBookmark(String conceptId) async {
    final existing = await (select(bookmarkedConcepts)
          ..where((c) => c.conceptId.equals(conceptId)))
        .getSingleOrNull();

    if (existing == null) {
      await into(bookmarkedConcepts).insert(BookmarkedConceptsCompanion.insert(
        conceptId: conceptId,
        savedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    } else {
      await (delete(bookmarkedConcepts)
            ..where((c) => c.conceptId.equals(conceptId)))
          .go();
    }
  }

  /// Get all bookmarked concept IDs.
  Future<List<String>> getBookmarkedConceptIds() async {
    final list = await select(bookmarkedConcepts).get();
    return list.map((c) => c.conceptId).toList();
  }

  /// Stream bookmarked concept IDs.
  Stream<List<String>> watchBookmarkedConceptIds() {
    return select(bookmarkedConcepts).watch().map(
          (list) => list.map((c) => c.conceptId).toList(),
        );
  }
}
