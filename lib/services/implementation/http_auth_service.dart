import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:backend_debugger/errors/network/failed_connection_error.dart';
import 'package:backend_debugger/errors/network/http_error.dart';
import 'package:backend_debugger/errors/network/network_error.dart';
import 'package:backend_debugger/proto/auth.pb.dart';
import 'package:backend_debugger/services/interfaces/auth_service.dart';

import 'package:http/http.dart' as http;

final class HttpAuthService implements IAuthService {
  @override
  Map<String, Type> get authSchema =>
      (AuthRequest(email: "", password: "").toProto3Json()
              as Map<dynamic, dynamic>)
          .map((key, value) => MapEntry(key, value.runtimeType));

  @override
  Future<Either<NetworkError, TokenStr>> authenticate(
      Uri url, String email, String password) async {
    // Create a POST request
    try {
      // Creating request
      final request = AuthRequest(
        email: email,
        password: password,
      ).toProto3Json();

      // Parse it to JSON
      final json = jsonEncode(request);

      // Send request
      final result = await http.post(url, body: json);

      // Parse response
      if (result.statusCode == HttpStatus.ok) {
        return Either.right(result.body);
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
