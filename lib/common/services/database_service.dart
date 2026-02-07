import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../common/constants.dart';
import '../models/employee.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.employeesTable} (
        id INTEGER PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        designation TEXT NOT NULL,
        level INTEGER NOT NULL,
        productivity_score REAL NOT NULL,
        current_salary TEXT NOT NULL,
        employment_status INTEGER NOT NULL
      )
    ''');
  }

  // CRUD Operations

  // Create/Insert
  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert(
      AppConstants.employeesTable,
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all employees
  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.employeesTable);

    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  // Read employee by ID
  Future<Employee?> getEmployeeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.employeesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    }
    return null;
  }

  // Update employee
  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      AppConstants.employeesTable,
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  // Delete employee
  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.employeesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all employees
  Future<int> deleteAllEmployees() async {
    final db = await database;
    return await db.delete(AppConstants.employeesTable);
  }

  // Insert multiple employees (batch insert)
  Future<void> insertEmployees(List<Employee> employees) async {
    final db = await database;
    Batch batch = db.batch();

    for (var employee in employees) {
      batch.insert(
        AppConstants.employeesTable,
        employee.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Search/Filter employees
  Future<List<Employee>> searchEmployees({
    String? name,
    String? designation,
    int? level,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClauses.add('(first_name LIKE ? OR last_name LIKE ?)');
      whereArgs.add('%$name%');
      whereArgs.add('%$name%');
    }

    if (designation != null && designation.isNotEmpty) {
      whereClauses.add('designation LIKE ?');
      whereArgs.add('%$designation%');
    }

    if (level != null) {
      whereClauses.add('level = ?');
      whereArgs.add(level);
    }

    String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.employeesTable,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  // Get employee count
  Future<int> getEmployeeCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.employeesTable}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}