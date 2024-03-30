part of '../exception.dart';

/// URI Scheme is invalid
final class RemoteServiceException extends NetworkException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  RemoteServiceException([String message = "Failed to reach remote service"])
      : _what = message,
        super([RemoteServiceException]);
}
