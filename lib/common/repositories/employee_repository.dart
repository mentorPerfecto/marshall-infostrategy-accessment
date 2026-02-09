import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class EmployeeRepository {
  final DatabaseService _databaseService;
  final ApiService _apiService;

  EmployeeRepository({
    required DatabaseService databaseService,
    required ApiService apiService,
  }) : _databaseService = databaseService,
       _apiService = apiService;

  // Fetch employees from API and save to database
  Future<List<Employee>> fetchAndSaveEmployees({bool simulateError = false}) async {
    try {
      final employees = await _apiService.fetchEmployees(simulateError: simulateError);
      // Save to database
      await _databaseService.insertEmployees(employees);
      return employees;
    } catch (e) {
      // If API fails, try to get from database as fallback
      return await _databaseService.getAllEmployees();
    }
  }

  // Get all employees from database
  Future<List<Employee>> getAllEmployees() async {
    return await _databaseService.getAllEmployees();
  }

  // Get employee by ID from database
  Future<Employee?> getEmployeeById(int id) async {
    return await _databaseService.getEmployeeById(id);
  }

  // Search/filter employees
  Future<List<Employee>> searchEmployees({
    String? name,
    String? designation,
    int? level,
  }) async {
    return await _databaseService.searchEmployees(
      name: name,
      designation: designation,
      level: level,
    );
  }

  // Save single employee
  Future<void> saveEmployee(Employee employee) async {
    await _databaseService.insertEmployee(employee);
  }

  // Update employee
  Future<void> updateEmployee(Employee employee) async {
    await _databaseService.updateEmployee(employee);
  }

  // Delete employee
  Future<void> deleteEmployee(int id) async {
    await _databaseService.deleteEmployee(id);
  }

  // Clear all employees
  Future<void> clearAllEmployees() async {
    await _databaseService.deleteAllEmployees();
  }

  // Get employee count
  Future<int> getEmployeeCount() async {
    return await _databaseService.getEmployeeCount();
  }
}