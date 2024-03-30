import 'dart:async';

import 'package:backend_debugger/exception.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IAuthService {
  /// Check if an user is authenticated
  bool get authenticated;

  /// Authenticate user in the remote server, returns either an exception or a token
  FutureOr<Either<RemoteServerException, String>> authenticate(
      String email, String password);
}
