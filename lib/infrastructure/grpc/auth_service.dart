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
  /// Create the [IAuthService] given the [ClientChannel]
  GrpcAuthService(
    Duration timeout,
    ClientChannel channel, [
    CallOptions? options,
  ]) : super(
          timeout,
          channel,
          AuthServiceClient(channel),
          options,
        );

  @override
  Future<Either<CustomException, TokenString>> authenticate(
          String email, String password) =>
      // Order of operation is the following
      // TaskEither<Exception, AuthResponse> -> Either<Exception, Either<Exception, String>> -> Either<Exception, String>
      TaskEither.tryCatch(
              // Call to authentication with timeout Future into TetworkExceptionask
              () => stub
                  .authenticate(
                    AuthRequest(email: email, password: password),
                    options: super.options,
                  )
                  .timeout(timeout),
              // Transform error into a NetworkException
              (o, s) => RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o is GrpcError)
                        ? (o).message.toString()
                        : (o as Exception).toString(),
                  ) as NetworkException)
          // Transform the result into an Either<Error, Value> instead of AuthResponse
          .chainEither((r) => r.status
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Get either the error or the token
              .toEither(() => r.token)
              // Swap positions to put the error as Left
              .swap())
          .run();

  @override
  Future<Option<CustomException>> verifyToken(TokenString token) =>
      // Order of operations is the following
      // TaskEither<Exception, StatusCode> -> Either<Exception, Option<Exception>> -> Either<Exception, Unit> -> Option<Exception>
      TaskEither.tryCatch(
              () => stub.verifyToken(
                    TokenRequest(token: token),
                    options: super.options,
                  ),
              // Transform error into a NetworkException
              (o, s) => (RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o is GrpcError)
                        ? (o).message.toString()
                        : (o as Exception).toString(),
                  ) as NetworkException))

          // Transform the result into an Either<Error, Unit> instead of StatusCode
          .chainEither((r) => r
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Create Either to match parent type
              .toEither(() => unit)
              // Swap positions to put the error as Left
              .swap())
          // Put error (left) as value
          .swap()
          // Wrap into an option
          .match<Option<CustomException>>(
              (l) => const Option.none(), (r) => Option.of(r))
          .run();

  @override
  Future<Option<CustomException>> invalidateSession(TokenString token) =>
      // Order of operations is the following
      // TaskEither<Exception, StatusCode> -> Either<Exception, Option<Exception>> -> Either<Exception, Unit> -> Option<Exception>
      TaskEither.tryCatch(
              () => stub.invalidateSession(
                    TokenRequest(token: token),
                    options: super.options,
                  ),
              // Transform error into a NetworkException
              (o, s) => (RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o is GrpcError)
                        ? (o).message.toString()
                        : (o as Exception).toString(),
                  ) as NetworkException))

          // Transform the result into an Either<Error, Unit> instead of StatusCode
          .chainEither((r) => r
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Create Either to match parent type
              .toEither(() => unit)
              // Swap positions to put the error as Left
              .swap())
          // Put error (left) as value
          .swap()
          // Wrap into an option
          .match<Option<CustomException>>(
              (l) => const Option.none(), (r) => Option.of(r))
          .run();
}
