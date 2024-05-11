import 'package:backend_debugger/infrastructure/support.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

abstract class ProviderWithService<S> with ChangeNotifier {
  ProviderWithService([this._service]);

  /// Check if the provided service is enabled (is not null)
  bool get hasService => _service != null;

  S? _service;
  // Replace old service with new service
  set service(S? service) {
    GetIt.I.get<Logger>().i(
        "Replaced '$runtimeType' service ($S) with '${service.runtimeType}'");

    _service = service;
    // Call either init or destroy
    (service == null) ? onDispose() : onInit();
    notifyListeners();
  }

  /// Override for initial behaviour
  void onInit() {}

  /// Override for final behaviour
  void onDispose() {}

  /// Disconnect from remote server
  void disconnect() => (service = null);

  /// Get the non-null service
  @protected
  S get service => _service!;

  /// Request the service to [SupportedInfrastructure]
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server);

  /// Stored server [Uri]
  @protected
  Uri? internalServerUri;

  /// Get the server connection URI, uri is set via [requestServiceFromInfrastructureWithUri]
  get serverUri => internalServerUri;

  @override
  String toString() => "Connected to server ($serverUri)";
}
