import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/providers/analysis_provider.dart';
import 'package:backend_debugger/widgets/response_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';

class ExpandedResults extends StatelessWidget {
  const ExpandedResults({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AnalysisProvider>(
        builder: (context, provider, _) => Scaffold(
          appBar: AppBar(
            title: const Text("Analysis Results"),
          ),
          body: (provider.responses.isEmpty)
              ? const Center(
                  child: Column(
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
                  ),
                )
              : Expanded(
                  child: ListView(
                    children: provider.responses
                        .mapIndexed(
                          (i, response) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                        color: context.colors.scheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      ResponseSection(
                                        title: "Status",
                                        content:
                                            "Code=${response.status.code},Description=${response.status.hasDescription() ? response.status.description : "none"}",
                                      ),
                                      if (response.hasError()) ...[
                                        ResponseSection(
                                          title: "Diagnosis",
                                          content:
                                              response.error.metadata.diagnosis,
                                        ),
                                        ResponseSection(
                                          title: "Disease",
                                          content:
                                              response.error.metadata.disease,
                                        ),
                                        ResponseSection(
                                          title: "Date",
                                          content: response.error.metadata.date
                                              .toString(),
                                        ),
                                        ResponseSection(
                                          title: "Specialist",
                                          content:
                                              response.error.specialist.email,
                                        ),
                                      ],
                                      if (response.hasOk()) ...[
                                        ResponseSection(
                                          title: "Diagnosis",
                                          content:
                                              response.ok.metadata.diagnosis,
                                        ),
                                        ResponseSection(
                                          title: "Disease",
                                          content: response.ok.metadata.disease,
                                        ),
                                        ResponseSection(
                                          title: "Date",
                                          content: response.ok.metadata.date
                                              .toString(),
                                        ),
                                        ResponseSection(
                                          title: "Specialist",
                                          content: response.ok.specialist.email,
                                        ),
                                        const Divider(),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: response.ok.results.entries
                                              .map(
                                                (entry) => Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    Card.outlined(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(entry.key),
                                                      ),
                                                    ),
                                                    ...entry.value.coordinates
                                                        .map(
                                                      (e) => Card.filled(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Text(
                                                            "(${e.x}, ${e.y})",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList()
                        .reversed
                        .toList(),
                  ),
                ),
        ),
      );
}
