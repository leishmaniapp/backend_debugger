import 'dart:async';
import 'dart:typed_data';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/proto/model.pbenum.dart';
import 'package:fpdart/fpdart.dart';

class ImageContents {
  final ByteData bytes;
  final String mime;
  final int size;

  const ImageContents({
    required this.bytes,
    required this.mime,
    required this.size,
  });
}

class SampleContents {
  final String uuid;
  final int sample;
  final String disease;
  final AnalysisStage stage;
  final String results;
  final DateTime date;

  const SampleContents({
    required this.uuid,
    required this.sample,
    required this.disease,
    required this.stage,
    required this.results,
    required this.date,
  });
}

abstract interface class ISampleService {
  /// Store an image and its sample metadata
  FutureOr<Option<CustomException>> storeImageSample(
      ImageContents image, SampleContents sample);

  /// Update already existing sample metadata
  FutureOr<Option<CustomException>> updateSample(SampleContents sample);

  /// Get a sample
  FutureOr<Either<CustomException, SampleContents>> getSample(
      String uuid, int sample);

  /// Delete a sample
  FutureOr<Either<CustomException, SampleContents>> deleteSample(
      String uuid, int sample);
}
