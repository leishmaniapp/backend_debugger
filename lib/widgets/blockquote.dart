import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

class Blockquote extends StatelessWidget {
  const Blockquote({this.title, required this.text, super.key});
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: context.textStyles.bodyMedium.bold,
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: context.colors.scheme.primary),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(text),
          ),
        ],
      );
}
