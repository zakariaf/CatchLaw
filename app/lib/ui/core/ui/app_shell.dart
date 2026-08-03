import 'package:catchlaw/routing/destination_placeholder.dart';
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:catchlaw/ui/core/ui/lonja_nav_strip.dart';
import 'package:flutter/material.dart';

/// The app's front door: five branches, each keeping its own history.
///
/// **An `IndexedStack` of `Navigator`s, and no router package.** `go_router` is
/// not in `SPEC.md` §10's dependency table, and v1 has no deep link, no
/// share-in and no notification tap-through — nothing to link deeply from. D-23
/// records the decision and names what the v2 task that adopts a router must
/// do.
///
/// **Branch state survives a switch**, which is the whole reason the branches
/// are stacked rather than swapped: a fisher who pushes a species detail, taps
/// Reference and taps back is still looking at that species. Rebuilding the
/// branch would put him back at the top of a list he had already scrolled.
class AppShell extends StatefulWidget {
  /// Opens on Check, with [check] as its root.
  const AppShell({required this.check, super.key});

  /// The Check branch's root screen — S1.
  final Widget check;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final Map<LonjaDestination, GlobalKey<NavigatorState>> _navigators =
      <LonjaDestination, GlobalKey<NavigatorState>>{
        for (final LonjaDestination d in LonjaDestination.values)
          d: GlobalKey<NavigatorState>(debugLabel: d.name),
      };

  LonjaDestination _current = LonjaDestination.check;

  /// Switches branch, or pops the current one to its root on a second tap.
  ///
  /// The second-tap-pops behaviour is what makes the strip a way BACK as well
  /// as a way across: a fisher three screens deep in Check who taps Check
  /// expects the front door, and every other app on his phone does that.
  void _select(LonjaDestination destination) {
    if (destination == _current) {
      _navigators[destination]!.currentState?.popUntil((Route<void> r) => r.isFirst);
      return;
    }
    setState(() => _current = destination);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: LonjaDestination.values.indexOf(_current),
      children: <Widget>[
        for (final LonjaDestination destination in LonjaDestination.values)
          Navigator(
            key: _navigators[destination],
            onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) => destination == LonjaDestination.check
                  ? widget.check
                  : DestinationPlaceholder(destination: destination),
            ),
          ),
      ],
    ),
    bottomNavigationBar: LonjaNavStrip(current: _current, onSelected: _select),
  );
}
