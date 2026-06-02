import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => user != null;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiService = ref.read(apiServiceProvider);
      // Şimdilik username'i kullanarak login mockluyoruz.
      final user = await apiService.login(username);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void logout() {
    state = AuthState(); // Reset
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
