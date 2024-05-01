import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/samples_service.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:backend_debugger/tools/assets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class SamplesProvider extends ProviderWithService<ISampleService> {
  SamplesProvider([super.service]);

  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(Uri server) =>
      SupportedInfrastructure()
          .createServiceFromUri(
        server,
        grpcBuilder: (timeout, channel) => GrpcSampleService(timeout, channel),
      )
          .fold((l) => Option.of(l), (r) {
        // Store the server URI
        internalServerUri = server;
        // Store the new service
        service = r;
        return const Option.none();
      });

  /// Store an image and its sample metadata
  Future<Option<CustomException>> storeImageSample(
      String asset, Sample request) async {
    try {
      // Get image data in bytes
      final imageBytes = (await AssetsTool().loadBytes(asset)).asByteData();

      GetIt.I.get<Logger>().t(
            "Uploading (${request.runtimeType}), ${request.toString()} with (${imageBytes.lengthInBytes}) bytes of image data",
          );

      return service.storeImageSample(
        imageBytes: imageBytes,
        imageMimeType: "image/jpeg",
        sample: request,
      );
    } catch (e) {
      GetIt.I.get<Logger>().e(
            "Failed to upload SampleImage, failed with error (${e.runtimeType}): (${e.toString()})",
          );
      if (e is FormatException || e is TypeError) {
        // Catch formatting exceptions
        return Option.of(
          JsonSerializationException(Map<String, ListOfCoordinates>),
        );
      } else {
        return Option.of(
          UnknownException(e.toString()),
        );
      }
    }
  }

  /// Update already existing sample metadata
  Future<Option<CustomException>> updateSample(Sample sample) async {
    try {
      GetIt.I.get<Logger>().t(
            "Updating (${sample.runtimeType}), ${sample.toString()}",
          );
      return service.updateSample(sample);
    } catch (e) {
      GetIt.I.get<Logger>().e(
            "Failed to update SampleImage, failed with error (${e.runtimeType}): (${e.toString()})",
          );
      if (e is FormatException || e is TypeError) {
        // Catch formatting exceptions
        return Option.of(
          JsonSerializationException(Map<String, ListOfCoordinates>),
        );
      } else {
        return Option.of(
          UnknownException(e.toString()),
        );
      }
    }
  }

  /// Get a sample
  Future<Either<CustomException, Sample>> getSample(
          String uuid, int sample) async =>
      service.getSample(uuid, sample);

  /// Delete a sample
  Future<Either<CustomException, Sample>> deleteSample(
          String uuid, int sample) async =>
      service.deleteSample(uuid, sample);

  /// Get undelivered samples
  Future<Either<CustomException, List<Sample>>> getUndeliveredSamples(
          String email) async =>
      service.getUndeliveredSamples(email);
}
