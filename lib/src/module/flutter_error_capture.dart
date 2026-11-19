import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' as logging;
import 'package:zuraffa/zuraffa.dart';

/// Signature of the uncaught-error sink every Flutter handler funnels into.
///
/// This is the Flutter-side mirror of the core contract
/// (`Zuraffa.captureUncaught`, arrrrny/zuraffa#2099). A sink must not throw:
/// it runs inside an error handler, and a throw there replaces the error the
/// app was trying to report with the sink's own.
typedef ZuraffaUncaughtErrorSink =
    void Function(Object error, StackTrace stackTrace, {String? context});

/// Arms the Flutter surfaces of the uncaught-error funnel.
///
/// `zuraffa_flutter` is the only package in the family that can own these two
/// handlers: [FlutterError.onError] and [PlatformDispatcher.onError] are
/// `dart:ui` / framework APIs, so they cannot live in the pure-Dart core or in
/// `zuraffa_observability`.
///
/// Both handlers **delegate to one sink** rather than logging directly, so
/// `zuraffa_observability`'s `OtelLogExporter` / failure-reporter wiring sees
/// the same records wherever they originated. The default sink is
/// [captureUncaught]; pass [install]'s `sink` to route somewhere else.
///
/// ## Usage
///
/// ```dart
/// void main() {
///   ZuraffaFlutterErrorCapture.install();
///   runApp(MyApp());
/// }
/// ```
///
/// [install] is idempotent and hands back the live session, which
/// [ZuraffaFlutterErrorCaptureHandle.restore] puts back the handlers that were
/// armed before. Re-entry is tolerated for apps that re-call `main`
/// (arrrrny/zik_zak#356).
abstract final class ZuraffaFlutterErrorCapture {
  static ZuraffaFlutterErrorCaptureHandle? _session;

  /// Arms [FlutterError.onError] and [PlatformDispatcher.onError].
  ///
  /// When a capture is already live it is returned untouched — the second call
  /// neither re-arms the handlers nor chains its own onto the first one's, so
  /// an app that calls `main` twice still chains each previous handler exactly
  /// once.
  ///
  /// [reportAsFailureSpan] also reports the error through
  /// [FailureReporterRegistry], which produces a failure span for exporters
  /// that consume one. It is fire-and-forget and is dropped when no reporter is
  /// registered, so it is safe to leave on.
  ///
  /// [sink] replaces [captureUncaught] as the funnel target. Pass
  /// `Zuraffa.captureUncaught` here once the core contract ships.
  static ZuraffaFlutterErrorCaptureHandle install({
    bool reportAsFailureSpan = true,
    ZuraffaUncaughtErrorSink? sink,
  }) {
    final live = _session;
    if (live != null) return live;

    final session = ZuraffaFlutterErrorCaptureHandle._(
      reportAsFailureSpan: reportAsFailureSpan,
      sink: sink,
    );
    _session = session;
    session._arm();
    return session;
  }

  /// Puts back the handlers that were armed before [install].
  ///
  /// A no-op when no capture is live, so it is safe as a `tearDown` hook.
  static void restore() {
    final session = _session;
    if (session == null) return;
    _session = null;
    session.restore();
  }

  /// The uncaught-error funnel: a SEVERE [logging.Logger.root] record plus,
  /// when [reportAsFailureSpan] is set, a failure report.
  ///
  /// [logging.Logger.root] is the record every exporter already subscribes to,
  /// which is why the Flutter side needs no exporter knowledge of its own.
  static void captureUncaught(
    Object error,
    StackTrace stackTrace, {
    String? context,
    bool reportAsFailureSpan = true,
  }) {
    logging.Logger.root.severe(context ?? 'Uncaught error', error, stackTrace);

    if (!reportAsFailureSpan) return;
    try {
      FailureReporterRegistry.instance.reportFailure(
        AppFailure.from(error, stackTrace),
        stackTrace: stackTrace,
      );
    } on Object {
      // The funnel runs inside an error handler: a throw here would replace
      // the error being reported with the funnel's own. The SEVERE record
      // above has already carried the error to every exporter.
    }
  }
}

/// The live capture [ZuraffaFlutterErrorCapture.install] armed.
///
/// Restore it with [restore] — in a `tearDown` between tests, or at app
/// shutdown for an app that installs capture more than once.
class ZuraffaFlutterErrorCaptureHandle {
  ZuraffaFlutterErrorCaptureHandle._({
    required this.reportAsFailureSpan,
    required ZuraffaUncaughtErrorSink? sink,
  }) : _sink =
           sink ??
           ((error, stackTrace, {context}) =>
               ZuraffaFlutterErrorCapture.captureUncaught(
                 error,
                 stackTrace,
                 context: context,
                 reportAsFailureSpan: reportAsFailureSpan,
               ));

  /// Whether this capture also produces a failure span.
  final bool reportAsFailureSpan;

  final ZuraffaUncaughtErrorSink _sink;

  FlutterExceptionHandler? _previousFlutterOnError;
  bool Function(Object, StackTrace)? _previousPlatformOnError;
  bool _restored = false;

  void _arm() {
    final previous = FlutterError.onError;
    _previousFlutterOnError = previous;

    FlutterError.onError = (details) {
      _sink(
        details.exception,
        details.stack ?? StackTrace.empty,
        context:
            'Uncaught FlutterError: '
            '${details.library ?? 'framework'}: ${details.summary}',
      );
      // Dev tools and `FlutterError.presentError` depend on the previous
      // handler still running, so it is chained rather than dropped.
      previous?.call(details);
    };

    // Deliberately superseded rather than chained: the platform handler's
    // return value decides whether the engine terminates the process, and the
    // two contracts cannot be combined without reintroducing the crash this
    // capture exists to prevent.
    _previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _sink(error, stackTrace, context: 'Uncaught platform error');
      return true;
    };
  }

  /// Puts back the handlers that were armed before the capture.
  ///
  /// Idempotent: restoring twice does nothing.
  void restore() {
    if (_restored) return;
    _restored = true;
    FlutterError.onError = _previousFlutterOnError;
    PlatformDispatcher.instance.onError = _previousPlatformOnError;
  }
}
