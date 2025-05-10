class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool userExists;
  final String? error;
  final dynamic user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userExists = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? userExists,
    String? error,
    dynamic user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userExists: userExists ?? this.userExists,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}
