class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException()
      : super(
          'Failed to connect to server. Please check your internet connection and try again.',
        );
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Incorrect email or password. Please try again.');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('An account with this email already exists. Try signing in.');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('No account found with this email address.');
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super('Your session has expired. Please sign in again.');
}

class AuthServerException extends AuthException {
  final int? statusCode;
  const AuthServerException({String message = 'Server error.', this.statusCode})
      : super(message);
}

class DuplicateEmailException extends AuthException {
  const DuplicateEmailException()
      : super('An account with this email already exists.');
}
