import 'package:backend_debugger/infrastructure/grpc/analysis_service.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/analysis_service.dart';
import 'package:fpdart/fpdart.dart';

class AnalysisProvider extends ProviderWithService<IAnalysisService> {
  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server) =>
      SupportedInfrastructure()
          .createServiceFromUri(
        server,
        grpcBuilder: (timeout, channel) =>
            GrpcAnalysisService(timeout, channel),
      )
          .fold(
              // Forward the error
              (l) => Option.of(l), (r) {
        // Store the server URI
        internalServerUri = server;
        // Store the new service
        service = r;
        return const Option.none();
      });
}
