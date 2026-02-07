part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      designation: json['designation'] as String,
      level: json['level'] as int,
      productivityScore: (json['productivity_score'] as num).toDouble(),
      currentSalary: json['current_salary'] as String,
      employmentStatus: $enumDecode(_$EmploymentStatusEnumMap, json['employment_status']),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'designation': instance.designation,
      'level': instance.level,
      'productivity_score': instance.productivityScore,
      'current_salary': instance.currentSalary,
      'employment_status': _$EmploymentStatusEnumMap[instance.employmentStatus]!,
    };

const _$EmploymentStatusEnumMap = {
  EmploymentStatus.terminated: 0,
  EmploymentStatus.active: 1,
};