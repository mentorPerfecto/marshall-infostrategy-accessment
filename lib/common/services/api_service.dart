import '../models/employee.dart';
import '../io/data.dart' as data;

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Not used in simulation

  // Load employee data from successResponse JSON
  Future<List<Employee>> fetchEmployees({bool simulateError = false}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (simulateError) {
      throw ApiException(
        message: data.Api.errorRexponse['message'] as String,
        statusCode: data.Api.errorRexponse['statusCode'] as int,
        errors: data.Api.errorRexponse['errors'] as Map<String, dynamic>,
      );
    }

    try {
      // Load employee data from successResponse JSON
      final responseData = data.Api.successResponse;
      final List<dynamic> employeeData = responseData['data'] as List<dynamic>;

      // Parse JSON data into Employee objects
      final employees = employeeData.map((json) => Employee.fromJson(json as Map<String, dynamic>)).toList();

      return employees;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse employee data: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Alternative: Real HTTP implementation using Dio (commented out for now)
  /*
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await _dio.get('/employees');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> employeeData = responseData['data'];

        return employeeData.map((json) => Employee.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = response.data ?? {};
        throw ApiException(
          message: errorData['message'] ?? 'Unknown error',
          statusCode: response.statusCode ?? 500,
          errors: errorData['errors'],
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException(
          message: 'Connection timeout',
          statusCode: 408,
        );
      } else if (e.type == DioExceptionType.badResponse) {
        throw ApiException(
          message: e.response?.data?['message'] ?? 'Bad response',
          statusCode: e.response?.statusCode ?? 500,
          errors: e.response?.data?['errors'],
        );
      } else {
        throw ApiException(
          message: 'Network error: ${e.message}',
          statusCode: 0,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
  */

  // Get employee by ID (for future use)
  Future<Employee> fetchEmployeeById(int id) async {
    final employees = await fetchEmployees();
    final employee = employees.where((emp) => emp.id == id).firstOrNull;

    if (employee == null) {
      throw ApiException(
        message: 'Employee with ID $id not found',
        statusCode: 404,
      );
    }

    return employee;
  }

  // Simulate posting employee data (for future use)
  Future<Employee> createEmployee(Employee employee) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real API, this would make a POST request
    return employee;
  }

  // Simulate updating employee (for future use)
  Future<Employee> updateEmployee(Employee employee) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real API, this would make a PUT request
    return employee;
  }

  // Simulate deleting employee (for future use)
  Future<void> deleteEmployee(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real API, this would make a DELETE request
  }
}