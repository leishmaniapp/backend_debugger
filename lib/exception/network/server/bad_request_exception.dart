part of '../../exception.dart';

final class BadRequestException extends RemoteServerException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  BadRequestException(
      [String what = "Request to the server was in a bad state"])
      : _what = what,
        super([BadRequestException]);
}
