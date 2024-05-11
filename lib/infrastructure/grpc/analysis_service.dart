import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/proto/analysis.pbgrpc.dart';
import 'package:backend_debugger/services/analysis_service.dart';
import 'package:grpc/grpc.dart';

class GrpcAnalysisService extends GrpcService<AnalysisServiceClient>
    implements IAnalysisService {
  GrpcAnalysisService(
    Duration timeout,
    ClientChannel channel,
  ) : super(
          timeout,
          channel,
          AnalysisServiceClient(channel),
        );

  /// Start a gRPC streamed analysis
  @override
  Stream<AnalysisResponse> startAnalysis(
    Stream<AnalysisRequest> request,
    String from,
  ) =>
      stub.startAnalysis(
        request,
        options: CallOptions(
          metadata: {"from": from},
        ),
      );
}
