import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa/skin.dart';
import 'package:zuraffa_flutter/src/skin/skin_app.dart';
import 'package:zuraffa_ui/src/identified/contract/skin_contract_kit.dart';

SkinContractRuntimeBinding _binding() {
  const contractJson = '''
{
  "schemaVersion": "1",
  "routes": [
    { "path": "/login", "view": "LoginPage" },
    { "path": "/register", "view": "RegisterPage" }
  ],
  "states": [
    { "view": "LoginPage", "loading": true, "error": "toaster", "empty": false },
    { "view": "RegisterPage", "loading": true, "error": "inline", "empty": true }
  ],
  "platformRows": [],
  "stateRows": [
    { "view": "LoginPage", "row": "error-toaster", "kind": "observer" }
  ]
}
''';
  final contract = parseSkinContractJson(contractJson);
  return SkinContractRuntimeBinding.fromContract(
    name: 'login-seam',
    contract: contract,
  );
}

Widget _shell(SkinContractRuntimeBinding binding) =>
    ZuraffaSkinApp(
      binding: binding,
      home: const Scaffold(body: Text('root view')),
      viewBuilders: {
        'LoginPage': (_) => const Scaffold(body: Text('login view')),
        'RegisterPage': (_) => const Scaffold(body: Text('register view')),
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('contract routes populate the app route table', (tester) async {
    await tester.pumpWidget(_shell(_binding()));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/register');
    await tester.pumpAndSettle();
    expect(find.text('register view'), findsOneWidget);
  });

  testWidgets('a push of an undeclared route violates on the audit bus',
      (tester) async {
    final binding = _binding();
    final bus = ZfaAuditBus();
    final kit = SkinContractKit(bus: bus);
    final observer =
        SkinRouteContractObserver(binding: binding, bus: kit.bus);

    final violations = <ZfaContractViolation>[];
    bus.addListener(() => violations.addAll(bus.violations));

    final route = MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/settings'),
      builder: (_) => const Scaffold(body: Text('settings')),
    );
    observer.didPush(route, null);
    expect(violations, isNotEmpty);
    expect(violations.last.code, SkinRouteContractObserver.undeclaredRouteCode);
  });

  testWidgets('declared named pushes conform — no violations', (tester) async {
    final binding = _binding();
    final bus = ZfaAuditBus();
    final observer = SkinRouteContractObserver(binding: binding, bus: bus);

    observer.didPush(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const Scaffold(body: Text('login')),
      ),
      null,
    );
    expect(bus.violations, isEmpty);
  });

  test('state bindings drive the toaster per the contract', () {
    final binding = _binding();
    final shell = ZuraffaSkinApp(
      binding: binding,
      viewBuilders: const {},
    );
    expect(shell.toastsErrorsFor('LoginPage'), isTrue);
    expect(shell.toastsErrorsFor('RegisterPage'), isFalse);
    expect(shell.stateBindingFor('RegisterPage').empty, isTrue);
  });
}
