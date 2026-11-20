import 'package:material_ui/material_ui.dart';

import 'package:zuraffa/zuraffa.dart';

/// Minimal widget that resolves routes from a [ZuraffaEngine]'s
/// [ZuraffaEngine.masterRouteMap].
///
/// [ZuraffaAppRunner] is a proof-of-concept host shell widget.
/// It does **not** integrate with `go_router` or any named-route
/// system -- that bridge is a future follow-up. For now it
/// demonstrates that the engine produces a usable route table
/// and that the host can resolve a widget from it.
///
/// ## Usage
///
/// ```dart
/// final engine = ZuraffaEngine()
///   ..register(ZuraffaFlutterPlugin())
///   ..register(MyFeaturePlugin());
/// await engine.bootstrap();
///
/// runApp(
///   ZuraffaAppRunner(engine: engine),
/// );
/// ```
///
/// ## Booting with error capture
///
/// The snippet above boots with a bare [runApp], so a widget build error, an
/// uncaught async error and a fire-and-forget future reach no sink: invisible
/// in release, console-print in debug. Arm the global handlers first:
///
/// ```dart
/// void main() {
///   ZuraffaFlutterErrorCapture.install();
///   runApp(ZuraffaAppRunner(engine: engine));
/// }
/// ```
///
/// `install()` is idempotent, so an app that re-calls `main` does not stack
/// handlers. Once the core funnel ships (arrrrny/zuraffa#2099) the guarded boot
/// also wraps the body in `Zuraffa.runGuarded` and passes
/// `sink: Zuraffa.captureUncaught` to `install`, so the Dart-level and
/// Flutter-level handlers report through one function.
class ZuraffaAppRunner extends StatelessWidget {
  /// The bootstrapped engine whose [ZuraffaEngine.masterRouteMap]
  /// supplies the route table.
  final ZuraffaEngine engine;

  /// Optional initial route key to display on first frame.
  /// Defaults to `'/`.
  final String initialRoute;

  /// Creates a [ZuraffaAppRunner] powered by the given [engine].
  const ZuraffaAppRunner({
    super.key,
    required this.engine,
    this.initialRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    final routes = engine.masterRouteMap;
    final handler = routes[initialRoute];

    return MaterialApp(
      home: handler != null
          ? Builder(
              builder: (context) {
                // Flutter routes are registered as `ZuraffaRouteBuilder`s
                // (Widget Function(BuildContext, Object?)). The engine stores
                // them as platform-agnostic handlers. Pass the runtime
                // [BuildContext] through the payload so adapted route builders
                // can access it.
                final payload = <String, dynamic>{
                  '_context': context,
                  'args': null,
                };
                final result = handler(payload);
                return result is Widget ? result : const SizedBox.shrink();
              },
            )
          : const _PlaceholderHome(),
    );
  }
}

/// Placeholder shown when [initialRoute] is not found in the
/// engine's route map.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ZuraffaAppRunner: no route matched initialRoute.'),
      ),
    );
  }
}
