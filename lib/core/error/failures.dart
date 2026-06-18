// Exceptions thrown by data sources
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  @override
  String toString() => message;
}

// Thrown when location permission is denied permanently (the OS will no
// longer show the system prompt), so recovery requires opening app settings.
class PermissionPermanentlyDeniedException implements Exception {
  final String message;
  const PermissionPermanentlyDeniedException(this.message);
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

// Typed failures returned by repositories via Result<T>
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

class CacheFailure extends AppFailure {
  const CacheFailure(super.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}
