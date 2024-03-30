import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

class SimpleIgnoreDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  const SimpleIgnoreDialog(this.title, this.content, {super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton(
                onPressed: context.navigator.pop,
                child: const Text("Ok"),
              ),
            ),
          ].separatedBy(const SizedBox(height: 10)),
        ),
      );
}
