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
  Future<Either<CustomException, TokenString>> authenticate(
          String email, String password) async =>
      // Order of operation is the following
      // TaskEither<Exception, AuthResponse> -> Either<Exception, Either<Exception, String>> -> Either<Exception, String>
      (await TaskEither.tryCatch(
                  // Call to authentication with timeout Future into TetworkExceptionask
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
          .bind((r) => r.status
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Get either the error or the token
              .toEither(() => r.token)
              // Swap positions to put the error as Left
              .swap());

  @override
  FutureOr<Option<CustomException>> verifyToken(TokenString token) async =>
      // Order of operations is the following
      // TaskEither<Exception, StatusCode> -> Either<Exception, Option<Exception>> -> Either<Exception, Unit> -> Option<Exception>
      (await TaskEither.tryCatch(
                  () => stub.verifyToken(VerificationRequest(token: token)),
                  // Transform error into a NetworkException
                  (o, s) => (RemoteServiceException(
                        // Catch the GrpcError and get its message as a RemoteServiceException
                        (o as GrpcError).message.toString(),
                      ) as NetworkException))
              // Unwrap task into a future
              .run())
          // Transform the result into an Either<Error, Unit> instead of StatusCode
          .bind((r) => r
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Create Either to match parent type
              .toEither(() => unit)
              // Swap positions to put the error as Left
              .swap())
          // Put error (left) as value
          .swap()
          // Return the error if present
          .toOption();
}
