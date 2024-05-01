import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/diagnoses_service.dart';
import 'package:fpdart/fpdart.dart';

class DiagnosesProvider extends ProviderWithService<IDiagnosesService> {
  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server) {
    // TODO: implement requestServiceFromInfrastructureWithUri
    throw UnimplementedError();
  }
}
