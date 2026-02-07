import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../widgets/employee_card.dart';
import '../../widgets/filter_widget.dart';
import '../../widgets/loading_error_widgets.dart' as custom_widgets;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(homeViewModelProvider);
    final employees = ref.watch(employeesProvider);
    final hasError = ref.watch(hasErrorProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        elevation: 0,
        actions: [
          // Error simulation button for testing
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => viewModel.simulateError(),
            tooltip: 'Simulate Error',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues( alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                _buildSearchSection(viewModel),

                SizedBox(height: 16.h),

                // Filter Section
                _buildFilterSection(ref, viewModel),
              ],
            ),
          ),

          // Active Filters Display
          if (viewModel.designationFilter != null || viewModel.levelFilter != null)
            FilterChipsWidget(
              designationFilter: viewModel.designationFilter,
              levelFilter: viewModel.levelFilter,
              onClearFilters: viewModel.clearFilters,
            ),

          // Employee List
          Expanded(
            child: _buildEmployeeList(viewState, employees, hasError, errorMessage, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(HomeViewModel viewModel) {
    return SearchBarWidget(
      initialValue: viewModel.searchQuery,
      hintText: 'Search employees by name...',
      onChanged: viewModel.searchEmployees,
      onClear: () => viewModel.searchEmployees(''),
    );
  }

  Widget _buildFilterSection(WidgetRef ref, HomeViewModel viewModel) {
    final designations = ref.watch(uniqueDesignationsProvider);
    final levels = ref.watch(uniqueLevelsProvider);

    return Row(
      children: [
        // Designation Filter
        Expanded(
          child: FilterWidget(
            selectedValue: viewModel.designationFilter,
            options: designations,
            hintText: 'All Designations',
            labelText: 'Filter by Designation',
            onChanged: viewModel.filterByDesignation,
          ),
        ),

        SizedBox(width: 16.w),

        // Level Filter
        Expanded(
          child: FilterWidget(
            selectedValue: viewModel.levelFilter?.toString(),
            options: levels.map((level) => level.toString()).toList(),
            hintText: 'All Levels',
            labelText: 'Filter by Level',
            onChanged: (value) => viewModel.filterByLevel(
              value != null ? int.tryParse(value) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeList(
    HomeViewState viewState,
    List employees,
    bool hasError,
    String? errorMessage,
    HomeViewModel viewModel,
  ) {
    if (hasError) {
      return custom_widgets.CustomErrorWidget(
        message: errorMessage ?? 'Failed to load employees',
        onRetry: () => viewModel.refresh(),
        retryText: 'Retry Loading',
      );
    }

    if (viewState.state == HomeState.loading && employees.isEmpty) {
      return const custom_widgets.LoadingWidget(message: 'Loading employees...');
    }

    if (employees.isEmpty) {
      return custom_widgets.EmptyStateWidget(
        title: 'No Employees Found',
        message: viewState.state == HomeState.loaded
            ? 'Try adjusting your search or filters'
            : 'Pull to refresh to load employees',
        icon: Icons.people_outline,
        onAction: () => viewModel.refresh(),
        actionText: 'Load Employees',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.refresh(),
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 16.h),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return EmployeeCard(employee: employee);
        },
      ),
    );
  }
}
