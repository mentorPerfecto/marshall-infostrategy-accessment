import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../common/models/employee.dart';
import '../../common/constants.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;

  const EmployeeCard({
    Key? key,
    required this.employee,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.go(AppConstants.employeeDetailsRoute.replaceFirst(':id', employee.id.toString())),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      employee.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  EmploymentStatusBadge(status: employee.employmentStatus),
                ],
              ),
              SizedBox(height: 8.h),

              // Designation
              Text(
                employee.designation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 4.h),

              // Level and productivity score
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    'Level ${employee.level}',
                    Icons.grade,
                  ),
                  SizedBox(width: 8.w),
                  _buildInfoChip(
                    context,
                    '${employee.productivityScore}%',
                    Icons.analytics,
                    color: _getProductivityColor(employee.productivityScore),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Salary
              Text(
                'Salary: ${employee.currentSalary}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues( alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.primary).withValues( alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color ?? theme.colorScheme.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color ?? theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProductivityColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    if (score >= 40) return Colors.red;
    return Colors.red.shade900;
  }
}

class EmploymentStatusBadge extends StatelessWidget {
  final EmploymentStatus status;

  const EmploymentStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case EmploymentStatus.active:
        backgroundColor = Colors.green.withValues( alpha: 0.1);
        textColor = Colors.green;
        label = 'Active';
        break;
      case EmploymentStatus.terminated:
        backgroundColor = Colors.red.withValues( alpha: 0.1);
        textColor = Colors.red;
        label = 'Terminated';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withValues( alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}