import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ws_debugger/errors/network/network_error.dart';
import 'package:ws_debugger/services/interfaces/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider(this._authService);
  final IAuthService _authService;

  String? _token;
  String? get token => _token;

  // Check if an user is authenticated
  bool get authenticated => _token != null;

  String get authSchema => _authService.authSchema.toString();

  Future<Option<NetworkError>> login(
      Uri url, String username, String password) async {
    switch (await _authService.authenticate(url, username, password)) {
      // An error was returned
      case Left(value: final l):
        _token = null;
        notifyListeners();
        return Option.of(l);

      // A token was returned
      case Right(value: final tkn):
        _token = tkn;
        notifyListeners();
        return const Option.none();
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
