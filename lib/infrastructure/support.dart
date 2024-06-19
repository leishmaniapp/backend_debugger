import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:screwdriver/screwdriver.dart';

/// Manipulate and create the supported infrastructre classes
class SupportedInfrastructure {
  // Create a singleton constructor and factory
  SupportedInfrastructure._();
  static final _singleton = SupportedInfrastructure._();
  factory SupportedInfrastructure() => _singleton;

  /// List of supported infrastructure
  final supported = ['rpc', 'grpc'];

  /// Create a service given its URL scheme
  Either<Exception, S> createServiceFromUri<S, Gs extends S>(
    Uri server, {
    /// Builder for [GrpcService] type services
    required Gs Function(
      Duration timeout,
      ClientChannel channel,
    ) grpcBuilder,
  }) =>
      server.run((server) {
        GetIt.I.get<Logger>().d("Server Properties: ${{
              "scheme": server.scheme,
              "host": server.host,
              "port": server.port,
              "path": server.path,
            }}");

        return switch (server.scheme) {
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
                .map((channel) => grpcBuilder(
                      GetIt.I.get<Duration>(instanceName: 'timeout'),
                      channel,
                    )),

          // None matched
          _ => Either.left(
              InvalidSchemeException(
                server.scheme,
                supported.toString(),
              ),
            ),
        };
      });
}
