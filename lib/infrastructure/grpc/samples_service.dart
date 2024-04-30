import 'dart:async';
import 'dart:typed_data';

import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/infrastructure/grpc/grpc_service.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/samples.pbgrpc.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/services/sample_service.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:grpc/grpc.dart';

class GrpcSampleService extends GrpcService<SamplesServiceClient>
    implements ISampleService {
  GrpcSampleService(Duration timeout, ClientChannel channel)
      : super(timeout, channel, SamplesServiceClient(channel));

  /// Store an image and its sample metadata
  @override
  Future<Option<CustomException>> storeImageSample({
    required ByteData imageBytes,
    required String imageMimeType,
    required Sample sample,
  }) =>
      // Order of operations is the following
      // TaskEither<Exception, StatusCode> -> Either<Exception, Option<Exception>> -> Either<Exception, Unit> -> Option<Exception>
      TaskEither.tryCatch(
              () => stub.storeImageSample(
                    ImageSampleRequest(
                      sample: sample,
                      image: ImageBytes(
                        mime: imageMimeType,
                        data: imageBytes.buffer.asUint8ClampedList(),
                      ),
                    ),
                  ),
              (o, s) => RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o as GrpcError).message.toString(),
                  ) as NetworkException)
          // Transform the result into an Either<Error, Unit> instead of StatusCode
          .chainEither((r) => r
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Create Either to match parent type but with Unit type
              .toEither(() => unit)
              // Swap positions to put the error as Left (and match parent type)
              .swap())
          // Wrap into an option
          .match<Option<CustomException>>(
            (l) => Option.of(l),
            (r) => const Option.none(),
          )
          .run();

  /// Update already existing sample metadata
  @override
  Future<Option<CustomException>> updateSample(Sample sample) =>
      // Order of operations is the following
      // Either<Exception, StatusCode> -> Either<Exception, Option<Exception>> -> Either<Exception, Unit> -> Option<Exception>
      TaskEither.tryCatch(
              () => stub.updateSample(sample),
              (o, s) => RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o as GrpcError).message.toString(),
                  ) as NetworkException)
          // Transform the result into an Either<Error, Unit> instead of StatusCode
          .chainEither((r) => r
              // Get the exception if present (transform to Option<Exception>)
              .toException()
              // Create Either to match parent type
              .toEither(() => unit)
              // Swap positions to put the error as Left
              .swap())
          // Wrap into an option
          .match<Option<CustomException>>(
            (l) => Option.of(l),
            (r) => const Option.none(),
          )
          .run();

  /// Get a sample
  @override
  Future<Either<CustomException, Sample>> getSample(String uuid, int sample) =>
      TaskEither.tryCatch(
              () => stub.getSample(SampleRequest(
                  diagnosis: uuid,
                  sample: sample)), // Transform error into a NetworkException
              (o, s) => RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o as GrpcError).message.toString(),
                  ) as NetworkException)
          .chainEither((r) => r.status
              .toException()
              .toEither(
                () => r.sample,
              )
              .swap())
          .run();

  /// Delete a sample
  @override
  Future<Either<CustomException, Sample>> deleteSample(
          String uuid, int sample) =>
      TaskEither.tryCatch(
              () => stub.deleteSample(SampleRequest(
                  diagnosis: uuid,
                  sample: sample)), // Transform error into a NetworkException
              (o, s) => RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o as GrpcError).message.toString(),
                  ) as NetworkException)
          .chainEither((r) => r.status
              .toException()
              .toEither(
                () => r.sample,
              )
              .swap())
          .run();

  /// Get samples in DELIVER state
  @override
  Future<Either<CustomException, List<Sample>>> getUndeliveredSamples(
          String email) =>
      TaskEither.tryCatch(
              () => stub.getUndeliveredBySpecialist(
                  UndeliveredRequest(specialist: email)),
              (o, s) => RemoteServiceException(
                    // Catch the GrpcError and get its message as a RemoteServiceException
                    (o as GrpcError).message.toString(),
                  ) as NetworkException)
          .chainEither((r) => r.status
              .toException()
              .toEither(
                () => r.samples,
              )
              .swap())
          .run();
}
