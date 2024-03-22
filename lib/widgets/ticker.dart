import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that updates itself every [Duration]
class TickerBuilder<T> extends StatefulWidget {
  final Duration updateRate;
  final T initialValue;
  final T Function(T) computeValue;
  final Widget Function(BuildContext, T) builder;

  const TickerBuilder(
      {required this.updateRate,
      required this.initialValue,
      required this.computeValue,
      required this.builder,
      super.key});

  @override
  State<TickerBuilder> createState() => _TickerBuilderState<T>();
}

class _TickerBuilderState<T> extends State<TickerBuilder<T>> {
  late T value = widget.initialValue;
  late Timer timer;

  @override
  void initState() {
    // Every widget.updateRate, set value to the new this.computeValue computed value
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timer = Timer.periodic(widget.updateRate,
          (timer) => setState(() => value = widget.computeValue(value)));
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context, value);
}
