import 'dart:async';
import 'dart:typed_data';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ISampleService {
  /// Store an image and its sample metadata
  FutureOr<Option<CustomException>> storeImageSample({
    required ByteData imageBytes,
    required String imageMimeType,
    required Sample sample,
  });

  /// Update already existing sample metadata
  FutureOr<Option<CustomException>> updateSample(Sample sample);

  /// Get a sample
  FutureOr<Either<CustomException, Sample>> getSample(String uuid, int sample);

  /// Delete a sample
  FutureOr<Either<CustomException, Sample>> deleteSample(
      String uuid, int sample);

  /// Get undelivered samples (DELIVER or ERROR_DELIVER stage)
  FutureOr<Either<CustomException, List<Sample>>> getUndeliveredSamples(
      String email);
}
