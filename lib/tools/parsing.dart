import 'dart:convert';

import 'package:backend_debugger/proto/types.pb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// Parse results JSON into proper [Map]
Map<String, ListOfCoordinates> parseSampleResults(String results) {
  final parsed = jsonDecode(results) as Map<String, dynamic>;
  GetIt.I.get<Logger>().t(parsed);

  return parsed.mapValue(
    (value) => ListOfCoordinates(
      coordinates: (value["coordinates"] as List<dynamic>).map<Coordinates>(
        (e) => Coordinates.create()..mergeFromProto3Json(e),
      ),
    ),
  );
}
