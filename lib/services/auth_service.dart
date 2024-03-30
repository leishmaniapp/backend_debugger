import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:fpdart/fpdart.dart';

typedef TokenString = String;

abstract interface class IAuthService {
  /// Authenticate user in the remote server, returns either an exception or a token
  FutureOr<Either<NetworkException, TokenString>> authenticate(
      String email, String password);
}
