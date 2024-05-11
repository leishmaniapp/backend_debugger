import 'package:backend_debugger/proto/analysis.pb.dart';

abstract interface class IAnalysisService {
  /// Start a streamed analysis between the client and the server
  Stream<AnalysisResponse> startAnalysis(
    Stream<AnalysisRequest> request,
    String from,
  );
}
