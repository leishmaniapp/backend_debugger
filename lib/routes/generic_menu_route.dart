import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

/// Show a menu of options and select each one of them
class GenericMenuRoute extends StatefulWidget {
  /// List of destinations (menu items)
  final List<MenuRouteDestination> destinations;

  /// Function to be called when exiting the menu
  final void Function() onExit;

  /// Function to be called when the continue button is pressed
  final void Function() onNext;

  const GenericMenuRoute({
    required this.destinations,
    required this.onExit,
    required this.onNext,
    super.key,
  });

  @override
  State<GenericMenuRoute> createState() => _GenericMenuRouteState();
}

class _GenericMenuRouteState extends State<GenericMenuRoute> {
  // Current shown widget
  Widget? valueWidget;

  @override
  Widget build(BuildContext context) =>
      // If the current widget is null then show the menu
      (valueWidget != null)
          ? valueWidget!
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      // Wrap each destination into a card button widget
                      children: widget.destinations
                          .map(
                            (e) => _MenuRouteDestinationCardButtonWidget(
                              key: UniqueKey(),
                              destination: e,
                              onClick: () {
                                // Change the widget by the one created by the buildrer
                                setState(() => valueWidget = e.builder.call(() {
                                      // Set the widget back to null to show menu
                                      setState(() => valueWidget = null);
                                    }));
                              },
                            ),
                          )
                          .toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                              onPressed: widget.onExit,
                              icon: const Icon(Icons.power_off_rounded),
                              label: const Text("Cancel connection")),
                          FilledButton.icon(
                              onPressed: widget.onNext,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text("Continue")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
}

/// When a service has many possible routes (each for each provided service method)
/// wrap each one of these routes for showing in a menu
class MenuRouteDestination {
  /// Icon to show in the menu card
  final IconData icon;

  /// Title to show
  final String title;

  /// Subtitle of the button
  final String subtitle;

  /// Create the widget, with an exit option
  final Widget Function(void Function() onExit) builder;

  const MenuRouteDestination({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

/// Show [MenuRouteDestination] in a card button
class _MenuRouteDestinationCardButtonWidget extends StatelessWidget {
  /// Where the button navigates to, calls the [MenuRouteDestination.builder]
  final MenuRouteDestination destination;

  /// Callback when the card button is clicked
  final void Function() onClick;

  const _MenuRouteDestinationCardButtonWidget({
    required this.destination,
    required this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(
            12.0,
          ),
          onTap: () => onClick.call(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    destination.icon,
                    size: 40.0,
                  ),
                  Text(
                    destination.title,
                    style: context.textStyles.headlineSmall,
                  ),
                  Text(destination.subtitle),
                ],
              ),
            ),
          ),
        ),
      );
}
