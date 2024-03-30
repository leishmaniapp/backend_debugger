part of '../../../exception.dart';

final class InvalidTokenException extends AuthException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InvalidTokenException(
      [String what = "Provided token was not accepted by the server"])
      : _what = what,
        super([InvalidTokenException]);
}
