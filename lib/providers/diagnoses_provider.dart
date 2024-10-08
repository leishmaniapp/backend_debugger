import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/diagnoses_service.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/diagnoses_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grpc/grpc.dart';

class DiagnosesProvider extends ProviderWithService<IDiagnosesService> {
  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(
    Uri server, [
    String? authToken,
  ]) =>
      SupportedInfrastructure()
          .createServiceFromUri(
        server,
        grpcBuilder: (timeout, channel) => GrpcDiagnosesService(
          timeout,
          channel,
          authToken != null
              ? CallOptions(metadata: {"authorization": "Bearer $authToken"})
              : null,
        ),
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

  Future<Either<CustomException, Diagnosis>> getDiagnosis(String uuid) async =>
      await service.getDiagnosis(uuid);

  Future<Option<CustomException>> storeDiagnosis(Diagnosis diagnosis) async =>
      await service.storeDiagnosis(diagnosis);
}
