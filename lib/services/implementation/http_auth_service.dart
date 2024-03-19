import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:ws_debugger/errors/network/failed_connection_error.dart';
import 'package:ws_debugger/errors/network/http_error.dart';
import 'package:ws_debugger/errors/network/network_error.dart';
import 'package:ws_debugger/proto/auth.pb.dart';
import 'package:ws_debugger/services/interfaces/auth_service.dart';

import 'package:http/http.dart' as http;

final class HttpAuthService implements IAuthService {
  @override
  Map<String, Type> get authSchema =>
      (AuthRequest(username: "", password: "").toProto3Json()
              as Map<dynamic, dynamic>)
          .map((key, value) => MapEntry(key, value.runtimeType));

  @override
  Future<Either<NetworkError, TokenStr>> authenticate(
      Uri url, String username, String password) async {
    // Create a POST request
    try {
      // Creating request
      final request = AuthRequest(
        username: username,
        password: password,
      ).toProto3Json();

      // Send request
      final result = await http.post(url, body: request);

      // Parse response
      if (result.statusCode == HttpStatus.ok) {
        return Either.right(result.body);
      } else {
        return Either.left(HttpError(result.statusCode));
      }
    } on http.ClientException catch (e) {
      return Either.left(FailedConnectionError(e.uri.toString()));
    }
  }
}
