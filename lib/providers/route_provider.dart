import 'package:flutter/material.dart';

// Wrap a destination with its widget
class DestinationWithRoute {
  final Widget route;
  final NavigationDestination destination;

  const DestinationWithRoute(this.route, this.destination);
}

class RouteProvider with ChangeNotifier {
  late List<DestinationWithRoute> destinations;

  int _currentDestinationIndex = 0;
  int get currentDestinationIndex => _currentDestinationIndex;
  set currentDestinationIndex(int newDestinationIndex) {
    _currentDestinationIndex = newDestinationIndex;
    notifyListeners();
  }

  final PageController pageController = PageController();

  /// Go to the next route
  void goNextRoute({bool animate = true}) {
    goToRouteIndex(
      (currentDestinationIndex + 1) % destinations.length,
      animate: animate,
    );
  }

  void goToRouteIndex(int newIndex, {bool animate = true}) {
    // Change the index
    currentDestinationIndex = newIndex;
    // Animate page change
    if (animate) {
      pageController.animateToPage(
        _currentDestinationIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }
}
