import 'package:backend_debugger/proto/auth.pb.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:backend_debugger/errors/network/network_error.dart';
import 'package:backend_debugger/services/interfaces/auth_service.dart';
import 'package:unixtime/unixtime.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider(this._authService);
  final IAuthService _authService;

  String? _token;
  String? get token => _token;

  // Check if an user is authenticated
  bool get authenticated => _token != null;

  // Authentication schema from proto
  String get authRequestSchema => _authService.authRequestSchema.toString();
  String get authResponseSchema => _authService.authResponseSchema.toString();

  // Parsed token
  JWT? get parsedToken => _token == null ? null : JWT.decode(_token!);

  TokenPayload? get tokenPayload => token != null
      ? (TokenPayload.create()..mergeFromProto3Json(parsedToken!.payload))
      : null;

  Duration? get remaining {
    // Check if token is present
    if (!authenticated) {
      return null;
    }

    // Get times
    final expiration = tokenPayload!.exp.toInt().toUnixTime();
    final now = DateTime.now();

    // Return the difference
    return expiration.difference(now);
  }

  Future<Option<NetworkError>> login(
      Uri url, String email, String password) async {
    switch (await _authService.authenticate(
        url, AuthRequest(email: email, password: password))) {
      // An error was returned
      case Left(value: final l):
        _token = null;
        notifyListeners();
        return Option.of(l);

      // A token was returned
      case Right(value: final res):
        _token = res.token;
        notifyListeners();
        return const Option.none();
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
