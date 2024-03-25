import 'dart:convert';
import 'dart:io';

import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/tools/types.dart';
import 'package:fpdart/fpdart.dart';
import 'package:backend_debugger/errors/network/failed_connection_error.dart';
import 'package:backend_debugger/errors/network/http_error.dart';
import 'package:backend_debugger/errors/network/network_error.dart';
import 'package:backend_debugger/proto/auth.pb.dart';
import 'package:backend_debugger/services/interfaces/auth_service.dart';

import 'package:http/http.dart' as http;

final class HttpAuthService implements IAuthService {
  @override
  Map<String, dynamic> get authRequestSchema =>
      valuesAsTypesInMap((AuthRequest(email: "", password: "").toProto3Json()
          as Map<String, dynamic>));

  @override
  Map<String, dynamic> get authResponseSchema =>
      valuesAsTypesInMap((AuthResponse(
              status:
                  StatusResponse(code: StatusCode.UNSPECIFIED, description: ""),
              token: "")
          .toProto3Json() as Map<String, dynamic>));

  @override
  Future<Either<NetworkError, AuthResponse>> authenticate(
      Uri url, AuthRequest request) async {
    // Create a POST request
    try {
      // Parse it to JSON
      final json = jsonEncode(request.toProto3Json());

      // Send request
      final result = await http.post(url, body: json);

      // Parse response
      if (result.statusCode == HttpStatus.ok) {
        return Either.right(AuthResponse.create()
          ..mergeFromProto3Json(jsonDecode(result.body)));
      } else {
        return Either.left(
          HttpError(
            result.statusCode,
            body: result.body.isEmpty ? null : result.body,
          ),
        );
      }
    } on http.ClientException catch (e) {
      return Either.left(FailedConnectionError(e.uri.toString()));
    }
  }
}
