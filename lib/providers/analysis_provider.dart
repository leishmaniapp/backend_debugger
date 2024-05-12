import 'dart:async';

import 'package:backend_debugger/infrastructure/grpc/analysis_service.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/analysis.pb.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/analysis_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

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

  /// Send the requests
  StreamController<AnalysisRequest> _requestController = StreamController();

  /// Gather the results
  StreamSubscription<AnalysisResponse>? _responseSubscription;

  // Gather all the responses
  List<AnalysisResponse> responses = [];

  /// Send the new request to the remote service
  void sendRequest(AnalysisRequest request) {
    GetIt.I.get<Logger>().i(
          "Sent new request with size (${request.image.data.length ~/ 1024}) KiB\n"
          "${request.metadata}",
        );
    _requestController.add(request);
  }

  /// Currently listening for reponses
  bool get listening => _responseSubscription != null;

  // Start listening for reponses
  void startListening(String from) {
    // If no analysis response
    _responseSubscription ??= service
        .startAnalysis(
      _requestController.stream,
      from,
    )
        .listen((event) {
      GetIt.I.get<Logger>().i("Response arrived ($event)");
      // Add response to the list of responses
      responses.add(event);

      // Notify children
      notifyListeners();
    });
  }

  @override
  void onInit() {
    // Recreate the stream controller
    _requestController = StreamController();
  }

  @override
  void onDispose() {
    // Cancel subscription
    _responseSubscription?.cancel();
    _responseSubscription = null;
    // Close the old stream
    _requestController.close();
  }
}
