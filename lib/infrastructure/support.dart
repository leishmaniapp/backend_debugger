import 'package:backend_debugger/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/auth_service.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/services/auth_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

/// Manipulate and create the supported infrastructre classes
class SupportedInfrastructure {
  // Create a singleton constructor and factory
  SupportedInfrastructure._();
  static final _singleton = SupportedInfrastructure._();
  factory SupportedInfrastructure() => _singleton;

  // List of supported infrastructure
  final supported = ['rpc', 'grpc'];

  Either<Exception, IAuthService> createAuthServiceFromUri(Uri server) =>
      switch (server.scheme) {
        // Create the Grpc service
        'rpc' ||
        'grpc' =>
          // Try to create the client channel
          Either.tryCatch(
            () => ClientChannel(
              server.host,
              port: server.port,
              options: GrpcService.defaultChannelOptions,
            ),
            (exception, _) => exception as Exception,
          )
              // From the channel create the service
              .map((channel) => GrpcAuthService(
                    GetIt.I.get<Duration>(instanceName: 'timeout'),
                    channel,
                  )),
        // None matched
        _ => Either.left(InvalidScheme(server.scheme, supported.toString())),
      };
}
