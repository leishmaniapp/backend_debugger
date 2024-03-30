part of 'exception.dart';

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
