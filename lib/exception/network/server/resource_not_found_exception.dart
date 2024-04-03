part of '../../exception.dart';

final class ResourceNotFoundException extends RemoteServerException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  ResourceNotFoundException([String? resource])
      : _what =
            "The given resource (${resource ?? "'¯\\_(ツ )_/¯'"}) was not found on the server",
        super([ResourceNotFoundException]);
}
