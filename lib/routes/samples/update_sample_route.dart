import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:flutter/material.dart';
import 'package:unixtime/unixtime.dart';
import 'package:uuid/uuid.dart';

class UpdateSampleRoute extends StatelessWidget {
  final Function() onCancelConnection;

  final void Function(
    String uuid,
    int sample,
    String disease,
    AnalysisStage stage,
    String results,
    DateTime date,
  ) onUpdateSample;

  const UpdateSampleRoute(
    this.onCancelConnection,
    this.onUpdateSample, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get UUID controller
    final textUuidController = TextEditingController();
    final sampleTextController = TextEditingController()..text = "0";
    final diseaseTextController = TextEditingController()..text = "mock.dots";
    final resultsTextController = TextEditingController();

    AnalysisStage? analysisStage = AnalysisStage.ANALYZED;
    DateTime currentDateTime = DateTime.now();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
          horizontal: 2.0,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.image,
                size: 64.0,
              ),
              const Text("Enter sample storage metadata"),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownMenu<AnalysisStage>(
                    onSelected: (value) => (analysisStage = value),
                    label: const Text("Analysis Stage"),
                    initialSelection: AnalysisStage.ANALYZED,
                    dropdownMenuEntries: AnalysisStage.values
                        .map((e) => DropdownMenuEntry(
                              value: e,
                              label: e.name.toLowerCase().capitalizeFirst(),
                            ))
                        .toList(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: textUuidController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Diagnosis UUID",
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: context.colors.scheme.primaryContainer,
                    onPressed: () =>
                        (textUuidController.text = const Uuid().v4()),
                    child: const Icon(Icons.playlist_add_rounded),
                  )
                ].separatedBy(const SizedBox(width: 16.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextField(
                        controller: sampleTextController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sample Number",
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
              TextField(
                maxLines: null,
                controller: resultsTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Results - JSON"),
                ),
              ),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: StatefulBuilder(
                  builder: (context, setState) => Column(
                    children: [
                      Text(
                        "Current selected date",
                        style: context.textStyles.bodyLarge,
                      ),
                      Text(
                        "${currentDateTime.year}/${currentDateTime.month}/${currentDateTime.day}"
                        " (${currentDateTime.hour}:${currentDateTime.minute}:${currentDateTime.second})"
                        " @ ${currentDateTime.unixtime} UnixTime",
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: OutlinedButton(
                                onPressed: () => showDatePicker(
                                  context: context,
                                  initialDate: currentDateTime,
                                  firstDate: currentDateTime.subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: currentDateTime.add(
                                    const Duration(days: 365),
                                  ),
                                ).then((datetime) {
                                  if (datetime != null) {
                                    // Replace current datetime with provided one
                                    setState(
                                      () => (currentDateTime = datetime),
                                    );
                                  }
                                }),
                                child: const Text("Pick Date"),
                              )),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: () => showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentDateTime))
                                  .then((time) {
                                if (time != null) {
                                  // Copy current datetime with current time
                                  setState(
                                    () => (
                                      currentDateTime =
                                          currentDateTime.copyWith(
                                              minute: time.minute,
                                              hour: time.hour),
                                    ),
                                  );
                                }
                              }),
                              child: const Text("Pick Time"),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: FilledButton(
                              onPressed: () => setState(
                                  () => (currentDateTime = DateTime.now())),
                              child: const Text("Now"),
                            ),
                          ),
                        ].separatedBy(const SizedBox(width: 8.0)),
                      )
                    ],
                  ),
                ),
              )),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                      onPressed: onCancelConnection,
                      icon: const Icon(Icons.home_repair_service_rounded),
                      label: const Text("Back to services")),
                  FilledButton.icon(
                      onPressed: () {
                        try {
                          if (analysisStage == null) {
                            throw Exception(
                                "AnalysisStage has not been selected");
                          } else if (!Uuid.isValidUUID(
                              fromString: textUuidController.value.text)) {
                            throw Exception("Invalid UUID");
                          }

                          onUpdateSample.call(
                            textUuidController.value.text,
                            int.parse(sampleTextController.value.text),
                            diseaseTextController.value.text,
                            analysisStage!,
                            resultsTextController.value.text,
                            currentDateTime,
                          );
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) => SimpleIgnoreDialog(
                                const Text("Error parsing options"),
                                Text(e.toString())),
                          );
                        }
                      },
                      icon: const Icon(Icons.update),
                      label: const Text("Update")),
                ],
              ),
            ].separatedBy(const SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
