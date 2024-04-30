part of '../../exception.dart';

final class UnprocessableContentException extends RemoteServerException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  UnprocessableContentException(String what)
      : _what = what,
        super([UnprocessableContentException]);
}
