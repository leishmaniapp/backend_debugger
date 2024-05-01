import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

/// Abstraction over a gRPC service implementation
abstract class GrpcService<C extends Client> implements Disposable {
  /// Timeout during sync calls
  final Duration timeout;

  /// Client channel for communication
  final ClientChannel channel;

  /// Service stub
  final C stub;

  const GrpcService(this.timeout, this.channel, this.stub);

  @override
  FutureOr onDispose() {
    return channel.shutdown();
  }

  static ChannelOptions get defaultChannelOptions => const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      );
}
