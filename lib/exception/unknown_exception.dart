part of 'exception.dart';

/// Unknown exception
final class UnknownException extends CustomException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  UnknownException(String what)
      : _what = what,
        super([UnknownException]);
}
