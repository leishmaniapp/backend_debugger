import 'dart:async';
import 'dart:typed_data';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/model.pbenum.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:fpdart/fpdart.dart';

class SampleProvider extends ProviderWithService<ISampleService> {
  SampleProvider([super.service]);

  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server) =>
      SupportedInfrastructure().createSampleServiceFromUri(server).fold(
          // Forward the error
          (l) => Option.of(l), (r) {
        // Store the new service
        service = r;
        return const Option.none();
      });

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
  ) {
    return service.uploadImageSample(diagnosisUuid, sample, disease, stage,
        results, date, sampleBytes, sampleSize, sampleMime);
  }
}
