import 'dart:async';
import 'dart:convert';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/support.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:backend_debugger/tools/assets.dart';
import 'package:fixnum/fixnum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:unixtime/unixtime.dart';

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
  Future<Option<CustomException>> storeImageSample(String asset, String uuid,
      int sample, String disease, AnalysisStage stage, String results) async {
    try {
      final request = Sample(
        // Parse result JSON into the appropiate type
        results: results.isEmpty
            ? <String, ListOfCoordinates>{}
            : (jsonDecode(results) as Map<String, dynamic>).mapValue(
                (value) => ListOfCoordinates(
                  coordinates:
                      (value["coordintes"] as List<dynamic>).map<Coordinates>(
                    (e) => Coordinates.create()..mergeFromProto3Json(e),
                  ),
                ),
              ),
        // Store image metadata
        metadata: ImageMetadata(
          diagnosis: uuid,
          sample: sample,
          disease: disease,
          date: Int64(DateTime.now().unixtime),
        ),
        stage: stage,
      );

      // Get image data in bytes
      final imageBytes = (await AssetsTool().loadBytes(asset)).asByteData();

      GetIt.I.get<Logger>().t(
            "Uploading (${request.runtimeType}), ${request.toString()} with (${imageBytes.lengthInBytes}) bytes of image data",
          );

      return service.storeImageSample(
        imageBytes: imageBytes,
        imageMimeType: "image/jpeg",
        sample: Sample(
          metadata: ImageMetadata(
              date: Int64(DateTime.now().unixtime),
              diagnosis: uuid,
              sample: sample,
              disease: disease,
              size: 500),
        ),
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
  Future<Option<CustomException>> updateSample(
      String uuid,
      int sample,
      String disease,
      AnalysisStage stage,
      String results,
      DateTime date) async {
    try {
      final request = Sample(
        // Parse result JSON into the appropiate type
        results: results.isEmpty
            ? <String, ListOfCoordinates>{}
            : (jsonDecode(results) as Map<String, dynamic>).mapValue(
                (value) => ListOfCoordinates(
                  coordinates:
                      (value["coordinates"] as List<dynamic>).map<Coordinates>(
                    (e) => Coordinates.create()..mergeFromProto3Json(e),
                  ),
                ),
              ),
        // Store image metadata
        metadata: ImageMetadata(
          diagnosis: uuid,
          sample: sample,
          disease: disease,
          date: Int64(date.unixtime),
        ),
        stage: stage,
      );

      GetIt.I.get<Logger>().t(
            "Updating (${request.runtimeType}), ${request.toString()}",
          );

      return service.updateSample(request);
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
  Future<Either<CustomException, Object>> getSample(
          String uuid, int sample) async =>
      service.getSample(uuid, sample);

  /// Delete a sample
  Future<Either<CustomException, Object>> deleteSample(
          String uuid, int sample) async =>
      service.deleteSample(uuid, sample);
}
