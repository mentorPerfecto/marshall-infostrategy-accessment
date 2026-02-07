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

class DetailsViewModel extends StateNotifier<DetailsState> {
  final EmployeeRepository _repository;
  final int employeeId;

  DetailsViewModel(this._repository, this.employeeId) : super(DetailsState.initial) {
    loadEmployee();
  }

  Employee? _employee;
  String? _errorMessage;

  // Getters
  Employee? get employee => _employee;
  DetailsState get currentState => state;
  String? get errorMessage => _errorMessage;
  bool get hasError => state == DetailsState.error;

  // Load employee by ID
  Future<void> loadEmployee() async {
    state = DetailsState.loading;
    try {
      _employee = await _repository.getEmployeeById(employeeId);
      if (_employee == null) {
        throw Exception('Employee not found');
      }
      state = DetailsState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      state = DetailsState.error;
    }
  }

  // Refresh employee data
  Future<void> refresh() async {
    await loadEmployee();
  }
}

// Providers
final detailsViewModelProvider = StateNotifierProvider.family<DetailsViewModel, DetailsState, int>((ref, employeeId) {
  // Use the shared repository provider
  final repository = ref.watch(employeeRepositoryProvider);
  return DetailsViewModel(repository, employeeId);
});

final employeeProvider = Provider.family<Employee?, int>((ref, employeeId) {
  final viewModel = ref.watch(detailsViewModelProvider(employeeId).notifier);
  return viewModel.employee;
});

final detailsErrorMessageProvider = Provider.family<String?, int>((ref, employeeId) {
  final viewModel = ref.watch(detailsViewModelProvider(employeeId).notifier);
  return viewModel.errorMessage;
});

final detailsHasErrorProvider = Provider.family<bool, int>((ref, employeeId) {
  final viewModel = ref.watch(detailsViewModelProvider(employeeId).notifier);
  return viewModel.hasError;
});