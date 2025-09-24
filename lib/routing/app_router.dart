import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../widgets/main_layout.dart';
import '../services/api_service.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final isAuthenticated = await ApiService().isAuthenticated();
    final isLoginRoute = state.matchedLocation == '/login';
    
    // Para depuración
    print('Is authenticated: $isAuthenticated');
    print('Current route: ${state.matchedLocation}');
    print('Is login route: $isLoginRoute');

    // Si no está autenticado y no está en la página de login
    if (!isAuthenticated && !isLoginRoute) {
      print('Redirecting to login');
      return '/login';
    }

    // Si está autenticado y está en la página de login
    if (isAuthenticated && isLoginRoute) {
      print('Redirecting to dashboard');
      return '/dashboard';
    }

    // En cualquier otro caso, no redirigir
    print('No redirect needed');
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    ),
  ],
);