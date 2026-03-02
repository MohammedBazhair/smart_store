sealed class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthGoogleLoadingState extends AuthState {
  const AuthGoogleLoadingState();
}

class AuthSuccessfullState extends AuthState {
  const AuthSuccessfullState();
}

class AuthSignOutState extends AuthState {
  const AuthSignOutState();
}

class AuthResetPasswordSuccessfullState extends AuthState {
  const AuthResetPasswordSuccessfullState(this.email);
  final String email;
}

class AuthPasswordChangedSuccessfullState extends AuthState {
  const AuthPasswordChangedSuccessfullState();
}

class AuthFailedState extends AuthState {
  AuthFailedState(this.message);
  final String message;
}
