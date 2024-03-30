part of '../../../exception.dart';

final class InvalidCredentialsException extends AuthException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InvalidCredentialsException(
      [String what = "Invalid credentials were provided"])
      : _what = what,
        super([InvalidCredentialsException]);
}
