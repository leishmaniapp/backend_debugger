import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/routes/auth/auth_route.dart';
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
        const DestinationWithRoute(
          AuthRoute(),
          NavigationDestination(
            icon: Icon(Icons.key_rounded),
            label: "Auth",
          ),
        ),
        // About route
        const DestinationWithRoute(
          SamplesRoute(),
          NavigationDestination(
            icon: Icon(Icons.image),
            label: "Samples",
          ),
        ),
      ];
    });

    return Scaffold(
      body: PageView(
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
