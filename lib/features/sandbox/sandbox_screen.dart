import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';

enum SandboxSchema {
  standard('HR & E-Commerce (Standard)'),
  space('Space Fleet (Sci-Fi)'),
  custom('Custom SQL Schema');

  final String label;
  const SandboxSchema(this.label);
}

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _schemaController = TextEditingController();
  
  late sqlite.Database _db;
  sqlite.ResultSet? _result;
  String? _error;
  bool _isInitializing = true;
  SandboxSchema _selectedSchema = SandboxSchema.standard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _schemaController.text = _getInitialCustomSchema();
    _initDb();
    _loadSnippets();
  }
  
  void _loadSnippets() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuery = prefs.getString('sandbox_saved_query');
    if (savedQuery != null && savedQuery.isNotEmpty && _queryController.text == 'SELECT * FROM employees;') {
      _queryController.text = savedQuery;
    }
  }

  void _saveSnippet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sandbox_saved_query', _queryController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Query snippet saved!', style: GameTokens.bodyMedium.copyWith(color: GameTokens.background)),
          backgroundColor: GameTokens.success,
        )
      );
    }
  }

  String _getInitialCustomSchema() {
    return '''-- Create your custom tables here
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
INSERT INTO users VALUES (1, 'Player One');''';
  }

  void _initDb() {
    try {
      _db = sqlite.sqlite3.openInMemory();
      
      String schemaSql = '';
      if (_selectedSchema == SandboxSchema.standard) {
        schemaSql = '''
          CREATE TABLE departments (id INTEGER PRIMARY KEY, name TEXT NOT NULL, budget REAL);
          CREATE TABLE employees (id INTEGER PRIMARY KEY, name TEXT NOT NULL, department_id INTEGER, salary REAL, hire_date TEXT);
          CREATE TABLE projects (id INTEGER PRIMARY KEY, name TEXT NOT NULL, status TEXT);
          CREATE TABLE assignments (employee_id INTEGER, project_id INTEGER, role TEXT);
          
          INSERT INTO departments VALUES (1, 'Engineering', 500000), (2, 'Marketing', 150000), (3, 'Sales', 200000);
          INSERT INTO employees VALUES (101, 'Alice', 1, 95000, '2023-01-15'), (102, 'Bob', 1, 85000, '2023-03-22'), (103, 'Charlie', 2, 75000, '2022-11-05'), (104, 'Diana', 3, 105000, '2021-08-30'), (105, 'Eve', NULL, 60000, '2024-01-10');
          INSERT INTO projects VALUES (10, 'Project Apollo', 'Active'), (20, 'Project Zeus', 'Planning'), (30, 'Project Hermes', 'Completed');
          INSERT INTO assignments VALUES (101, 10, 'Lead'), (102, 10, 'Developer'), (101, 20, 'Consultant'), (104, 30, 'Manager');
        ''';
        _queryController.text = 'SELECT * FROM employees;';
      } else if (_selectedSchema == SandboxSchema.space) {
        schemaSql = '''
          CREATE TABLE ships (id INTEGER PRIMARY KEY, name TEXT, class TEXT);
          CREATE TABLE crew (id INTEGER PRIMARY KEY, name TEXT, ship_id INTEGER, role TEXT);
          INSERT INTO ships VALUES (1, 'USCSS Nostromo', 'Freighter'), (2, 'USS Enterprise', 'Cruiser');
          INSERT INTO crew VALUES (1, 'Ripley', 1, 'Warrant Officer'), (2, 'Kirk', 2, 'Captain');
        ''';
        _queryController.text = 'SELECT * FROM ships;';
      } else {
        schemaSql = _schemaController.text;
      }
      
      if (schemaSql.trim().isNotEmpty) {
        _db.execute(schemaSql);
      }
      
      setState(() {
        _isInitializing = false;
        _error = null;
        _result = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize Schema: \$e';
        _isInitializing = false;
        _result = null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    _schemaController.dispose();
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
  
  void _applySchema() {
    _db.dispose();
    _initDb();
    if (_selectedSchema == SandboxSchema.custom) {
      _tabController.animateTo(0); // Go back to query tab
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(GameTokens.spaceMd),
              child: SlantedPanel(
                padding: const EdgeInsets.all(GameTokens.spaceMd),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, color: GameTokens.accent, size: 24),
                    const SizedBox(width: GameTokens.spaceMd),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'ABI SANDBOX v3.0  QUERIES_RUN: 42    SCHEMAS: 3',
                            style: GameTokens.code.copyWith(color: GameTokens.primaryText),
                          ),
                          Text(
                            '_',
                            style: GameTokens.code.copyWith(color: GameTokens.accent),
                          ).animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 500.ms).fadeOut(duration: 500.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: GameTokens.accent,
              labelColor: GameTokens.accent,
              unselectedLabelColor: GameTokens.secondaryText,
              tabs: const [
                Tab(text: 'QUERY TERMINAL'),
                Tab(text: 'SCHEMA BUILDER'),
                Tab(text: 'PRESETS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQueryTab(context),
                  _buildSchemaTab(context),
                  _buildPresetsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryTab(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GameTokens.accent)));
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 720;
        return Padding(
          padding: const EdgeInsets.all(GameTokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner is moved to Presets tab now
              // Main content area
              
              // Main content area
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 1, child: _buildEditor()),
                          const SizedBox(width: GameTokens.spaceMd),
                          Expanded(flex: 1, child: _buildResultsPanel()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: _buildEditor()),
                          const SizedBox(height: GameTokens.spaceMd),
                          Expanded(flex: 3, child: _buildResultsPanel()),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSchemaTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlantedPanel(
            padding: const EdgeInsets.all(GameTokens.spaceMd),
            child: Text(
              'Paste your custom DDL/DML statements here. This will initialize the in-memory database.',
              style: GameTokens.bodySmall.copyWith(color: GameTokens.info),
            ),
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Expanded(
            child: SlantedPanel(
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _schemaController,
                maxLines: null,
                expands: true,
                style: GameTokens.code.copyWith(
                  color: GameTokens.primaryText,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(GameTokens.spaceMd),
                  hintText: 'CREATE TABLE ...',
                  hintStyle: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText),
                ),
              ),
            ),
          ),
          const SizedBox(height: GameTokens.spaceMd),
          ActionButton(
            isPrimary: true,
            onPressed: () {
              setState(() {
                _selectedSchema = SandboxSchema.custom;
              });
              _applySchema();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.build, size: 16),
                const SizedBox(width: GameTokens.spaceSm),
                const Text('INITIALIZE DATABASE'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
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
        Row(
          children: [
            Expanded(
              child: ActionButton(
                isPrimary: true,
                onPressed: _runQuery,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 16),
                    const SizedBox(width: GameTokens.spaceSm),
                    const Text('EXECUTE'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: GameTokens.spaceMd),
            ActionButton(
              isPrimary: false,
              onPressed: _saveSnippet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 16),
                  const SizedBox(width: GameTokens.spaceSm),
                  const Text('SAVE PRESET'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPresetsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlantedPanel(
            padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Active Schema: \${_selectedSchema.label}',
                    style: GameTokens.bodySmall.copyWith(color: GameTokens.accent),
                  ),
                ),
                DropdownButton<SandboxSchema>(
                  value: _selectedSchema,
                  dropdownColor: GameTokens.surfaceHighlight,
                  style: GameTokens.bodySmall.copyWith(color: GameTokens.primaryText),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: GameTokens.accent),
                  items: SandboxSchema.values.map((schema) {
                    return DropdownMenuItem(
                      value: schema,
                      child: Text(schema.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSchema = val;
                      });
                      if (val != SandboxSchema.custom) {
                        _applySchema();
                      } else {
                        _tabController.animateTo(1);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: GameTokens.spaceLg),
          Expanded(
            child: ListView(
              children: [
                _buildPresetItem('SELECT ALL FROM EMPLOYEES', 'SELECT * FROM employees;'),
                _buildPresetItem('SELECT BY DEPARTMENT', 'SELECT * FROM employees WHERE department_id = 1;'),
                _buildPresetItem('JOIN EMPLOYEES AND DEPARTMENTS', 'SELECT e.name, d.name AS department FROM employees e JOIN departments d ON e.department_id = d.id;'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPresetItem(String label, String query) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
      child: SlantedPanel(
        padding: const EdgeInsets.all(GameTokens.spaceMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GameTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: GameTokens.spaceSm),
                  Text(query, style: GameTokens.code.copyWith(color: GameTokens.secondaryText)),
                ],
              ),
            ),
            ActionButton(
              isPrimary: true,
              onPressed: () {
                _queryController.text = query;
                _tabController.animateTo(0);
              },
              child: const Text('LOAD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPanel() {
    return SlantedPanel(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: SizedBox(
        width: double.infinity,
        child: _buildResultsArea(),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_error != null) {
      return SingleChildScrollView(
        child: Text(
          'ERROR: \$_error',
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
