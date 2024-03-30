part of '../../../exception.dart';

/// Remote authentication failed for server
sealed class AuthException extends RemoteServerException {
  AuthException(ExceptionStack children) : super([AuthException, ...children]);
}
