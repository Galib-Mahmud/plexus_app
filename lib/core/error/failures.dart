abstract class Failure {
  final String message;
  const Failure(this.message);
}
class ServerFailure extends Failure { const ServerFailure(super.m); }
class NetworkFailure extends Failure { const NetworkFailure(super.m); }
class CacheFailure extends Failure { const CacheFailure(super.m); }
class AuthFailure extends Failure { const AuthFailure(super.m); }

class AppException implements Exception {
  final String message;
  const AppException(this.message);
}
class AuthException extends AppException { const AuthException(super.m); }
class CacheException extends AppException { const CacheException(super.m); }
