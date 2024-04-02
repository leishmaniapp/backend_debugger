import 'dart:async';
import 'dart:typed_data';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/proto/model.pbenum.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ISampleService {
  FutureOr<Option<CustomException>> uploadImageSample(
    String diagnosisUuid,
    int sample,
    String disease,
    AnalysisStage stage,
    String results,
    DateTime date,
    ByteData sampleBytes,
    int sampleSize,
    String sampleMime,
  );
}
