import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

class ExceptionAlertDialog extends StatelessWidget {
  final Exception exception;
  const ExceptionAlertDialog(this.exception, {super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "An exception ocurred",
              style: context.textStyles.headlineMedium,
            ),
            Text(exception.toString()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton.filled(
                onPressed: context.navigator.pop,
                icon: const Icon(Icons.cancel),
              ),
            ),
          ].separatedBy(const SizedBox(height: 10)),
        ),
      );
}
