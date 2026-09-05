import 'package:flutter/material.dart';
import 'package:zuraffa/skin.dart';
import 'package:zuraffa_ui/src/identified/app/zuraffa_app.dart';
import 'package:zuraffa_ui/src/identified/theme/zfa_theme.dart';
import 'package:zuraffa_ui/src/identified/contract/skin_contract_kit.dart';

/// Validates every navigator push against the skin contract's declared
/// routes and reports violations into the shared audit bus.
///
/// The route semantics live in the core's [RouteContractTable]
/// (`package:zuraffa/skin.dart`): the navigator root conforms by
/// construction, null/empty names are framework traffic, and only
/// undeclared named pushes violate. This observer is the bridge from
/// those pure semantics to the Flutter navigator — it owns no rules of
/// its own.
class SkinRouteContractObserver extends NavigatorObserver {
  SkinRouteContractObserver({
    required SkinContractRuntimeBinding binding,
    this.bus,
  }) : _routeTable = binding.routeTable;

  final RouteContractTable _routeTable;

  /// The audit bus violations are reported to; may be null for a
  /// silent observer.
  final ZfaAuditBus? bus;

  /// The violation code for a push of an undeclared route.
  static const String undeclaredRouteCode = 'route.undeclared';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _audit(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _audit(newRoute);
  }

  void _audit(Route<dynamic> route) {
    final violation = _routeTable.validatePush(route.settings.name);
    if (violation != null) {
      bus?.report(
        ZfaContractViolation(
          code: undeclaredRouteCode,
          message: violation.message,
        ),
      );
    }
  }
}

/// The contract-consuming app shell (issue #1165, stage 2b of #1111).
///
/// Composes the certified [ZuraffaApp] around a parsed skin contract:
/// the route table is populated from `contract.routes` (each route's
/// view resolved through [viewBuilders]), the audit bus is fed by a
/// [SkinRouteContractObserver] validating pushes against the declared
/// routes, and the per-view toaster/empty bindings are exposed through
/// [stateBindingFor] so the app's error handling needs zero contract
/// wiring at call sites.
///
/// ```dart
/// final binding = SkinContractRuntimeBinding.fromContract(
///   name: declaration.name, contract: declaration.contract);
/// ZuraffaSkinApp(
///   binding: binding,
///   viewBuilders: {
///     'LoginPage': (_) => const LoginPage(),
///     'RegisterPage': (_) => const RegisterPage(),
///   },
/// )
/// ```
class ZuraffaSkinApp extends StatelessWidget {
  const ZuraffaSkinApp({
    super.key,
    required this.binding,
    required this.viewBuilders,
    this.home,
    this.initialRoute,
    this.theme,
    this.showViolationChrome = true,
  });

  /// The route name to start on (must be declared by the contract).

  /// The root widget — WidgetsApp always pushes `/` on cold start (the
  /// route contract conforms it by construction); forward it here.

  /// The runtime binding built from the parsed skin contract.
  final SkinContractRuntimeBinding binding;

  /// Builders for the views the contract declares, keyed by the view
  /// NAME in the contract (`routes[].view`).
  final Map<String, WidgetBuilder> viewBuilders;

  final String? initialRoute;

  /// The root (home) widget of the app.
  final Widget? home;

  /// Optional theme forwarded to [ZuraffaApp].
  final ZfaThemeData? theme;

  /// Whether the violation chrome is shown.
  final bool showViolationChrome;

  /// The state binding for [view] — how error and empty states surface
  /// for that view per the contract. An undeclared view binds neutral
  /// (no toaster, no empty).
  StateBinding stateBindingFor(String view) => binding.stateBindingFor(view);

  /// Whether [view] reports errors through the toaster per the contract.
  bool toastsErrorsFor(String view) =>
      stateBindingFor(view).error == StateErrorKind.toaster;

  @override
  Widget build(BuildContext context) {
    assert(
      binding.declaredViews.every(viewBuilders.containsKey),
      'ZuraffaSkinApp: the contract declares views with no builder: '
      '${binding.declaredViews.where((v) => !viewBuilders.containsKey(v)).join(", ")}',
    );
    final kit = SkinContractKit();
    return ZuraffaApp(
      home: home,
      initialRoute: initialRoute,
      routes: {
        for (final route in binding.declaredRoutes)
          if (viewBuilders[route.view] != null)
            route.path: viewBuilders[route.view]!,
      },
      navigatorObservers: [
        SkinRouteContractObserver(binding: binding, bus: kit.bus),
      ],
      auditBus: kit.bus,
      showViolationChrome: showViolationChrome,
      theme: theme,
    );
  }
}
