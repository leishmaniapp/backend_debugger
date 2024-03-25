import 'package:fpdart/fpdart.dart';

Map<String, dynamic> valuesAsTypesInMap(Map<String, dynamic> type) =>
    type.mapValue((value) => (value is Map)
        // Recursive call to itself
        ? valuesAsTypesInMap(value as Map<String, dynamic>)
        // As type
        : value.runtimeType);
