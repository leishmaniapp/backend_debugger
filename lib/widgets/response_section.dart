import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

class ResponseSection extends StatelessWidget {
  final String title;
  final String content;

  const ResponseSection({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(title),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  content,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: context.textStyles.bodySmall,
                ),
              ),
              const SizedBox(
                width: 4.0,
              )
            ],
          ),
        ),
      );
}
