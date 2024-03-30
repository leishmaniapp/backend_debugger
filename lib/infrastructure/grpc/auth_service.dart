import 'dart:async';

import 'package:backend_debugger/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/proto/auth.pbgrpc.dart';
import 'package:backend_debugger/services/auth_service.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grpc/grpc.dart';
import 'package:screwdriver/screwdriver.dart';

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
  //TODO: actual authentication method
  bool get authenticated => false;

  @override
  Future<Either<RemoteServerException, String>> authenticate(
          String email, String password) async =>
      (await stub
              .authenticate(AuthRequest(email: email, password: password))
              .timeout(timeout))
          .run((authResponse) => switch (authResponse.status.toException()) {
                None() => Either.of(authResponse.token),
                Some(value: final e) => Either.left(e as RemoteServerException),
              });
}
