import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );

    if (result.success) {
      _user = result.user;
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _setError(result.message ?? 'Sign up failed');
      _setLoading(false);
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.success) {
      _user = result.user;
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _setError(result.message ?? 'Sign in failed');
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _clearError();
    notifyListeners();
    _setLoading(false);
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.updateUserProfile(
      name: name,
      phone: phone,
      profileImageUrl: profileImageUrl,
    );

    if (result.success) {
      // Refresh user data
      _user = await _authService.getCurrentUserData();
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _setError(result.message ?? 'Profile update failed');
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.resetPassword(email);

    _setLoading(false);
    if (result.success) {
      return true;
    } else {
      _setError(result.message ?? 'Password reset failed');
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithGoogle();

    if (result.success) {
      _user = result.user;
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _setError(result.message ?? 'Google sign in failed');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
