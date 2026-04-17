import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

// Provider for the raw Firebase Auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService().authStateChanges;
});

// Provider for the specialized UserProfile
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return await AuthService().getUserProfile(user.uid);
});

// Controller for handling Auth actions (login, logout)
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _service;
  
  AuthController(this._service) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.signIn(email, password));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.signOut());
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(AuthService());
});
