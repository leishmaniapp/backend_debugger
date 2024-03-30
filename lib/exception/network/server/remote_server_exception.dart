part of '../../exception.dart';

/// An exception ocurred in a remote server
sealed class RemoteServerException extends NetworkException {
  RemoteServerException(ExceptionStack children)
      : super([RemoteServerException, ...children]);
}
