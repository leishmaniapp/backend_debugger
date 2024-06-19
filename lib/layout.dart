import 'package:backend_debugger/providers/analysis_provider.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/providers/diagnoses_provider.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/providers/samples_provider.dart';
import 'package:backend_debugger/routes/analysis/analysis_route.dart';
import 'package:backend_debugger/routes/auth/auth_route.dart';
import 'package:backend_debugger/routes/diagnoses/diagnoses_route.dart';
import 'package:backend_debugger/routes/generic_connection_authenticated_route.dart';
import 'package:backend_debugger/routes/generic_connection_route.dart';
import 'package:backend_debugger/routes/home_route.dart';
import 'package:backend_debugger/routes/samples/samples_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    // Create provider
    final routeProvider = context.watch<RouteProvider>().apply((it) {
      it.destinations = [
        const DestinationWithRoute(
          HomeRoute(),
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
        ),
        // Authentication route
        DestinationWithRoute(
          GenericConnectionRoute<AuthProvider>(
            connectionTitle: "Connect to the authentication service",
            builder: (contex, provider) => AuthRoute(provider: provider),
          ),
          const NavigationDestination(
            icon: Icon(Icons.key_rounded),
            label: "Auth",
          ),
        ),
        // Samples routes
        DestinationWithRoute(
          GenericConnectionAuthenticatedRoute<SamplesProvider>(
            connectionTitle: "Connect to the samples service",
            builder: (context, provider) => SamplesRoute(provider: provider),
          ),
          const NavigationDestination(
            icon: Icon(Icons.image),
            label: "Samples",
          ),
        ),
        // Diagnoses route
        DestinationWithRoute(
          GenericConnectionAuthenticatedRoute<DiagnosesProvider>(
            connectionTitle: "Connect to the diagnoses service",
            builder: (context, provider) => DiagnosesRoute(provider: provider),
          ),
          const NavigationDestination(
            icon: Icon(Icons.text_snippet_rounded),
            label: "Diagnoses",
          ),
        ),
        DestinationWithRoute(
          GenericConnectionAuthenticatedRoute<AnalysisProvider>(
            connectionTitle: "Connect to the analysis service",
            builder: (contex, provider) => AnalysisRoute(provider: provider),
          ),
          const NavigationDestination(
              icon: Icon(Icons.analytics_rounded), label: "Analysis"),
        ),
      ];
    });

    return Scaffold(
      body: PageView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        controller: routeProvider.pageController,
        onPageChanged: (newDestinationIndex) => routeProvider.goToRouteIndex(
          newDestinationIndex,
          animate: false,
        ),
        children: routeProvider.destinations.map((e) => e.route).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: routeProvider.currentDestinationIndex,
        destinations:
            routeProvider.destinations.map((e) => e.destination).toList(),
        onDestinationSelected: (newDestinationIndex) =>
            routeProvider.goToRouteIndex(
          newDestinationIndex,
        ),
      ),
    );
  }
}
