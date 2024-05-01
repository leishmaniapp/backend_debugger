import 'package:backend_debugger/providers/diagnoses_provider.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/routes/generic_menu_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiagnosesRoute extends StatefulWidget {
  final DiagnosesProvider provider;
  const DiagnosesRoute({
    required this.provider,
    super.key,
  });

  @override
  State<DiagnosesRoute> createState() => _DiagnosesRouteState();
}

class _DiagnosesRouteState extends State<DiagnosesRoute> {
  // Show the current destination
  Widget? currentDestination;

  @override
  Widget build(BuildContext context) {
    // Get the routes
    final routes = <MenuRouteDestination>[];

    return Center(
      child: (currentDestination == null)
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    children: routes,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton.icon(
                            onPressed: () => (widget.provider.service = null),
                            icon: const Icon(Icons.power_off_rounded),
                            label: const Text("Cancel connection")),
                        FilledButton.icon(
                            onPressed:
                                context.read<RouteProvider>().goNextRoute,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text("Continue")),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : currentDestination,
    );
  }
}
