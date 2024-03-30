import 'package:screwdriver/screwdriver.dart';

/// Stores and prints all the exception inheritance stack
abstract mixin class PrintsExceptionStack {
  List<Type> get exceptionStack;

  String printExceptionStack() =>
      // ignore: prefer_interpolation_to_compose_strings
      "Exception ocurred, showing exception stack:\n" +
      exceptionStack
          .mapIndexed((index, element) =>
              '${' ' * index}${index == 0 ? '>' : ' └'} $element')
          .reduce((value, element) => '$value\n$element');
}

/// Exception must have a cause
abstract interface class HasCause {
  String get cause;
}

/// Mixin to print the exception stack with cause
mixin PrintsExceptionCauseWithStack on HasCause, PrintsExceptionStack {
  String printExceptionCause() => "${printExceptionStack()}\nCause: $cause";

  @override
  String toString() => printExceptionCause();
}

/// Custom type of exception only for the application to use
sealed class CustomException
    with PrintsExceptionStack
    implements Exception, HasCause {
  /// Get the cause of the [Exception]
  List<Type> children;
  CustomException(List<Type> children)
      : children = [
          CustomException,
          ...children,
        ];

  @override
  List<Type> get exceptionStack => children;
}

/// An exception ocurred while networking
sealed class NetworkException extends CustomException {
  NetworkException(List<Type> children)
      : super([NetworkException, ...children]);
}

final class InvalidScheme extends NetworkException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InvalidScheme(String actual, String expected)
      : _what = "Unexpected scheme ($actual), expected ($expected)",
        super([InvalidScheme]);
}

/// An exception ocurred in a remote server
sealed class RemoteServerException extends NetworkException {
  RemoteServerException(List<Type> children)
      : super([RemoteServerException, ...children]);
}

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

final class InternalServerError extends RemoteServerException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InternalServerError([String what = "Remote server error"])
      : _what = what,
        super([InternalServerError]);
}

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

/// Remote authentication failed for server
sealed class RemoteAuthException extends RemoteServerException {
  RemoteAuthException(List<Type> children)
      : super([RemoteAuthException, ...children]);
}

final class InvalidCredentialsException extends RemoteAuthException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InvalidCredentialsException(
      [String what = "Invalid credentials were provided"])
      : _what = what,
        super([InvalidCredentialsException]);
}

final class InvalidTokenException extends RemoteAuthException
    with PrintsExceptionCauseWithStack {
  // Store the cause of the exception
  final String _what;

  @override
  String get cause => _what;

  InvalidTokenException(
      [String what = "Provided token was not accepted by the server"])
      : _what = what,
        super([InvalidTokenException]);
}
