import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/proto/diagnoses.pbgrpc.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/services/diagnoses_service.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grpc/grpc.dart';

/// gRPC implementation of the [IDiagnosesService]
class GrpcDiagnosesService extends GrpcService<DiagnosesServiceClient>
    implements IDiagnosesService {
  /// Create the [IDiagnosesService] given a [ClientChannel]
  GrpcDiagnosesService(
    Duration timeout,
    ClientChannel channel,
  ) : super(
          timeout,
          channel,
          DiagnosesServiceClient(channel),
        );

  @override
  Future<Either<CustomException, Diagnosis>> getDiagnosis(String uuid) =>
      TaskEither.tryCatch(
              () => stub.getDiagnosis(DiagnosisRequest(uuid: uuid)),
              (o, s) =>
                  RemoteServiceException((o as GrpcError).message.toString())
                      as NetworkException)
          .chainEither((r) => r.status
              .toException()
              .toEither(
                () => r.diagnosis,
              )
              .swap())
          .run();

  @override
  Future<Option<CustomException>> storeDiagnosis(Diagnosis diagnosis) =>
      TaskEither.tryCatch(
              () => stub.storeDiagnosis(diagnosis),
              (o, s) =>
                  RemoteServiceException((o as GrpcError).message.toString())
                      as NetworkException)
          .chainEither((r) => r
              .toException()
              .toEither(
                () => unit,
              )
              .swap())
          .match<Option<CustomException>>(
            (l) => Option.of(l),
            (r) => const Option.none(),
          )
          .run();
}
