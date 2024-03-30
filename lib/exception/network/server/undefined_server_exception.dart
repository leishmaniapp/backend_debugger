part of '../../exception.dart';

final class UndefinedServerException extends RemoteServerException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  UndefinedServerException(String what)
      : _what = what,
        super([UndefinedServerException]);
}
