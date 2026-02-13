enum AuthProvider {
  google,
  email,
  unknown;

  static AuthProvider fromString(String provider) {
    switch (provider) {
      case 'google':
        return AuthProvider.google;
      case 'email':
        return AuthProvider.email;
      default:
        return AuthProvider.unknown;
    }
  }

  
}
