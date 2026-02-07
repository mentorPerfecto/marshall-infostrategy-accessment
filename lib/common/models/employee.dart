import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

enum EmploymentStatus {
  @JsonValue(0)
  terminated,
  @JsonValue(1)
  active,
}

enum ProductivityResult {
  promotion,
  noChange,
  demotion,
  termination,
}

@JsonSerializable()
class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String designation;
  final int level;
  final double productivityScore;
  final String currentSalary;
  final EmploymentStatus employmentStatus;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.level,
    required this.productivityScore,
    required this.currentSalary,
    required this.employmentStatus,
  });

  // JSON serialization
  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  // Database mapping
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'designation': designation,
      'level': level,
      'productivity_score': productivityScore,
      'current_salary': currentSalary,
      'employment_status': employmentStatus.index,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      designation: map['designation'],
      level: map['level'],
      productivityScore: map['productivity_score'],
      currentSalary: map['current_salary'],
      employmentStatus: EmploymentStatus.values[map['employment_status']],
    );
  }

  // Computed properties
  String get fullName => '$firstName $lastName';

  int get salaryAmount {
    // Remove commas and convert to int
    return int.tryParse(currentSalary.replaceAll(',', '')) ?? 0;
  }

  // Productivity score logic
  ProductivityResult get productivityResult {
    final score = productivityScore;
    if (score >= 80 && score <= 100) {
      return ProductivityResult.promotion;
    } else if (score >= 50 && score < 80) {
      return ProductivityResult.noChange;
    } else if (score >= 40 && score < 50) {
      return ProductivityResult.demotion;
    } else {
      return ProductivityResult.termination;
    }
  }

  // New salary based on level and productivity result
  int get newSalary {
    // Base salary by level
    int baseSalary;
    switch (level) {
      case 0:
        baseSalary = 70000;
        break;
      case 1:
        baseSalary = 100000;
        break;
      case 2:
        baseSalary = 120000;
        break;
      case 3:
        baseSalary = 180000;
        break;
      case 4:
        baseSalary = 200000;
        break;
      case 5:
        baseSalary = 250000;
        break;
      default:
        baseSalary = 70000;
    }

    // Apply productivity result
    switch (productivityResult) {
      case ProductivityResult.promotion:
        // Promotion with pay increase
        return _getNextLevelSalary();
      case ProductivityResult.noChange:
        return baseSalary;
      case ProductivityResult.demotion:
        // Level 0 employees cannot be demoted, only terminated
        if (level == 0) {
          return baseSalary; // Stay at current level
        }
        return _getPreviousLevelSalary();
      case ProductivityResult.termination:
        return salaryAmount; // Keep current salary when terminated
    }
  }

  int _getNextLevelSalary() {
    switch (level) {
      case 0:
        return 100000; // Level 1 salary
      case 1:
        return 120000; // Level 2 salary
      case 2:
        return 180000; // Level 3 salary
      case 3:
        return 200000; // Level 4 salary
      case 4:
        return 250000; // Level 5 salary
      case 5:
        return 250000; // Max level, stay at 250k
      default:
        return 70000;
    }
  }

  int _getPreviousLevelSalary() {
    switch (level) {
      case 1:
        return 70000; // Level 0 salary
      case 2:
        return 100000; // Level 1 salary
      case 3:
        return 120000; // Level 2 salary
      case 4:
        return 180000; // Level 3 salary
      case 5:
        return 200000; // Level 4 salary
      default:
        return 70000;
    }
  }

  // New employment status after evaluation
  EmploymentStatus get newEmploymentStatus {
    switch (productivityResult) {
      case ProductivityResult.termination:
        return EmploymentStatus.terminated;
      default:
        return EmploymentStatus.active;
    }
  }

  // Create copy with updated values
  Employee copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? designation,
    int? level,
    double? productivityScore,
    String? currentSalary,
    EmploymentStatus? employmentStatus,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      designation: designation ?? this.designation,
      level: level ?? this.level,
      productivityScore: productivityScore ?? this.productivityScore,
      currentSalary: currentSalary ?? this.currentSalary,
      employmentStatus: employmentStatus ?? this.employmentStatus,
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, name: $fullName, designation: $designation, level: $level, score: $productivityScore, salary: $currentSalary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Employee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}