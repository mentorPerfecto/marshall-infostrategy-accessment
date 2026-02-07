import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/models/employee.dart';

class ProductivityIndicator extends StatelessWidget {
  final ProductivityResult result;
  final double score;

  const ProductivityIndicator({
    Key? key,
    required this.result,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withValues( alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _getBorderColor().withValues( alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          // Score display
          Text(
            '${score.toStringAsFixed(1)}%',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: _getTextColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),

          // Result label
          Text(
            _getResultLabel(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: _getTextColor(),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Description
          Text(
            _getResultDescription(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues( alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (result) {
      case ProductivityResult.promotion:
        return Colors.green;
      case ProductivityResult.noChange:
        return Colors.blue;
      case ProductivityResult.demotion:
        return Colors.orange;
      case ProductivityResult.termination:
        return Colors.red;
    }
  }

  Color _getBorderColor() {
    return _getBackgroundColor();
  }

  Color _getTextColor() {
    return _getBackgroundColor();
  }

  String _getResultLabel() {
    switch (result) {
      case ProductivityResult.promotion:
        return 'Promotion';
      case ProductivityResult.noChange:
        return 'No Change';
      case ProductivityResult.demotion:
        return 'Demotion';
      case ProductivityResult.termination:
        return 'Termination';
    }
  }

  String _getResultDescription() {
    switch (result) {
      case ProductivityResult.promotion:
        return 'Outstanding performance! Eligible for promotion and salary increase.';
      case ProductivityResult.noChange:
        return 'Good performance. Employment status remains unchanged.';
      case ProductivityResult.demotion:
        return 'Performance needs improvement. Eligible for demotion.';
      case ProductivityResult.termination:
        return 'Poor performance. Employment may be terminated.';
    }
  }
}

class SalaryComparisonWidget extends StatelessWidget {
  final int currentSalary;
  final int newSalary;

  const SalaryComparisonWidget({
    Key? key,
    required this.currentSalary,
    required this.newSalary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difference = newSalary - currentSalary;
    final isIncrease = difference > 0;
    final isDecrease = difference < 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues( alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Salary Adjustment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),

          // Current salary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current:',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '₦${_formatSalary(currentSalary)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // New salary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₦${_formatSalary(newSalary)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isIncrease ? Colors.green : isDecrease ? Colors.red : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          if (difference != 0) ...[
            SizedBox(height: 8.h),
            const Divider(),
            SizedBox(height: 8.h),

            // Difference
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isIncrease ? 'Increase' : 'Decrease'}:',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${isIncrease ? '+' : ''}₦${_formatSalary(difference.abs())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isIncrease ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatSalary(int salary) {
    return salary.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}