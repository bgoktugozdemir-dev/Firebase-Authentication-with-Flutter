class AuthenticationException implements Exception {
  const AuthenticationException({required this.message});

  final String message;
}
