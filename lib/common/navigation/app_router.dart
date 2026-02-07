import 'package:go_router/go_router.dart';
import '../../modules/home/presentation/home_screen.dart';
import '../../modules/details/presentation/details_screen.dart';
import '../../common/constants.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.employeeDetailsRoute,
        builder: (context, state) {
          final employeeId = int.tryParse(state.pathParameters['id'] ?? '');
          if (employeeId == null) {
            // Handle invalid ID - redirect to home
            return const HomeScreen();
          }
          return DetailsScreen(employeeId: employeeId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      // Simple error page - could be made more sophisticated
      return const HomeScreen();
    },
  );
}