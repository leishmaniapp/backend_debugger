import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

abstract class GrpcService<C extends Client> implements Disposable {
  final Duration timeout;
  final ClientChannel channel;
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
