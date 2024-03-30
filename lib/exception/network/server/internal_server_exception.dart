part of '../../exception.dart';

final class InternalServerException extends RemoteServerException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InternalServerException([String what = "Remote server error"])
      : _what = what,
        super([InternalServerException]);
}
