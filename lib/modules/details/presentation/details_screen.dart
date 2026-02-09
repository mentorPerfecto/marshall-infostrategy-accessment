import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/details_viewmodel.dart';
import '../../widgets/productivity_indicator.dart';
import '../../widgets/employee_card.dart';
import '../../widgets/loading_error_widgets.dart' as custom_widgets;
import '../../../common/models/employee.dart';

class DetailsScreen extends ConsumerWidget {
  final int employeeId;

  const DetailsScreen({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(detailsViewModelProvider(employeeId));
    final employee = ref.watch(employeeProvider(employeeId));
    final hasError = ref.watch(detailsHasErrorProvider(employeeId));
    final errorMessage = ref.watch(detailsErrorMessageProvider(employeeId));
    final viewModel = ref.watch(detailsViewModelNotifierProvider(employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Refresh home screen data when returning
            context.go('/');
          },
        ),
      ),
      body: _buildBody(viewState, employee, hasError, errorMessage, viewModel),
    );
  }

  Widget _buildBody(
    DetailsViewState viewState,
    Employee? employee,
    bool hasError,
    String? errorMessage,
    DetailsViewModel viewModel,
  ) {
    if (hasError) {
      return custom_widgets.CustomErrorWidget(
        message: errorMessage ?? 'Failed to load employee details',
        onRetry: () => viewModel.refresh(),
        retryText: 'Retry',
      );
    }

    if (viewState.state == DetailsState.loading) {
      return const custom_widgets.LoadingWidget(message: 'Loading employee details...');
    }

    if (employee == null) {
      return Builder(
        builder: (context) => custom_widgets.EmptyStateWidget(
          title: 'Employee Not Found',
          message: 'The requested employee could not be found.',
          icon: Icons.person_off,
          onAction: () => context.go('/'),
          actionText: 'Back to List',
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Header Card
            _buildEmployeeHeader(context, employee),

            SizedBox(height: 24.h),

            // Productivity Assessment Section
            _buildProductivitySection(context, employee),

            SizedBox(height: 24.h),

            // Salary Information Section
            _buildSalarySection(context, employee),

            SizedBox(height: 24.h),

            // Employment Status Section
            _buildEmploymentStatusSection(context, employee),

            SizedBox(height: 24.h),

            // Level Management Section
            _buildLevelManagementSection(context, employee, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(BuildContext context, Employee employee) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues( alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues( alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              employee.firstName[0] + employee.lastName[0],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Name
          Text(
            employee.fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          // Designation and Level
          Text(
            '${employee.designation} • Level ${employee.level}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // Current Status Badge
          EmploymentStatusBadge(status: employee.employmentStatus),
        ],
      ),
    );
  }

  Widget _buildProductivitySection(BuildContext context, Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productivity Assessment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        ProductivityIndicator(
          result: employee.productivityResult,
          score: employee.productivityScore,
        ),

        SizedBox(height: 16.h),

        // Productivity Score Details
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues( alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assessment Criteria',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),

              _buildCriteriaRow(context, '100-80%', 'Promotion & Pay Increase'),
              _buildCriteriaRow(context, '79-50%', 'No Change'),
              _buildCriteriaRow(context, '49-40%', 'Demotion'),
              _buildCriteriaRow(context, '39% & below', 'Termination'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalarySection(BuildContext context, Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        SalaryComparisonWidget(
          currentSalary: employee.salaryAmount,
          newSalary: employee.newSalary,
        ),
      ],
    );
  }

  Widget _buildEmploymentStatusSection(BuildContext context, Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employment Status',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues( alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues( alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    employee.employmentStatus == EmploymentStatus.active ? 'Active' : 'Terminated',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: employee.employmentStatus == EmploymentStatus.active
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'New Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues( alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    employee.newEmploymentStatus == EmploymentStatus.active ? 'Active' : 'Terminated',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: employee.newEmploymentStatus == EmploymentStatus.active
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Special note for level 0 employees
        if (employee.level == 0 && employee.productivityResult == ProductivityResult.demotion) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withValues( alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.orange.withValues( alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Level 0 employees cannot be demoted and will only be terminated if performance is below standards.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLevelManagementSection(BuildContext context, Employee employee, DetailsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level Management',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Level & Salary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${employee.level}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Salary: ₦${_formatSalary(employee.salaryAmount)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  // Level selector dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: DropdownButton<int>(
                      value: employee.level,
                      onChanged: (int? newLevel) async {
                        if (newLevel != null && newLevel != employee.level) {
                          final confirmed = await _showLevelUpdateConfirmation(context, employee.level, newLevel);
                          if (confirmed == true) {
                            await viewModel.updateEmployeeLevel(newLevel);
                            // Show success message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Employee level updated successfully'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        }
                      },
                      items: List.generate(6, (index) => index).map<DropdownMenuItem<int>>((int level) {
                        return DropdownMenuItem<int>(
                          value: level,
                          child: Text(
                            'Level $level',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Salary preview for different levels
              Text(
                'Salary by Level',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 8.h),

              ..._buildSalaryByLevelList(context, employee),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSalaryByLevelList(BuildContext context, Employee employee) {
    final salaryMap = {
      0: 70000,
      1: 100000,
      2: 120000,
      3: 180000,
      4: 200000,
      5: 250000,
    };

    return salaryMap.entries.map((entry) {
      final isCurrentLevel = entry.key == employee.level;
      return Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isCurrentLevel
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isCurrentLevel
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${entry.key}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrentLevel ? FontWeight.w600 : FontWeight.normal,
                color: isCurrentLevel
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '₦${_formatSalary(entry.value)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrentLevel ? FontWeight.w600 : FontWeight.normal,
                color: isCurrentLevel
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<bool?> _showLevelUpdateConfirmation(BuildContext context, int currentLevel, int newLevel) {
    final currentSalary = _getSalaryForLevel(currentLevel);
    final newSalary = _getSalaryForLevel(newLevel);
    final salaryDifference = newSalary - currentSalary;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Employee Level'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change level from $currentLevel to $newLevel?'),
              SizedBox(height: 16.h),
              Text(
                'Salary Impact:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text('Current: ₦${_formatSalary(currentSalary)}'),
              Text(
                'New: ₦${_formatSalary(newSalary)}',
                style: TextStyle(
                  color: salaryDifference >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (salaryDifference != 0)
                Text(
                  '${salaryDifference >= 0 ? 'Increase' : 'Decrease'}: ₦${_formatSalary(salaryDifference.abs())}',
                  style: TextStyle(
                    color: salaryDifference >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  int _getSalaryForLevel(int level) {
    switch (level) {
      case 0:
        return 70000;
      case 1:
        return 100000;
      case 2:
        return 120000;
      case 3:
        return 180000;
      case 4:
        return 200000;
      case 5:
        return 250000;
      default:
        return 70000;
    }
  }


  String _formatSalary(int salary) {
    return salary.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildCriteriaRow(BuildContext context, String range, String outcome) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            range,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            outcome,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
