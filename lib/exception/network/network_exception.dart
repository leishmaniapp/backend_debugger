part of '../exception.dart';

/// An exception ocurred while networking
sealed class NetworkException extends CustomException {
  NetworkException(ExceptionStack children)
      : super([NetworkException, ...children]);
}
