import 'package:backend_debugger/providers/diagnoses_provider.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/routes/generic_menu_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiagnosesRoute extends StatelessWidget {
  final DiagnosesProvider provider;

  const DiagnosesRoute({
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GenericMenuRoute(
        onExit: () => provider.disconnect(),
        onNext: context.read<RouteProvider>().goNextRoute,
        destinations: [],
      );
}
