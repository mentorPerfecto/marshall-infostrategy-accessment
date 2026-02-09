import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/employee.dart';
import '../../../common/repositories/employee_repository.dart';
import '../../home/viewmodels/home_viewmodel.dart';

enum DetailsState {
  initial,
  loading,
  loaded,
  error,
}

class DetailsViewState {
  final DetailsState state;
  final Employee? employee;
  final String? errorMessage;

  const DetailsViewState({
    required this.state,
    this.employee,
    this.errorMessage,
  });

  DetailsViewState copyWith({
    DetailsState? state,
    Employee? employee,
    String? errorMessage,
  }) {
    return DetailsViewState(
      state: state ?? this.state,
      employee: employee ?? this.employee,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DetailsViewModel extends StateNotifier<DetailsViewState> {
  final EmployeeRepository _repository;
  final int employeeId;

  DetailsViewModel(this._repository, this.employeeId) : super(const DetailsViewState(state: DetailsState.initial)) {
    loadEmployee();
  }

  // Getters
  Employee? get employee => state.employee;
  DetailsState get currentState => state.state;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.state == DetailsState.error;

  // Load employee by ID
  Future<void> loadEmployee() async {
    state = state.copyWith(state: DetailsState.loading);
    try {
      final employee = await _repository.getEmployeeById(employeeId);
      if (employee == null) {
        throw Exception('Employee not found');
      }
      state = DetailsViewState(
        state: DetailsState.loaded,
        employee: employee,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: DetailsState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update employee level and salary
  Future<void> updateEmployeeLevel(int newLevel) async {
    if (state.employee == null) return;

    try {
      final updatedEmployee = state.employee!.copyWith(
        level: newLevel,
        currentSalary: _getSalaryForLevel(newLevel).toString(),
      );

      await _repository.updateEmployee(updatedEmployee);

      // Update the state with the new employee data
      state = DetailsViewState(
        state: DetailsState.loaded,
        employee: updatedEmployee,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: DetailsState.error,
        errorMessage: 'Failed to update employee level: ${e.toString()}',
      );
    }
  }

  // Helper method to get salary for level
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

  // Refresh employee data
  Future<void> refresh() async {
    await loadEmployee();
  }
}

// Providers
final detailsViewModelProvider = StateNotifierProvider.family<DetailsViewModel, DetailsViewState, int>((ref, employeeId) {
  // Use the shared repository provider
  final repository = ref.watch(employeeRepositoryProvider);
  return DetailsViewModel(repository, employeeId);
});

final detailsViewModelNotifierProvider = Provider.family<DetailsViewModel, int>((ref, employeeId) {
  return ref.watch(detailsViewModelProvider(employeeId).notifier);
});

final employeeProvider = Provider.family<Employee?, int>((ref, employeeId) {
  final viewState = ref.watch(detailsViewModelProvider(employeeId));
  return viewState.employee;
});

final detailsErrorMessageProvider = Provider.family<String?, int>((ref, employeeId) {
  final viewState = ref.watch(detailsViewModelProvider(employeeId));
  return viewState.errorMessage;
});

final detailsHasErrorProvider = Provider.family<bool, int>((ref, employeeId) {
  final viewState = ref.watch(detailsViewModelProvider(employeeId));
  return viewState.state == DetailsState.error;
});