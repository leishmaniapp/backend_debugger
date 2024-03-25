import 'package:backend_debugger/proto/auth.pbserver.dart';
import 'package:fpdart/fpdart.dart';
import 'package:backend_debugger/errors/network/network_error.dart';

abstract interface class IAuthService {
  Future<Either<NetworkError, AuthResponse>> authenticate(
      Uri url, AuthRequest request);

  Map<String, dynamic> get authRequestSchema;
  Map<String, dynamic> get authResponseSchema;
}
