import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart' as logging;
import 'package:zuraffa/zuraffa.dart';

import 'package:zuraffa_flutter/src/module/flutter_error_capture.dart';

/// Collects the SEVERE records [logging.Logger.root] emits while [body] runs.
///
/// The funnel is observed at the root logger because that is where
/// `zuraffa_observability`'s `OtelLogExporter` subscribes — an exporter that
/// sees the record is proof the error reached every configured sink.
Future<List<logging.LogRecord>> captureSevereRecords(
  FutureOr<void> Function() body,
) async {
  final severe = <logging.LogRecord>[];
  final previousLevel = logging.Logger.root.level;
  logging.Logger.root.level = logging.Level.ALL;
  final sub = logging.Logger.root.onRecord.listen((record) {
    if (record.level == logging.Level.SEVERE) severe.add(record);
  });
  try {
    await body();
  } finally {
    sub.cancel();
    logging.Logger.root.level = previousLevel;
  }
  return severe;
}

/// A [FailureReporter] that keeps what it was handed.
class _RecordingReporter implements FailureReporter {
  final List<FailureReport> reports = <FailureReport>[];

  @override
  String get id => 'test-recorder';

  @override
  bool shouldReport(AppFailure failure) => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> reportBatch(List<FailureReport> batch) async {
    reports.addAll(batch);
  }
}

/// A widget whose [build] throws — the reported symptom's simplest trigger.
class _ThrowingView extends StatelessWidget {
  const _ThrowingView();

  @override
  Widget build(BuildContext context) => throw StateError('boom');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The handlers are process state, so every test puts them back: a leaked
  // capture changes what the next test observes.
  tearDown(ZuraffaFlutterErrorCapture.restore);

  group('FlutterError.onError', () {
    testWidgets('a widget build error produces a Logger.root SEVERE record', (
      tester,
    ) async {
      ZuraffaFlutterErrorCapture.install();

      final severe = await captureSevereRecords(() async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: _ThrowingView(),
          ),
        );
      });
      // Drain the framework's own record of the build error so it does not
      // fail the test independently of what we assert here.
      tester.takeException();

      expect(severe, hasLength(1));
      expect(severe.single.message, contains('Uncaught FlutterError'));
      expect(severe.single.error, isA<StateError>());
      expect(severe.single.stackTrace, isNotNull);
    });

    test('the details are summarized with library and exception', () {
      final seen = <List<dynamic>>[];
      ZuraffaFlutterErrorCapture.install(
        sink: (error, st, {context}) {
          seen.add(<dynamic>[error, context]);
        },
      );

      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError('boom'),
          stack: StackTrace.empty,
          library: 'zuraffa test',
        ),
      );

      expect(seen.single.first, isA<StateError>());
      expect(seen.single[1], contains('Uncaught FlutterError'));
      expect(seen.single[1], contains('zuraffa test'));
    });

    test('the previous FlutterError.onError is chained, not replaced', () {
      var previousCalls = 0;
      final previous = FlutterError.onError;
      FlutterError.onError = (_) => previousCalls++;
      addTearDown(() {
        ZuraffaFlutterErrorCapture.restore();
        FlutterError.onError = previous;
      });

      ZuraffaFlutterErrorCapture.install(sink: (_, __, {context}) {});
      FlutterError.reportError(
        FlutterErrorDetails(exception: StateError('boom')),
      );

      // Dev tools and `FlutterError.presentError` depend on the previous
      // handler still running, in debug builds especially.
      expect(previousCalls, 1);
    });

    test('a null previous handler installs cleanly', () {
      final previous = FlutterError.onError;
      FlutterError.onError = null;
      addTearDown(() {
        ZuraffaFlutterErrorCapture.restore();
        FlutterError.onError = previous;
      });

      final seen = <Object?>[];
      ZuraffaFlutterErrorCapture.install(
        sink: (error, _, {context}) => seen.add(error),
      );

      FlutterError.reportError(
        FlutterErrorDetails(exception: StateError('boom')),
      );
      expect(seen.single, isA<StateError>());
    });
  });

  group('PlatformDispatcher.onError', () {
    test(
      'an uncaught platform error is funneled and does not crash the app',
      () {
        final seen = <List<dynamic>>[];
        ZuraffaFlutterErrorCapture.install(
          sink: (error, st, {context}) {
            seen.add(<dynamic>[error, context]);
          },
        );

        final handled = PlatformDispatcher.instance.onError!(
          StateError('async boom'),
          StackTrace.empty,
        );

        // `true` is the contract: the framework swallows the error instead of
        // terminating the process.
        expect(handled, isTrue);
        expect(seen.single.first, isA<StateError>());
        expect(seen.single[1], contains('Uncaught platform error'));
      },
    );

    test('an async error reaches Logger.root as SEVERE', () async {
      ZuraffaFlutterErrorCapture.install();

      final severe = await captureSevereRecords(() async {
        PlatformDispatcher.instance.onError!(
          StateError('async boom'),
          StackTrace.current,
        );
      });

      expect(severe, hasLength(1));
      expect(severe.single.error, isA<StateError>());
    });
  });

  group('idempotence and restore', () {
    test('a second install() is a no-op and does not re-chain', () {
      var previousCalls = 0;
      final previous = FlutterError.onError;
      FlutterError.onError = (_) => previousCalls++;
      addTearDown(() {
        ZuraffaFlutterErrorCapture.restore();
        FlutterError.onError = previous;
      });

      final first = ZuraffaFlutterErrorCapture.install(
        sink: (_, __, {context}) {},
      );
      final second = ZuraffaFlutterErrorCapture.install(
        sink: (_, __, {context}) {},
      );

      // Re-entry tolerance for apps that re-call main (zik_zak#356): the
      // original handler is chained exactly once, not once per install.
      expect(second, same(first));

      FlutterError.reportError(
        FlutterErrorDetails(exception: StateError('boom')),
      );
      expect(previousCalls, 1);
    });

    test('restore() puts the previous handlers back', () {
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;

      ZuraffaFlutterErrorCapture.install();
      expect(PlatformDispatcher.instance.onError, isNotNull);

      ZuraffaFlutterErrorCapture.restore();

      expect(FlutterError.onError, same(previousFlutter));
      expect(PlatformDispatcher.instance.onError, same(previousPlatform));
    });

    test('restore() before install() is a no-op, not a throw', () {
      final previous = FlutterError.onError;

      expect(ZuraffaFlutterErrorCapture.restore, returnsNormally);
      expect(FlutterError.onError, same(previous));
    });

    test('install() after restore() arms a fresh capture', () {
      final seen = <Object?>[];
      ZuraffaFlutterErrorCapture.install();
      ZuraffaFlutterErrorCapture.restore();
      ZuraffaFlutterErrorCapture.install(
        sink: (error, _, {context}) => seen.add(error),
      );

      FlutterError.reportError(
        FlutterErrorDetails(exception: StateError('boom')),
      );

      expect(seen.single, isA<StateError>());
    });

    test('restoring through the handle lets the next install() re-arm', () {
      final seen = <Object?>[];
      final handle = ZuraffaFlutterErrorCapture.install();
      handle.restore();

      // The handle's restore() must clear the live session so the next
      // install() arms a fresh capture instead of handing back the restored
      // handle (which would leave capture silently disabled).
      ZuraffaFlutterErrorCapture.install(
        sink: (error, _, {context}) => seen.add(error),
      );

      FlutterError.reportError(
        FlutterErrorDetails(exception: StateError('boom')),
      );

      expect(seen.single, isA<StateError>());
    });
  });

  group('the funnel', () {
    test('captureUncaught logs SEVERE with the given context', () async {
      final severe = await captureSevereRecords(() async {
        ZuraffaFlutterErrorCapture.captureUncaught(
          StateError('boom'),
          StackTrace.current,
          context: 'Uncaught platform error',
        );
      });

      expect(severe.single.message, 'Uncaught platform error');
      expect(severe.single.error, isA<StateError>());
      expect(severe.single.stackTrace, isNotNull);
    });

    test('captureUncaught defaults the context when none is given', () async {
      final severe = await captureSevereRecords(() async {
        ZuraffaFlutterErrorCapture.captureUncaught(
          StateError('boom'),
          StackTrace.current,
        );
      });

      expect(severe.single.message, contains('Uncaught error'));
    });

    test('reportAsFailureSpan enqueues a failure report', () async {
      final registry = FailureReporterRegistry.instance;
      final reporter = _RecordingReporter();
      await registry.register(reporter);
      addTearDown(registry.reset);

      ZuraffaFlutterErrorCapture.install();

      final severe = await captureSevereRecords(() async {
        FlutterError.reportError(
          FlutterErrorDetails(exception: StateError('boom')),
        );
      });
      await registry.flush();

      expect(severe, hasLength(1));
      expect(reporter.reports, hasLength(1));
      expect(reporter.reports.single.failure, isA<UnknownFailure>());
    });

    test(
      'reportAsFailureSpan: false leaves the reporter registry alone',
      () async {
        final registry = FailureReporterRegistry.instance;
        final reporter = _RecordingReporter();
        await registry.register(reporter);
        addTearDown(registry.reset);

        ZuraffaFlutterErrorCapture.install(reportAsFailureSpan: false);
        await captureSevereRecords(() async {
          FlutterError.reportError(
            FlutterErrorDetails(exception: StateError('boom')),
          );
        });
        await registry.flush();

        expect(reporter.reports, isEmpty);
      },
    );
  });
}
