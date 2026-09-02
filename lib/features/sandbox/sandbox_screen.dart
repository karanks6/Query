import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  final TextEditingController _queryController = TextEditingController();
  late sqlite.Database _db;
  
  sqlite.ResultSet? _result;
  String? _error;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  void _initDb() {
    try {
      _db = sqlite.sqlite3.openInMemory();
      
      // Seed the sandbox with a rich standard schema (HR / E-commerce mix)
      _db.execute('''
        CREATE TABLE departments (id INTEGER PRIMARY KEY, name TEXT NOT NULL, budget REAL);
        CREATE TABLE employees (id INTEGER PRIMARY KEY, name TEXT NOT NULL, department_id INTEGER, salary REAL, hire_date TEXT);
        CREATE TABLE projects (id INTEGER PRIMARY KEY, name TEXT NOT NULL, status TEXT);
        CREATE TABLE assignments (employee_id INTEGER, project_id INTEGER, role TEXT);
        
        INSERT INTO departments VALUES (1, 'Engineering', 500000), (2, 'Marketing', 150000), (3, 'Sales', 200000);
        INSERT INTO employees VALUES (101, 'Alice', 1, 95000, '2023-01-15'), (102, 'Bob', 1, 85000, '2023-03-22'), (103, 'Charlie', 2, 75000, '2022-11-05'), (104, 'Diana', 3, 105000, '2021-08-30'), (105, 'Eve', NULL, 60000, '2024-01-10');
        INSERT INTO projects VALUES (10, 'Project Apollo', 'Active'), (20, 'Project Zeus', 'Planning'), (30, 'Project Hermes', 'Completed');
        INSERT INTO assignments VALUES (101, 10, 'Lead'), (102, 10, 'Developer'), (101, 20, 'Consultant'), (104, 30, 'Manager');
      ''');
      
      setState(() {
        _isInitializing = false;
        _queryController.text = 'SELECT * FROM employees;';
      });
      _runQuery();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize Sandbox: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _db.dispose();
    super.dispose();
  }

  void _runQuery() {
    if (_queryController.text.trim().isEmpty) return;
    
    setState(() {
      _error = null;
      _result = null;
    });

    try {
      final res = _db.select(_queryController.text);
      setState(() {
        _result = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(
        title: 'SANDBOX TERMINAL',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ParallaxBackground(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GameTokens.accent)))
            : Column(
                children: [
                  // Info Banner
                  SlantedPanel(
                    padding: const EdgeInsets.all(GameTokens.spaceMd),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Memory instance active. Available tables: departments, employees, projects, assignments.',
                        style: GameTokens.bodySmall.copyWith(color: GameTokens.accent),
                      ),
                    ),
                  ),
                  
                  // Editor
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(GameTokens.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SlantedPanel(
                              padding: EdgeInsets.zero,
                              child: TextField(
                                controller: _queryController,
                                maxLines: null,
                                expands: true,
                                style: GameTokens.code.copyWith(
                                  color: GameTokens.primaryText,
                                  height: 1.5,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(GameTokens.spaceMd),
                                  hintText: 'Enter SQL query...',
                                  hintStyle: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: GameTokens.spaceMd),
                          ActionButton(
                            isPrimary: true,
                            onPressed: _runQuery,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, size: 16),
                                const SizedBox(width: GameTokens.spaceSm),
                                const Text('EXECUTE QUERY'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Results
                  Expanded(
                    flex: 3,
                    child: SlantedPanel(
                      padding: const EdgeInsets.all(GameTokens.spaceMd),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildResultsArea(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_error != null) {
      return SingleChildScrollView(
        child: Text(
          'ERROR: $_error',
          style: GameTokens.bodyMedium.copyWith(color: GameTokens.error),
        ),
      );
    }

    if (_result == null) {
      return Center(
        child: Text(
          'READY FOR INPUT',
          style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText),
        ),
      );
    }

    if (_result!.isEmpty) {
      return Center(
        child: Text(
          '0 ROWS RETURNED',
          style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: GameTokens.bodySmall.copyWith(
            color: GameTokens.accent,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: GameTokens.bodyMedium.copyWith(
            color: GameTokens.primaryText,
          ),
          dividerThickness: 1,
          border: TableBorder(
            horizontalInside: BorderSide(color: GameTokens.accentDim, width: 1),
          ),
          columns: _result!.columnNames
              .map((col) => DataColumn(label: Text(col)))
              .toList(),
          rows: _result!.rows.map((row) {
            return DataRow(
              cells: row.map((cell) => DataCell(Text(cell?.toString() ?? 'NULL'))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
