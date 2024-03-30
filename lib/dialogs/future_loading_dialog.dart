import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:flutter/material.dart';

class FutureLoadingDialog<T> extends StatelessWidget {
  final Future<T> future;
  final String title;
  final Widget Function(BuildContext context, AsyncSnapshot<T?> value) builder;

  const FutureLoadingDialog({
    required this.future,
    required this.builder,
    this.title = "Loading",
    super.key,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Future has finished
            if (snapshot.hasError || !snapshot.hasData) {
              // Show an alert dialog
              return ExceptionAlertDialog(Exception(snapshot.error.toString()));
            } else {
              return builder.call(context, snapshot);
            }
          } else {
            return AlertDialog(
              title: Text(this.title),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Wait while the operation is completed"),
                  SizedBox(height: 16),
                  LinearProgressIndicator()
                ],
              ),
            );
          }
        },
      );
}
