import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/employee.dart';
import '../../../common/repositories/employee_repository.dart';
import '../../../common/services/database_service.dart';
import '../../../common/services/api_service.dart';

enum HomeState {
  initial,
  loading,
  loaded,
  error,
}

class HomeViewState {
  final HomeState state;
  final List<Employee> employees;
  final List<Employee> filteredEmployees;
  final String? errorMessage;

  const HomeViewState({
    required this.state,
    required this.employees,
    required this.filteredEmployees,
    this.errorMessage,
  });

  HomeViewState copyWith({
    HomeState? state,
    List<Employee>? employees,
    List<Employee>? filteredEmployees,
    String? errorMessage,
  }) {
    return HomeViewState(
      state: state ?? this.state,
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeViewState> {
  final EmployeeRepository _repository;
  Timer? _searchDebounceTimer;

  HomeViewModel(this._repository) : super(const HomeViewState(
    state: HomeState.initial,
    employees: [],
    filteredEmployees: [],
  )) {
    // Don't call async methods in constructor
    // loadEmployees will be called when the provider is first read
  }

  String _searchQuery = '';
  String? _designationFilter;
  int? _levelFilter;

  // Getters
  List<Employee> get employees => state.filteredEmployees;
  HomeState get currentState => state.state;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state == HomeState.error;
  String get searchQuery => _searchQuery;
  String? get designationFilter => _designationFilter;
  int? get levelFilter => _levelFilter;

  // Load employees from API and save to database
  Future<void> loadEmployees({bool simulateError = false}) async {
    state = state.copyWith(state: HomeState.loading);
    try {
      final employees = await _repository.fetchAndSaveEmployees(simulateError: simulateError);
      final filteredEmployees = _applyFilters(employees, _searchQuery, _designationFilter, _levelFilter);
      state = HomeViewState(
        state: HomeState.loaded,
        employees: employees,
        filteredEmployees: filteredEmployees,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: HomeState.error,
        errorMessage: e.toString(),
      );
      // Try to load from cache if API fails
      try {
        final cachedEmployees = await _repository.getAllEmployees();
        final filteredEmployees = _applyFilters(cachedEmployees, _searchQuery, _designationFilter, _levelFilter);
        if (cachedEmployees.isNotEmpty) {
          state = HomeViewState(
            state: HomeState.loaded,
            employees: cachedEmployees,
            filteredEmployees: filteredEmployees,
            errorMessage: null,
          );
        }
      } catch (_) {
        // If cache also fails, stay in error state
      }
    }
  }

  // Search employees by name with debounce
  void searchEmployees(String query) {
    _searchQuery = query;

    // Cancel previous timer if it exists
    _searchDebounceTimer?.cancel();

    // Set up a new timer with 300ms delay
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      final filteredEmployees = _applyFilters(state.employees, _searchQuery, _designationFilter, _levelFilter);
      state = state.copyWith(filteredEmployees: filteredEmployees);
    });
  }

  // Filter by designation
  void filterByDesignation(String? designation) {
    _designationFilter = designation;
    final filteredEmployees = _applyFilters(state.employees, _searchQuery, _designationFilter, _levelFilter);
    state = state.copyWith(filteredEmployees: filteredEmployees);
  }

  // Filter by level
  void filterByLevel(int? level) {
    _levelFilter = level;
    final filteredEmployees = _applyFilters(state.employees, _searchQuery, _designationFilter, _levelFilter);
    state = state.copyWith(filteredEmployees: filteredEmployees);
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _designationFilter = null;
    _levelFilter = null;
    final filteredEmployees = _applyFilters(state.employees, _searchQuery, _designationFilter, _levelFilter);
    state = state.copyWith(filteredEmployees: filteredEmployees);
  }

  // Apply filters to employee list
  List<Employee> _applyFilters(List<Employee> employees, String searchQuery, String? designationFilter, int? levelFilter) {
    return employees.where((employee) {
      // Search filter (name)
      if (searchQuery.isNotEmpty) {
        final fullName = employee.fullName.toLowerCase();
        final query = searchQuery.toLowerCase();
        if (!fullName.contains(query)) {
          return false;
        }
      }

      // Designation filter - exact match
      if (designationFilter != null && designationFilter.isNotEmpty) {
        if (employee.designation.toLowerCase() != designationFilter.toLowerCase()) {
          return false;
        }
      }

      // Level filter
      if (levelFilter != null) {
        if (employee.level != levelFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }


  // Refresh data
  Future<void> refresh() async {
    await loadEmployees();
  }

  // Dispose method to clean up timers
  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  // Simulate error for testing
  Future<void> simulateError() async {
    await loadEmployees(simulateError: true);
  }
}

// Providers
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(
    databaseService: DatabaseService(),
    apiService: ApiService(),
  );
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  final viewModel = HomeViewModel(repository);

  // Start loading employees immediately
  Future.microtask(() => viewModel.loadEmployees());

  return viewModel;
});

// Additional providers for computed state
final employeesProvider = Provider<List<Employee>>((ref) {
  final viewState = ref.watch(homeViewModelProvider);
  return viewState.filteredEmployees;
});

final errorMessageProvider = Provider<String?>((ref) {
  final viewState = ref.watch(homeViewModelProvider);
  return viewState.errorMessage;
});

final hasErrorProvider = Provider<bool>((ref) {
  final viewState = ref.watch(homeViewModelProvider);
  return viewState.state == HomeState.error;
});

final uniqueDesignationsProvider = Provider<List<String>>((ref) {
  final viewState = ref.watch(homeViewModelProvider);
  // Only compute when employees are loaded
  if (viewState.state != HomeState.loaded || viewState.employees.isEmpty) {
    return [];
  }
  final designations = viewState.employees
      .map((e) => e.designation)
      .toSet()
      .toList()
    ..sort();
  return designations;
});

final uniqueLevelsProvider = Provider<List<int>>((ref) {
  final viewState = ref.watch(homeViewModelProvider);
  // Only compute when employees are loaded
  if (viewState.state != HomeState.loaded || viewState.employees.isEmpty) {
    return [];
  }
  final levels = viewState.employees
      .map((e) => e.level)
      .toSet()
      .toList()
    ..sort();
  return levels;
});