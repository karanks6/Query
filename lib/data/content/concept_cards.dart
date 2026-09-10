/// Concept card library — maps conceptCardId values to structured lesson content.
///
/// Each card is used by [ConceptLessonDialog] on first exposure to a level.
library;

class ConceptCard {
  final String id;
  final String title;
  final String subtitle;
  final String explanation;
  final String codeExample;
  final String? doExample;
  final String? dontExample;
  final String? tip;

  const ConceptCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.explanation,
    required this.codeExample,
    this.doExample,
    this.dontExample,
    this.tip,
  });
}

class ConceptCards {
  ConceptCards._();

  static ConceptCard? lookup(String? id) {
    if (id == null) return null;
    return _cards[id];
  }

  /// Returns the best matching card for a level.
  static ConceptCard? forLevel(String? conceptCardId, String coreConcept) {
    if (conceptCardId != null && _cards.containsKey(conceptCardId)) {
      return _cards[conceptCardId];
    }
    final c = coreConcept.toUpperCase();
    if (c.contains('GROUP BY') || c.contains('HAVING')) return _cards['group_by'];
    if (c.contains('JOIN')) return _cards['join'];
    if (c.contains('WHERE')) return _cards['where'];
    if (c.contains('ORDER BY') || c.contains('LIMIT')) return _cards['order_limit'];
    if (c.contains('DISTINCT')) return _cards['distinct'];
    if (c.contains('AGGREGATE') || c.contains('COUNT') || c.contains('SUM')) return _cards['aggregates'];
    if (c.contains('SUBQUERY') || c.contains('EXISTS') || c.contains('IN')) return _cards['subquery'];
    if (c.contains('CTE') || c.contains('WITH')) return _cards['cte'];
    if (c.contains('WINDOW') || c.contains('OVER') || c.contains('RANK')) return _cards['window'];
    return _cards['select_basics'];
  }

  static const Map<String, ConceptCard> _cards = {
    'select_basics': ConceptCard(
      id: 'select_basics',
      title: 'SELECT & FROM',
      subtitle: 'Retrieving data from a table',
      explanation:
          'The **SELECT** statement fetches columns from a table. '
          '**FROM** tells SQL which table to look in. '
          'Use `SELECT *` to get all columns, or name specific ones to be precise.',
      codeExample: 'SELECT name, salary\nFROM employees;',
      doExample: 'SELECT name, department FROM employees;',
      dontExample: 'SELECT * FROM employees;  -- inefficient for large tables',
      tip: 'Naming columns explicitly makes queries faster and easier to read.',
    ),

    'distinct': ConceptCard(
      id: 'distinct',
      title: 'DISTINCT',
      subtitle: 'Removing duplicate rows',
      explanation:
          '**DISTINCT** removes duplicate rows from your result. '
          'Place it after SELECT to apply it to all columns. '
          'Both columns must match to be considered a duplicate.',
      codeExample: 'SELECT DISTINCT department\nFROM employees;',
      doExample: 'SELECT DISTINCT city, country FROM contacts;',
      dontExample: 'SELECT DISTINCT * FROM employees;  -- rarely useful',
      tip: 'DISTINCT applies across ALL selected columns together.',
    ),

    'where': ConceptCard(
      id: 'where',
      title: 'WHERE Clause',
      subtitle: 'Filtering rows by condition',
      explanation:
          'The **WHERE** clause filters which rows are returned. '
          'Use operators like `=`, `<`, `>`, `<>`, `BETWEEN`, `LIKE`, `IN`. '
          'Combine conditions with **AND** / **OR**.',
      codeExample:
          "SELECT name, salary\n"
          "FROM employees\n"
          "WHERE salary > 50000 AND department = 'Engineering';",
      doExample: "WHERE department = 'Sales' AND active = 1",
      dontExample: "WHERE name LIKE '%'  -- matches everything, no filter",
      tip: "Use single quotes for text: WHERE name = 'Alice'",
    ),

    'order_limit': ConceptCard(
      id: 'order_limit',
      title: 'ORDER BY & LIMIT',
      subtitle: 'Sorting and slicing results',
      explanation:
          '**ORDER BY** sorts results by one or more columns (ASC by default, DESC for reverse). '
          '**LIMIT** restricts how many rows are returned — great for top-N queries.',
      codeExample:
          'SELECT name, salary\n'
          'FROM employees\n'
          'ORDER BY salary DESC\n'
          'LIMIT 5;',
      doExample: 'ORDER BY created_at DESC LIMIT 10',
      dontExample: 'ORDER BY 1  -- column index works but is fragile',
      tip: 'ORDER BY always happens AFTER WHERE and GROUP BY.',
    ),

    'aggregates': ConceptCard(
      id: 'aggregates',
      title: 'Aggregate Functions',
      subtitle: 'COUNT, SUM, AVG, MIN, MAX',
      explanation:
          'Aggregate functions compute a single value from many rows. '
          '**COUNT(*)** counts all rows. **SUM**, **AVG**, **MIN**, **MAX** work on numerics. '
          'With **GROUP BY**, they compute per-group statistics.',
      codeExample:
          'SELECT department,\n'
          '       COUNT(*) AS headcount,\n'
          '       AVG(salary) AS avg_salary\n'
          'FROM employees\n'
          'GROUP BY department;',
      doExample: "SELECT COUNT(*) FROM orders WHERE status = 'complete'",
      dontExample: 'SELECT COUNT(salary)  -- ignores NULL rows',
      tip: 'COUNT(*) includes NULLs. COUNT(column) does not.',
    ),

    'group_by': ConceptCard(
      id: 'group_by',
      title: 'GROUP BY & HAVING',
      subtitle: 'Grouping and filtering aggregates',
      explanation:
          '**GROUP BY** groups rows sharing the same value so aggregate functions apply per group. '
          '**HAVING** filters groups after aggregation — unlike WHERE which filters rows before.',
      codeExample:
          'SELECT department, COUNT(*) AS headcount\n'
          'FROM employees\n'
          'GROUP BY department\n'
          'HAVING COUNT(*) > 5;',
      doExample: 'HAVING AVG(salary) > 60000',
      dontExample: 'WHERE COUNT(*) > 5  -- ERROR: cannot use aggregates in WHERE',
      tip: 'Order: WHERE → GROUP BY → HAVING → ORDER BY',
    ),

    'join': ConceptCard(
      id: 'join',
      title: 'JOIN',
      subtitle: 'Combining rows from multiple tables',
      explanation:
          'A **JOIN** connects rows from two tables by a related column. '
          '**INNER JOIN** returns rows with matches in both. '
          '**LEFT JOIN** returns all left rows, even without a match.',
      codeExample:
          'SELECT e.name, d.department_name\n'
          'FROM employees e\n'
          'INNER JOIN departments d\n'
          '  ON e.dept_id = d.id;',
      doExample: 'ON e.department_id = d.id',
      dontExample: 'FROM employees, departments  -- implicit join, avoid this',
      tip: 'Always specify ON — a missing condition creates a cartesian product!',
    ),

    'subquery': ConceptCard(
      id: 'subquery',
      title: 'Subqueries',
      subtitle: 'Nesting queries inside queries',
      explanation:
          'A **subquery** is a SELECT embedded inside another query. '
          'Use with **IN**, **EXISTS**, or comparison operators in WHERE. '
          'Scalar subqueries return a single value.',
      codeExample:
          'SELECT name\n'
          'FROM employees\n'
          'WHERE dept_id IN (\n'
          '  SELECT id FROM departments\n'
          "  WHERE location = 'London'\n"
          ');',
      doExample: 'WHERE salary > (SELECT AVG(salary) FROM employees)',
      dontExample: 'Avoid deeply nested subqueries — use CTEs instead',
      tip: 'EXISTS is often faster than IN for large datasets.',
    ),

    'cte': ConceptCard(
      id: 'cte',
      title: 'Common Table Expressions (WITH)',
      subtitle: 'Named temporary result sets',
      explanation:
          'A **CTE** (WITH clause) acts like a named temporary view. '
          'CTEs make complex queries readable by breaking them into logical steps.',
      codeExample:
          'WITH high_earners AS (\n'
          '  SELECT name, salary\n'
          '  FROM employees\n'
          '  WHERE salary > 80000\n'
          ')\n'
          'SELECT name FROM high_earners\n'
          'ORDER BY salary DESC;',
      doExample: 'WITH sales AS (...), totals AS (...) SELECT ...',
      dontExample: 'Avoid CTEs for simple filters — just use WHERE',
      tip: 'Chain multiple CTEs by separating them with commas.',
    ),

    'window': ConceptCard(
      id: 'window',
      title: 'Window Functions',
      subtitle: 'OVER, PARTITION BY, ROW_NUMBER',
      explanation:
          '**Window functions** compute values across related rows without collapsing them. '
          'The **OVER()** clause defines the window. '
          'Common: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM OVER.',
      codeExample:
          'SELECT name, salary,\n'
          '  RANK() OVER (\n'
          '    PARTITION BY department\n'
          '    ORDER BY salary DESC\n'
          '  ) AS dept_rank\n'
          'FROM employees;',
      doExample: 'ROW_NUMBER() OVER (PARTITION BY dept ORDER BY hire_date)',
      dontExample: 'RANK() OVER ()  -- no PARTITION means one global window',
      tip: 'Window functions run AFTER WHERE and GROUP BY but BEFORE ORDER BY.',
    ),
  };
}
