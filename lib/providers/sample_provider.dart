import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/model.pbenum.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:backend_debugger/tools/assets.dart';
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

  /// Store an image and its sample metadata
  Future<Option<CustomException>> storeImageSample(
          String asset,
          String uuid,
          int sample,
          String disease,
          AnalysisStage stage,
          String results) async =>
      service.storeImageSample(
          ImageContents(
              bytes: (await AssetsTool().loadBytes(asset)).asByteData(),
              mime: "image/jpeg",
              size: 500),
          SampleContents(
              uuid: uuid,
              sample: sample,
              disease: disease,
              stage: stage,
              results: results,
              date: DateTime.now()));

  /// Update already existing sample metadata
  Future<Option<CustomException>> updateSample(
          String uuid,
          int sample,
          String disease,
          AnalysisStage stage,
          String results,
          DateTime date) async =>
      service.updateSample(SampleContents(
          uuid: uuid,
          sample: sample,
          disease: disease,
          stage: stage,
          results: results,
          date: date));

  /// Get a sample
  Future<Either<CustomException, Object>> getSample(
          String uuid, int sample) async =>
      service.getSample(uuid, sample);

  /// Delete a sample
  Future<Either<CustomException, Object>> deleteSample(
          String uuid, int sample) async =>
      service.deleteSample(uuid, sample);
}
