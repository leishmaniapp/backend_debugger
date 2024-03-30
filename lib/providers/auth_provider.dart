import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/auth_service.dart';
import 'package:fpdart/fpdart.dart';

class AuthProvider extends ProviderWithService<IAuthService> {
  AuthProvider({IAuthService? service}) : super(service);

  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server) =>
      SupportedInfrastructure().createAuthServiceFromUri(server).fold(
          // Forward the error
          (l) => Option.of(l), (r) {
        // Store the new service
        service = r;
        return const Option.none();
      });
}
