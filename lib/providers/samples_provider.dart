import 'dart:async';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/samples_service.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

class SamplesProvider extends ProviderWithService<ISampleService> {
  SamplesProvider([super.service]);

  @override
  Option<Exception> requestServiceFromInfrastructureWithUri(
    Uri server, [
    String? authToken,
  ]) =>
      SupportedInfrastructure()
          .createServiceFromUri(
        server,
        grpcBuilder: (timeout, channel) => GrpcSampleService(
          timeout,
          channel,
          authToken != null
              ? CallOptions(metadata: {"authorization": "Bearer $authToken"})
              : null,
        ),
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
      ImageBytes asset, Sample request) async {
    try {
      GetIt.I.get<Logger>().t(
            "Uploading (${request.runtimeType}), ${request.toString()} with (${asset.data.length}) bytes of image data",
          );

      return service.storeImageSample(
        image: asset,
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
