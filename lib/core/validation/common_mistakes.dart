/// Lookup table mapping SQLite error patterns → plain-English, pedagogically
/// useful messages. Raw engine errors are NEVER shown to the player directly.
///
/// Keys match [ValidationResult.commonMistakeKey] values set throughout the
/// validation pipeline.
class CommonMistakes {
  CommonMistakes._();

  static final Map<String, CommonMistake> _db = {
    // Syntax mistakes
    'missing_select_list': CommonMistake(
      key: 'missing_select_list',
      title: 'Missing SELECT list',
      explanation:
          'Every query needs SELECT to specify what data you want. '
          'Try: SELECT column_name FROM table_name',
      example: 'SELECT name, price FROM products',
      sqlKeyword: 'SELECT',
    ),
    'missing_from_clause': CommonMistake(
      key: 'missing_from_clause',
      title: 'Missing FROM clause',
      explanation:
          'SQL needs to know which table to read data from. '
          'Add FROM table_name after your SELECT list.',
      example: 'SELECT name FROM products',
      sqlKeyword: 'FROM',
    ),
    'group_by_syntax': CommonMistake(
      key: 'group_by_syntax',
      title: 'GROUP BY syntax',
      explanation:
          'GROUP BY groups rows with the same values. '
          'It comes after WHERE and before HAVING. '
          'Syntax: GROUP BY column_name',
      example: 'SELECT category, COUNT(*) FROM products GROUP BY category',
      sqlKeyword: 'GROUP BY',
    ),
    'having_without_group': CommonMistake(
      key: 'having_without_group',
      title: 'HAVING without GROUP BY',
      explanation:
          'HAVING filters grouped results — it needs GROUP BY to work. '
          'If you want to filter individual rows, use WHERE instead.',
      example: 'SELECT category, COUNT(*) FROM products GROUP BY category HAVING COUNT(*) > 5',
      sqlKeyword: 'HAVING',
    ),

    // Semantic mistakes
    'unknown_table': CommonMistake(
      key: 'unknown_table',
      title: 'Table not found',
      explanation:
          'The table name you used doesn\'t exist in this database. '
          'Open the Schema Browser (the panel on the left) to see all available tables.',
      sqlKeyword: 'FROM',
    ),
    'equals_null': CommonMistake(
      key: 'equals_null',
      title: 'Comparing with = NULL',
      explanation:
          'NULL means "unknown", so = NULL never matches anything — not even NULL itself. '
          'Use IS NULL to find rows where a value is missing, or IS NOT NULL to find rows with a value.',
      example: 'SELECT * FROM orders WHERE delivery_date IS NULL',
      sqlKeyword: 'IS NULL',
    ),
    'select_star_group_by': CommonMistake(
      key: 'select_star_group_by',
      title: 'SELECT * with GROUP BY',
      explanation:
          'When you GROUP BY, the database collapses many rows into one group. '
          'SELECT * would try to show all columns from all those rows at once — '
          'it doesn\'t make sense. List the specific column(s) you\'re grouping by, '
          'plus any aggregate functions.',
      example: 'SELECT category, COUNT(*) AS total FROM products GROUP BY category',
      sqlKeyword: 'GROUP BY',
    ),

    // Performance
    'full_table_scan': CommonMistake(
      key: 'full_table_scan',
      title: 'Full table scan',
      explanation:
          'Your query reads every single row in the table to find matches. '
          'On a large table this is slow. Adding an index on the column you\'re filtering '
          'by lets the database jump directly to the right rows.',
      sqlKeyword: 'INDEX',
    ),
  };

  static CommonMistake? lookup(String key) => _db[key];

  static CommonMistake fallback(String rawError) => CommonMistake(
        key: 'generic_error',
        title: 'Query Error',
        explanation: rawError,
        sqlKeyword: null,
      );
}

class CommonMistake {
  final String key;
  final String title;
  final String explanation;
  final String? example;
  final String? sqlKeyword;

  const CommonMistake({
    required this.key,
    required this.title,
    required this.explanation,
    this.example,
    this.sqlKeyword,
  });
}
