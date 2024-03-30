part of 'exception.dart';

typedef ExceptionStack = List<Type>;

/// Stores and prints all the exception inheritance stack
abstract mixin class PrintsExceptionStack {
  ExceptionStack get exceptionStack;

  String printExceptionStack() =>
      // ignore: prefer_interpolation_to_compose_strings
      "Exception ocurred, showing exception stack:\n" +
      exceptionStack
          .mapIndexed((index, element) =>
              '${' ' * index}${index == 0 ? '>' : ' └'} $element')
          .reduce((value, element) => '$value\n$element');
}
