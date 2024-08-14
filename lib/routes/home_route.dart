import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            Text(
              "Leishmaniapp",
              style: context.textStyles.displayMedium,
            ),
            Text(
              "Analysis Backend Debugger",
              style: context.textStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const Text("gRPC client for a protobuf_schema based backend"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.icon(
                onPressed: () => context.read<RouteProvider>().goNextRoute(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Continue to the Debugger"),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.scheme.outline),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    "Copyright (c) 2024 Pontificia Universidad Javeriana, Angel Talero "
                    "\n"
                    "Permission is hereby granted, free of charge, to any person obtaining a copy "
                    "of this software and associated documentation files (the \"Software\"), to deal "
                    "in the Software without restriction, including without limitation the rights "
                    "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell "
                    "copies of the Software, and to permit persons to whom the Software is "
                    "furnished to do so, subject to the following conditions: "
                    "\n"
                    "The above copyright notice and this permission notice shall be included in all "
                    "copies or substantial portions of the Software. "
                    "\n"
                    "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR "
                    "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, "
                    "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE "
                    "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER "
                    "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, "
                    "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE "
                    "SOFTWARE.",
                    style: context.textStyles.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      );
}
