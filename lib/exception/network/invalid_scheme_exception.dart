part of '../exception.dart';

/// URI Scheme is invalid
final class InvalidSchemeException extends NetworkException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InvalidSchemeException(String actual, String expected)
      : _what = "Unexpected scheme ($actual), expected ($expected)",
        super([InvalidSchemeException]);
}
