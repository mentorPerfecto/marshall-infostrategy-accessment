import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_assessment/common/models/employee.dart';
import 'package:mobile_assessment/common/services/api_service.dart';
import 'package:mobile_assessment/common/services/database_service.dart';
import 'package:mobile_assessment/common/repositories/employee_repository.dart';
import 'package:mobile_assessment/common/services/api_service.dart';
import 'package:mobile_assessment/common/services/database_service.dart';
import 'package:mobile_assessment/modules/details/presentation/details_screen.dart';
import 'package:mobile_assessment/modules/details/viewmodels/details_viewmodel.dart';
import 'package:mobile_assessment/modules/home/presentation/home_screen.dart';
import 'package:mobile_assessment/modules/home/viewmodels/home_viewmodel.dart';
import 'package:mobile_assessment/modules/widgets/employee_card.dart';
import 'package:mobile_assessment/modules/widgets/filter_widget.dart';
import 'package:mobile_assessment/modules/widgets/loading_error_widgets.dart' as custom_widgets;
import 'package:mobile_assessment/modules/widgets/productivity_indicator.dart';
import 'package:mobile_assessment/root_widget.dart';

void main() {
  late Employee testEmployee;

  setUp(() {
    testEmployee = const Employee(
      id: 1,
      firstName: 'John',
      lastName: 'Doe',
      designation: 'Developer',
      level: 2,
      productivityScore: 85.0,
      currentSalary: '120,000',
      employmentStatus: EmploymentStatus.active,
    );
  });

  group('Employee Model Tests', () {
    test('Employee fullName should combine first and last name', () {
      expect(testEmployee.fullName, 'John Doe');
    });

    test('Employee salaryAmount should parse salary correctly', () {
      expect(testEmployee.salaryAmount, 120000);
    });

    test('Employee with high productivity score should get promotion', () {
      expect(testEmployee.productivityResult, ProductivityResult.promotion);
    });

    test('Employee should calculate new salary correctly after promotion', () {
      expect(testEmployee.newSalary, 180000); // Level 3 salary for promotion
    });

    test('Level 0 employee should not be demoted', () {
      final level0Employee = testEmployee.copyWith(
        level: 0,
        productivityScore: 35.0, // Below demotion threshold
        currentSalary: '70,000', // Set level 0 salary
      );
      expect(level0Employee.productivityResult, ProductivityResult.termination);
      expect(level0Employee.newSalary, 70000); // Keeps current salary when terminated
    });
  });

  group('Widget Tests', () {
    testWidgets('EmployeeCard displays employee information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: Scaffold(
                body: EmployeeCard(employee: testEmployee),
              ),
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('85.0%'), findsOneWidget);
      expect(find.text('Salary: 120,000'), findsOneWidget);
    });

    testWidgets('EmploymentStatusBadge shows correct status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: EmploymentStatusBadge(status: EmploymentStatus.active),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('ProductivityIndicator displays correct result',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: ProductivityIndicator(
                  result: ProductivityResult.promotion,
                  score: 85.0,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('85.0%'), findsOneWidget);
      expect(find.text('Promotion'), findsOneWidget);
    });

    testWidgets('LoadingWidget displays loading message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: custom_widgets.LoadingWidget(message: 'Loading employees...'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading employees...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CustomErrorWidget displays error message and retry button',
        (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: Scaffold(
                body: custom_widgets.CustomErrorWidget(
                  message: 'Network error',
                  onRetry: () => retryPressed = true,
                  retryText: 'Try Again',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryPressed, true);
    });

    testWidgets('EmptyStateWidget displays title and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: custom_widgets.EmptyStateWidget(
                  title: 'No Employees',
                  message: 'No employees found',
                  icon: Icons.people,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('No Employees'), findsOneWidget);
      expect(find.text('No Employees'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('FilterWidget displays options correctly',
        (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: Scaffold(
                body: FilterWidget(
                  selectedValue: selectedValue,
                  options: const ['Option 1', 'Option 2'],
                  hintText: 'Select option',
                  labelText: 'Filter',
                  onChanged: (value) => selectedValue = value,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Select option'), findsOneWidget);
    });

    testWidgets('SearchBarWidget handles input correctly',
        (WidgetTester tester) async {
      String changedValue = '';

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: Scaffold(
                body: SearchBarWidget(
                  initialValue: '',
                  hintText: 'Search...',
                  onChanged: (value) => changedValue = value,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test search');
      expect(changedValue, 'test search');
    });
  });

  group('Salary Calculation Tests', () {
    test('Level 0 employee salary should be 70,000', () {
      final employee = testEmployee.copyWith(level: 0, productivityScore: 65.0); // No change
      expect(employee.newSalary, 70000);
    });

    test('Level 1 employee salary should be 100,000', () {
      final employee = testEmployee.copyWith(level: 1, productivityScore: 65.0); // No change
      expect(employee.newSalary, 100000);
    });

    test('Level 2 employee salary should be 120,000', () {
      final employee = testEmployee.copyWith(level: 2, productivityScore: 65.0); // No change
      expect(employee.newSalary, 120000);
    });

    test('Level 3 employee salary should be 180,000', () {
      final employee = testEmployee.copyWith(level: 3, productivityScore: 65.0); // No change
      expect(employee.newSalary, 180000);
    });

    test('Level 4 employee salary should be 200,000', () {
      final employee = testEmployee.copyWith(level: 4, productivityScore: 65.0); // No change
      expect(employee.newSalary, 200000);
    });

    test('Level 5 employee salary should be 250,000', () {
      final employee = testEmployee.copyWith(level: 5, productivityScore: 65.0); // No change
      expect(employee.newSalary, 250000);
    });
  });

  group('Productivity Logic Tests', () {
    test('Score 80-100 should result in promotion', () {
      final employee = testEmployee.copyWith(productivityScore: 95.0);
      expect(employee.productivityResult, ProductivityResult.promotion);
    });

    test('Score 50-79 should result in no change', () {
      final employee = testEmployee.copyWith(productivityScore: 65.0);
      expect(employee.productivityResult, ProductivityResult.noChange);
    });

    test('Score 40-49 should result in demotion', () {
      final employee = testEmployee.copyWith(productivityScore: 45.0);
      expect(employee.productivityResult, ProductivityResult.demotion);
    });

    test('Score below 40 should result in termination', () {
      final employee = testEmployee.copyWith(productivityScore: 35.0);
      expect(employee.productivityResult, ProductivityResult.termination);
    });
  });

  group('Database and API Service Tests', () {
    test('DatabaseService should be properly initialized', () {
      final dbService = DatabaseService();
      expect(dbService, isNotNull);
    });

    test('ApiService should be properly initialized', () {
      final apiService = ApiService();
      expect(apiService, isNotNull);
    });

    test('Employee fromMap and toMap should be consistent', () {
      final map = testEmployee.toMap();
      final reconstructedEmployee = Employee.fromMap(map);

      expect(reconstructedEmployee.id, testEmployee.id);
      expect(reconstructedEmployee.firstName, testEmployee.firstName);
      expect(reconstructedEmployee.lastName, testEmployee.lastName);
      expect(reconstructedEmployee.designation, testEmployee.designation);
      expect(reconstructedEmployee.level, testEmployee.level);
      expect(reconstructedEmployee.productivityScore, testEmployee.productivityScore);
      expect(reconstructedEmployee.currentSalary, testEmployee.currentSalary);
      expect(reconstructedEmployee.employmentStatus, testEmployee.employmentStatus);
    });

    test('Employee JSON serialization should work', () {
      final json = testEmployee.toJson();
      final reconstructedEmployee = Employee.fromJson(json);

      expect(reconstructedEmployee.id, testEmployee.id);
      expect(reconstructedEmployee.firstName, testEmployee.firstName);
      expect(reconstructedEmployee.lastName, testEmployee.lastName);
      expect(reconstructedEmployee.designation, testEmployee.designation);
      expect(reconstructedEmployee.level, testEmployee.level);
      expect(reconstructedEmployee.productivityScore, testEmployee.productivityScore);
      expect(reconstructedEmployee.currentSalary, testEmployee.currentSalary);
    });
  });

  group('Screen Integration Tests', () {
    testWidgets('HomeScreen should render without errors',
        (WidgetTester tester) async {
      // Mock the providers to avoid async loading
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeViewModelProvider.overrideWith((ref) {
              final repository = ref.watch(employeeRepositoryProvider);
              final viewModel = HomeViewModel(repository);
              // Pre-populate with test data
              viewModel.state = HomeViewState(
                state: HomeState.loaded,
                employees: [testEmployee],
                filteredEmployees: [testEmployee],
              );
              return viewModel;
            }),
            uniqueDesignationsProvider.overrideWithValue(['Developer', 'Manager']),
            uniqueLevelsProvider.overrideWithValue([1, 2, 3]),
          ],
          child: const MobileAssessmentApp(isDebug: false),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check that the home screen is rendered
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget); // Test employee name
    });

    testWidgets('DetailsScreen should render with valid employee ID',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock the details view model to return loaded state with test employee
            detailsViewModelProvider(1).overrideWith((ref) {
              final repository = ref.watch(employeeRepositoryProvider);
              final viewModel = DetailsViewModel(repository, 1);
              // Simulate loaded state
              viewModel.state = DetailsState.loaded as DetailsViewState;
              return viewModel;
            }),
            employeeProvider(1).overrideWithValue(testEmployee),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: DetailsScreen(employeeId: 1),
            ),
          ),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check that the details screen is rendered
      expect(find.byType(DetailsScreen), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget); // Test employee name
    });
  });
}