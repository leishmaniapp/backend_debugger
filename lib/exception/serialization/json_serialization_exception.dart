part of '../exception.dart';

/// URI Scheme is invalid
final class JsonSerializationException extends SerializationException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  JsonSerializationException(Type type)
      : _what = "Failed to serialize value of type ($type)",
        super([JsonSerializationException]);
}
