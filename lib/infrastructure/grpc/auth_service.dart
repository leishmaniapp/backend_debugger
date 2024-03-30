import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/proto/auth.pbgrpc.dart';
import 'package:backend_debugger/services/auth_service.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grpc/grpc.dart';

class GrpcAuthService extends GrpcService<AuthServiceClient>
    implements IAuthService {
  /// Create the AuthService given the ClientChannel
  GrpcAuthService(Duration timeout, ClientChannel channel)
      : super(
          timeout,
          channel,
          AuthServiceClient(channel),
        );

  @override
  Future<Either<NetworkException, TokenString>> authenticate(
          String email, String password) async =>
      // Catch error into Either<Exception, Value>
      (await TaskEither.tryCatch(
                  // Call to authentication with timeout Future into Task
                  () => stub
                      .authenticate(
                          AuthRequest(email: email, password: password))
                      .timeout(timeout),
                  // Transform error into a NetworkException
                  (o, s) => RemoteServiceException(
                        // Catch the GrpcError and get its message as a RemoteServiceException
                        (o as GrpcError).message.toString(),
                      ) as NetworkException)
              // Unwrap the Task into a Future
              .run())
          // Transform the result into an Either<Error, Value> instead of AuthResponse
          .flatMap((r) => r.status
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Transform it to parent type for compatibility
              .map((t) => t as NetworkException)
              // Get either the error or the token
              .toEither(() => r.token)
              // Swap positions to put the error as Left
              .swap());
}
