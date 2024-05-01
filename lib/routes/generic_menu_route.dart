import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

/// SampleService has many possible routes (each for each provided method)
/// wrap each one of these routes in a selectable Card for nativation
class MenuRouteDestination extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget route;

  final void Function(Widget) onClick;

  const MenuRouteDestination({
    required this.icon,
    required this.title,
    required this.route,
    required this.subtitle,
    required this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: () => onClick.call(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 40.0,
                  ),
                  Text(
                    title,
                    style: context.textStyles.headlineSmall,
                  ),
                  Text(subtitle),
                ],
              ),
            ),
          ),
        ),
      );
}
