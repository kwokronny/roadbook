// lib/shared/providers/auth_state_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthState {
  const AuthState({this.token, this.user});
  final String? token;
  final User? user;
  bool get isAuthenticated => token != null;
}

class AuthStateNotifier extends AsyncNotifier<AuthState> {
  static const _tokenKey = 'auth_token';
  static const _userKey  = 'auth_user';

  @override
  Future<AuthState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) return const AuthState();
    final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    return AuthState(token: token, user: user);
  }

  Future<void> login(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = AsyncData(AuthState(token: token, user: user));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    state = const AsyncData(AuthState());
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);
