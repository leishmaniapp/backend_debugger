import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:fpdart/fpdart.dart';

typedef TokenString = String;

abstract interface class IAuthService {
  /// Authenticate user in the remote server, returns either an exception or a token
  FutureOr<Either<CustomException, TokenString>> authenticate(
      String email, String password);

  /// Check token authenticity and validity with the server
  /// Returns a [NetworkException] on network failure or subtype [AuthException] if token is invalid
  /// Returns [Option.none] if token is valid
  FutureOr<Option<CustomException>> verifyToken(TokenString token);

  /// Invalidate current token
  /// Returns a [NetworkException] on network failure
  /// Returns [Option.none] if token was invalidated
  FutureOr<Option<CustomException>> invalidateSession(TokenString token);
}
