import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/auth_service.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/auth.pb.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/auth_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:screwdriver/screwdriver.dart';

class AuthProvider extends ProviderWithService<IAuthService> {
  AuthProvider([super._service]);

  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server) =>
      SupportedInfrastructure()
          .createServiceFromUri(
        server,
        grpcBuilder: (timeout, channel) => GrpcAuthService(timeout, channel),
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

  /// Check if user is authenticated
  bool get authenticated => (_authToken != null);

  TokenString? _authToken;

  /// Get the authencation token, null check exception when not authenticated
  TokenString get tokenString => _authToken!;

  /// Get the parsed authentication token, null check exception when not authenticated
  JWT get jwtToken => JWT.decode(tokenString);

  /// Get the JWT token payload contents
  Either<Exception, TokenPayload> get tokenPayload => Either.tryCatch(
      () => TokenPayload.create()..mergeFromProto3Json(jwtToken.payload),
      (_, __) => UnauthenticatedException());

  /// Get a specialist contained within a [TokenPayload]
  Either<Exception, Specialist> get specialist =>
      tokenPayload.map((a) => a.specialist);

  /// Authenticate in remote server
  Future<Option<CustomException>> authenticate(
    String email,
    String password,
  ) async =>
      (await service.authenticate(
        email,
        password,
      ))
          .match((l) => Option.of(l), (token) {
        // Store the token
        _authToken = token;
        notifyListeners();
        GetIt.I.get<Logger>().i("Authenticated with token ($token)");
        return const Option.none();
      });

  Future<Option<CustomException>> verifyToken() async => _authToken.isNull
      ? Option.of(UnauthenticatedException())
      : (await service.verifyToken(tokenString)).fold(() => const Option.none(),
          (t) {
          // Not authenticated, remove token
          forgetToken();
          return Option.of(t);
        });

  /// Erase the stored authentication token
  void forgetToken() {
    _authToken = null;
    notifyListeners();
  }

  /// Invalidate the current token
  Future<Option<CustomException>> invalidate() async => _authToken.isNull
      ? Option.of(UnauthenticatedException())
      : await service.invalidateSession(tokenString);
}
