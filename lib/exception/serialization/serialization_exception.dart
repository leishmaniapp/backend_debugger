part of "../exception.dart";

/// An exception ocurred while serializing data
sealed class SerializationException extends CustomException {
  SerializationException(ExceptionStack children)
      : super([SerializationException, ...children]);
}
