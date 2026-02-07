class AppConstants {
  AppConstants._();

  // Database
  static const String databaseName = 'employee_database.db';
  static const String employeesTable = 'employees';

  // Salary levels
  static const Map<int, int> salaryByLevel = {
    0: 70000,
    1: 100000,
    2: 120000,
    3: 180000,
    4: 200000,
    5: 250000,
  };

  // Productivity score ranges
  static const double promotionMinScore = 80.0;
  static const double promotionMaxScore = 100.0;
  static const double noChangeMinScore = 50.0;
  static const double noChangeMaxScore = 79.0;
  static const double demotionMinScore = 40.0;
  static const double demotionMaxScore = 49.0;
  static const double terminationMaxScore = 39.0;

  // Routes
  static const String homeRoute = '/';
  static const String employeeDetailsRoute = '/employee/:id';
}
