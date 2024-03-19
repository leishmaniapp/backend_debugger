import 'package:fpdart/fpdart.dart';
import 'package:ws_debugger/errors/network/network_error.dart';

typedef TokenStr = String;

abstract interface class IAuthService {
  Future<Either<NetworkError, TokenStr>> authenticate(
      Uri url, String username, String password);

  Map<String, Type> get authSchema;
}
