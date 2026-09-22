class ScanException implements Exception {
  final String message;
  const ScanException({required this.message});

  @override
  String toString() => 'ScanException: $message';
}

class NetworkException extends ScanException {
  const NetworkException({required super.message});
}

class ServerException extends ScanException {
  final int? statusCode;
  const ServerException({required super.message, this.statusCode});
}

class PermissionException extends ScanException {
  const PermissionException({required super.message});
}
