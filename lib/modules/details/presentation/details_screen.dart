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
    final detailsState = ref.watch(detailsViewModelProvider(employeeId));
    final employee = ref.watch(employeeProvider(employeeId));
    final hasError = ref.watch(detailsHasErrorProvider(employeeId));
    final errorMessage = ref.watch(detailsErrorMessageProvider(employeeId));
    final viewModel = ref.read(detailsViewModelProvider(employeeId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: _buildBody(detailsState, employee, hasError, errorMessage, viewModel),
    );
  }

  Widget _buildBody(
    DetailsState detailsState,
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

    if (detailsState == DetailsState.loading) {
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
