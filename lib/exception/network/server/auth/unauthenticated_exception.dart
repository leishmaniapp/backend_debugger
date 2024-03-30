part of '../../../exception.dart';

final class UnauthenticatedException extends AuthException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  UnauthenticatedException()
      : _what = "User not authenticated",
        super([UnauthenticatedException]);
}
