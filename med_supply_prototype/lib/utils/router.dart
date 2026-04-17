import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../models/user_profile.dart';
import '../views/login_screen.dart';

// Screens will be fully implemented in Steps 7 & 11
// Adding placeholder widgets for now to allow routing logic development
import '../views/facility_dashboard_screen.dart';
import '../views/cms_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileState = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/login',
    
    // Redirect logic: The heart of MedSupply's Auth Gate
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) return isLoggingIn ? null : '/login';

      // If logged in, wait for the profile to decide where to go
      if (profileState.value == null) return null;

      final role = profileState.value!.role;
      
      // Prevent users from going back to login if they are authenticated
      if (isLoggingIn) {
        return role == UserRole.cmsAdmin ? '/cms' : '/dashboard';
      }

      return null;
    },
    
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const FacilityDashboardScreen(),
      ),
      GoRoute(
        path: '/cms',
        builder: (context, state) => const CMSDashboardScreen(),
      ),
    ],
  );
});
