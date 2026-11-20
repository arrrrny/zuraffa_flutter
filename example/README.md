# zuraffa_flutter

Flutter presentation layer for Zuraffa — views, controllers, presenters and
responsive/adaptive view helpers that bind a Zuraffa feature to Flutter widgets.

## Bind a view to a presenter

```dart
import 'package:flutter/material.dart';
import 'package:zuraffa_flutter/zuraffa_flutter.dart';

class CounterView extends ZuraffaView<CounterPresenter, int> {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, int state) {
    return Scaffold(
      body: Center(child: Text('$state')),
    );
  }
}
```

## Responsive layout

```dart
import 'package:zuraffa_flutter/zuraffa_flutter.dart';

ResponsiveView(
  mobile: const MobileLayout(),
  desktop: const DesktopLayout(),
)
```