import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:fpdart/fpdart.dart';

/// Upload and request diagnoses from the remote database
abstract interface class IDiagnosesService {
  /// Store a new [Diagnosis] in the remote database
  FutureOr<Option<CustomException>> storeDiagnosis(Diagnosis diagnosis);

  /// Get a [Diagnosis] given its id
  FutureOr<Either<CustomException, Diagnosis>> getDiagnosis(String uuid);
}
