import 'dart:async';
import 'dart:convert';

import 'dart:typed_data';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/samples.pbgrpc.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:unixtime/unixtime.dart';

class GrpcSampleService extends GrpcService<SampleServiceClient>
    implements ISampleService {
  GrpcSampleService(Duration timeout, ClientChannel channel)
      : super(timeout, channel, SampleServiceClient(channel));

  @override
  FutureOr<Option<CustomException>> uploadImageSample(
      String diagnosisUuid,
      int sample,
      String disease,
      AnalysisStage stage,
      String results,
      DateTime date,
      ByteData sampleBytes,
      int sampleSize,
      String sampleMime) async {
    // Serialize the results
    try {
      // Create the sample request
      final request = ImageSampleRequest(
        sample: Sample(
          // Parse result JSON into the appropiate type
          results: results.isEmpty
              ? <String, ListOfCoordinates>{}
              : (jsonDecode(results) as Map<String, dynamic>).mapValue(
                  (value) => ListOfCoordinates(
                    coordinates: (value as List<dynamic>).map<Coordinates>(
                      (e) => Coordinates.create()..mergeFromProto3Json(e),
                    ),
                  ),
                ),
          // Store image metadata
          metadata: ImageMetadata(
              diagnosis: diagnosisUuid,
              sample: sample,
              disease: disease,
              date: Int64(date.unixtime),
              size: sampleSize),
          stage: stage,
        ),
        // Image ByteBuffer as byte[]
        image: ImageBytes(
          mime: sampleMime,
          data: sampleBytes.buffer.asUint8List(),
        ),
      );

      GetIt.I.get<Logger>().t(
            "Uploading (${request.runtimeType}), ${request.toString()}",
          );

      // Order of operations is the following
      // TaskEither<Exception, StatusCode> -> Either<Exception, Option<Exception>> -> Either<Exception, Unit> -> Option<Exception>
      return (await TaskEither.tryCatch(
                  () => stub.storeImageSample(request),
                  (o, s) => RemoteServiceException(
                        // Catch the GrpcError and get its message as a RemoteServiceException
                        (o as GrpcError).message.toString(),
                      ) as NetworkException)
              // Transform task into Future
              .run())
          // Transform the result into an Either<Error, Unit> instead of StatusCode
          .bind((r) => r
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Create Either to match parent type
              .toEither(() => unit)
              // Swap positions to put the error as Left
              .swap())
          // Put error (left) as value
          .swap()
          // Return the error if present
          .toOption();
    } catch (e) {
      GetIt.I.get<Logger>().e(
            "Failed to upload SampleImage, failed with error (${e.runtimeType}): (${e.toString()})",
          );
      if (e is FormatException || e is TypeError) {
        // Catch formatting exceptions
        return Option.of(
            JsonSerializationException(Map<String, ListOfCoordinates>));
      } else {
        return Option.of(UnknownException(e.toString()));
      }
    }
  }
}
