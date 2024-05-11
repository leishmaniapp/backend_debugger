import 'dart:io';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/widgets/date_picker_widget.dart';
import 'package:fixnum/fixnum.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/analysis.pb.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/analysis_provider.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:unixtime/unixtime.dart';
import 'package:uuid/uuid.dart';

class AnalysisRoute extends StatefulWidget {
  final AnalysisProvider provider;

  const AnalysisRoute({
    required this.provider,
    super.key,
  });

  @override
  State<AnalysisRoute> createState() => _AnalysisRouteState();
}

class _AnalysisRouteState extends State<AnalysisRoute> {
  /// Text controller for the diagnosis UUID
  final diagnosisTextController = TextEditingController();

  /// Text controller for the sample
  final sampleTextController = TextEditingController()..text = "0";

  /// Text controller for the disease ID
  final diseaseTextController = TextEditingController()..text = "mock.dots";

  /// Current diagnosis DateTime
  DateTime currentDateTime = DateTime.now();

  /// Image bytes grabbed from a [FilePicker]
  List<int>? imageBytes;

  /// Selected image MIME type
  String? imageMime;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        // Get the authenticatefd user
        final from = context.read<AuthProvider>().specialist.match(
              (l) => throw l,
              (r) => r.email,
            );

        // Start listening
        widget.provider.startListening(from);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => const SimpleIgnoreDialog(
            Text("User not authenticated"),
            Text("Authentication required before using this service"),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Diagnosis UUID
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: diagnosisTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Diagnosis UUID",
                    ),
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: context.colors.scheme.primaryContainer,
                  onPressed: () =>
                      (diagnosisTextController.text = const Uuid().v4(),),
                  child: const Icon(Icons.playlist_add_rounded),
                )
              ].separatedBy(const SizedBox(width: 16.0)),
            ),

            // Samples and Disease
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                      controller: sampleTextController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Sample number",
                      )),
                ),
                Expanded(
                  child: TextField(
                    controller: diseaseTextController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Disease",
                      hintText: "mock.dots",
                    ),
                  ),
                ),
              ].separatedBy(const SizedBox(width: 16.0)),
            ),

            // Select image button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    // Get the selected file
                    final fileResult = await FilePicker.platform.pickFiles();
                    // If no file was selected
                    if (fileResult == null) {
                      return;
                    }

                    // Read the file
                    final file = File(fileResult.files.single.path!);
                    // Read the bytes
                    file.readAsBytes().then(
                          (value) => setState(() {
                            imageMime = lookupMimeType(file.path);
                            imageBytes = value;
                          }),
                        );
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Pick a file"),
                ),

                // Image description text
                (imageBytes == null
                    ? const Text("No file currently selected")
                    : Text(
                        "(${imageBytes?.length}) bytes loaded, file of type ($imageMime)",
                      )),
              ].separatedBy(const SizedBox(
                width: 12.0,
              )),
            ),

            // Current DateTime
            DatePickerWidget(
              onPick: (dt) => setState(() {
                currentDateTime = dt;
              }),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 2.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => widget.provider.disconnect(),
                    icon: const Icon(Icons.power_off_rounded),
                    label: const Text("Cancel connection"),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      try {
                        // Validate the input
                        if (diseaseTextController.text.isEmpty) {
                          throw Exception("Disease cannot be emtpy");
                        } else if (!Uuid.isValidUUID(
                          fromString: diagnosisTextController.value.text,
                        )) {
                          throw Exception("Invalid UUID");
                        }

                        // Get the specialist
                        final specialist =
                            switch (context.read<AuthProvider>().specialist) {
                          fp.Left(value: final l) => throw l,
                          fp.Right(value: final r) => r,
                        };

                        // Build the request
                        final request = AnalysisRequest(
                          specialist: specialist.toRecord(),
                          image: ImageBytes(
                            data: imageBytes,
                            mime: imageMime,
                          ),
                          metadata: ImageMetadata(
                            sample: sampleTextController.text.toInt(),
                            diagnosis: diagnosisTextController.text,
                            disease: diseaseTextController.text,
                            date: Int64(currentDateTime.unixtime),
                          ),
                        );

                        // Send the request
                        widget.provider.startListening(specialist.email);
                        widget.provider.sendRequest(request);
                      } catch (e, s) {
                        GetIt.I.get<Logger>().e("Failed to request analysis",
                            error: e, stackTrace: s);

                        showDialog(
                          context: context,
                          builder: (context) => SimpleIgnoreDialog(
                              const Text("Error parsing request"), Text("$e")),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_time_extension_rounded),
                    label: const Text("Send request"),
                  )
                ],
              ),
            ),

            const Divider(
              height: 0,
              indent: 0,
              thickness: 0,
            ),

            /// Response block
            (widget.provider.responses.isEmpty)
                ? const Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("When data arrives, it will be shown here"),
                      SizedBox(height: 8.0),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  )
                : Expanded(
                    child: ListView(
                      children: widget.provider.responses
                          .mapIndexed(
                            (i, e) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      padding: const EdgeInsets.all(
                                        8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.scheme.primary,
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      child: Text(
                                        "Response #$i",
                                        style: TextStyle(
                                          color:
                                              context.colors.scheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        e.toString().trim(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ].separatedBy(
            const SizedBox(
              height: 16.0,
            ),
          ),
        ),
      );
}
