# XYZ Inc. Employee Management System

A comprehensive Flutter application for XYZ Inc. that automates employee productivity assessment, status determination, and salary management based on annual performance scores.

## 📋 Overview

This mobile application implements a complete employee management system with the following core functionalities:

- **Employee Listing**: Display employees fetched from API and stored locally
- **Advanced Filtering**: Search and filter employees by name, designation, and level
- **Productivity Assessment**: Automatic evaluation based on performance scores
- **Salary Management**: Dynamic salary calculation based on employee level and performance
- **Status Determination**: Automated promotion, demotion, or termination decisions

## 🎯 Assessment Requirements Implemented

### Core Features ✅
- **Employee Data Management**: Fetch from `Api.successResponse` and persist in local SQLite database
- **Filtering System**: Filter employees by name, designation, or level
- **Employee Details**: Comprehensive profile view with status determination
- **Salary Calculation**:
  - Level 0: ₦70,000
  - Level 1: ₦100,000
  - Level 2: ₦120,000
  - Level 3: ₦180,000
  - Level 4: ₦200,000
  - Level 5: ₦250,000
- **Error Simulation**: Built-in error response simulation from `Api.errorResponse`
- **Level 0 Protection**: Cannot be demoted, only terminated if performance is critically low

### Bonus Features ✅ (All Implemented)
- **Proper State Management**: Riverpod for reactive state management
- **Adaptive UI**: Beautiful responsive design with light/dark theme support
- **Widget Tests**: Comprehensive test suite covering all components
- **Declarative Navigation**: Go Router for type-safe navigation
- **Reusable Elements**: Modular widget architecture

## 🏗️ Architecture & Implementation

### Tech Stack
- **Framework**: Flutter 3.2.3+
- **Language**: Dart
- **State Management**: Riverpod 2.4.9
- **Navigation**: Go Router 13.0.0
- **Database**: SQLite (sqflite)
- **UI Responsiveness**: Flutter ScreenUtil
- **Theming**: Material Design 3 with custom adaptive themes

### Project Structure
```
lib/
├── common/
│   ├── models/employee.dart          # Employee model with business logic
│   ├── services/
│   │   ├── api_service.dart          # API integration
│   │   └── database_service.dart     # SQLite operations
│   ├── repositories/
│   │   └── employee_repository.dart  # Data access layer
│   ├── navigation/
│   │   └── app_router.dart           # Go Router configuration
│   └── theme/
│       └── app_theme.dart            # Adaptive theming
├── modules/
│   ├── home/
│   │   ├── presentation/
│   │   │   └── home_screen.dart      # Employee list screen
│   │   └── viewmodels/
│   │       └── home_viewmodel.dart   # Home screen state management
│   ├── details/
│   │   ├── presentation/
│   │   │   └── details_screen.dart   # Employee details screen
│   │   └── viewmodels/
│   │       └── details_viewmodel.dart # Details screen state management
│   └── widgets/                      # Reusable UI components
│       ├── employee_card.dart
│       ├── productivity_indicator.dart
│       ├── filter_widget.dart
│       ├── loading_error_widgets.dart
│       └── ...
├── root_widget.dart                  # App entry with providers
└── main.dart                         # Application bootstrap
```

### Architecture Pattern
**MVVM (Model-View-ViewModel)** with Repository pattern:

- **Models**: Data entities with business logic
- **ViewModels**: State management and UI logic
- **Views**: UI components (Screens & Widgets)
- **Repositories**: Data access abstraction
- **Services**: External integrations (API, Database)

### Productivity Scoring Logic

```dart
enum ProductivityResult {
  promotion,    // Score: 100-80
  noChange,     // Score: 79-50
  demotion,     // Score: 49-40
  termination   // Score: 39 and below
}
```

### Salary Calculation Algorithm

```dart
int get newSalary {
  // Base salary by level
  int baseSalary = getSalaryByLevel(level);

  // Apply productivity result
  switch (productivityResult) {
    case ProductivityResult.promotion:
      return getNextLevelSalary();
    case ProductivityResult.noChange:
      return baseSalary;
    case ProductivityResult.demotion:
      return level == 0 ? baseSalary : getPreviousLevelSalary();
    case ProductivityResult.termination:
      return 0;
  }
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.2.3+)
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code / Cursor IDE

### Installation

1. **Clone the repository**
   ```bash
   git clone [your-repository-url]
   cd marshall-infostrategy-accessment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Testing

Run the comprehensive test suite:
```bash
flutter test
```

## 📱 Feature Demonstration

### 1. Home Screen - Employee List
- **Initial Load**: Employees are fetched from API and stored locally
- **Search**: Type in the search bar to filter by employee name
- **Filters**: Use dropdowns to filter by designation and level
- **Pull to Refresh**: Swipe down to refresh data
- **Error Simulation**: Tap the bug icon to simulate API errors

### 2. Employee Details Screen
- **Tap any employee** from the home screen to view details
- **Productivity Assessment**: Visual indicator showing performance result
- **Salary Comparison**: Current vs. new salary calculation
- **Status Determination**: Employment status based on performance

### 3. Key Features to Test

#### Filtering Employees
1. **By Name**: Search "John" to find employees with "John" in their name
2. **By Designation**: Filter to show only "Tech" or "Legal" employees
3. **By Level**: Filter to show only Level 3 employees

#### Productivity Scoring
1. **High Performers**: Employees with score ≥80 get promoted
2. **Average Performers**: Scores 50-79 maintain current status
3. **Underperformers**: Scores 40-49 get demoted
4. **Critical Cases**: Scores <40 face termination

#### Special Rules
1. **Level 0 Protection**: Level 0 employees cannot be demoted
2. **Salary Progression**: Promotions increase salary to next level
3. **Demotion Impact**: Demotions decrease salary to previous level

#### Error Handling
1. **Network Error**: Tap bug icon to simulate API failure
2. **Offline Mode**: App works with cached data when API fails
3. **Retry Mechanism**: Error screens provide retry options

### 4. Theme Switching
The app automatically adapts to system theme (light/dark mode).

## 🔧 Technical Implementation Details

### State Management with Riverpod
```dart
// Providers for global state
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(...);
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return HomeViewModel(repository);
});
```

### Navigation with Go Router
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/employee/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailsScreen(employeeId: id);
      },
    ),
  ],
);
```

### Database Operations
- **CRUD Operations**: Full Create, Read, Update, Delete functionality
- **Search & Filter**: Efficient querying with WHERE clauses
- **Batch Operations**: Bulk insert for API data
- **Migration Support**: Version-based schema updates

### Responsive UI with ScreenUtil
```dart
// Adaptive sizing
Container(
  padding: EdgeInsets.all(16.w), // Responsive padding
  margin: EdgeInsets.symmetric(vertical: 8.h), // Responsive margin
  child: Text(
    'Employee Name',
    style: TextStyle(fontSize: 16.sp), // Responsive font size
  ),
)
```

## 🧪 Testing Strategy

### Test Coverage
- **Model Tests**: Employee business logic validation
- **Widget Tests**: UI component rendering and interactions
- **Integration Tests**: Screen navigation and state management
- **Business Logic Tests**: Productivity scoring and salary calculations

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test groups
flutter test --name="Employee Model Tests"
```

## 🎨 UI/UX Features

### Adaptive Design
- **Responsive Layout**: Works on phones, tablets, and web
- **Material Design 3**: Modern design system
- **Dark/Light Theme**: Automatic theme switching
- **Accessibility**: Proper contrast ratios and touch targets

### User Experience
- **Loading States**: Skeleton screens and progress indicators
- **Error Recovery**: User-friendly error messages with retry options
- **Smooth Animations**: Material transitions and micro-interactions
- **Offline Support**: Graceful degradation when network unavailable

## 📊 Data Flow

1. **API Fetch** → `ApiService.fetchEmployees()`
2. **Local Storage** → `DatabaseService.insertEmployees()`
3. **State Management** → `HomeViewModel.loadEmployees()`
4. **UI Rendering** → `HomeScreen` with Riverpod consumers
5. **User Interaction** → Navigation to `DetailsScreen`
6. **Business Logic** → Employee model calculations

## 🔍 Code Quality

### Best Practices Implemented
- **Clean Architecture**: Separation of concerns
- **Dependency Injection**: Provider-based DI
- **Error Handling**: Try-catch with user-friendly messages
- **Type Safety**: Full Dart type system utilization
- **Performance**: Efficient state updates and rendering
- **Maintainability**: Modular, documented, and testable code

### Code Organization
- **Consistent Naming**: Clear, descriptive identifiers
- **Documentation**: Comprehensive comments and docstrings
- **Modularity**: Single responsibility principle
- **Reusability**: Shared components and utilities

## 🚀 Deployment

### Build Commands
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

### Platform Support
- ✅ **Android**: Full support
- ✅ **iOS**: Full support
- ✅ **Web**: Responsive web version
- ✅ **Desktop**: Windows, macOS, Linux

## 📝 Assessment Completion

This implementation fully satisfies all assessment requirements:

- ✅ **Core Functionality**: Employee management with productivity assessment
- ✅ **Data Persistence**: Local database storage
- ✅ **Advanced Features**: Filtering, search, error handling
- ✅ **Business Logic**: Accurate salary and status calculations
- ✅ **Special Rules**: Level 0 employee protection
- ✅ **Bonus Requirements**: State management, adaptive UI, tests, navigation, reusability

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with proper tests
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is part of the Irecharge mobile team assessment.

---

**Built with ❤️ using Flutter**
