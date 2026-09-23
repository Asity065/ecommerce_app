import 'package:ecommerce_riverpod/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(AsyncValue<String> value, {VoidCallback? onRetry}) {
    return MaterialApp(
      home: Scaffold(
        body: AsyncValueWidget<String>(
          value: value,
          onRetry: onRetry,
          data: (data) => Text(data),
        ),
      ),
    );
  }

  testWidgets('shows a CircularProgressIndicator while loading', (tester) async {
    await tester.pumpWidget(wrap(const AsyncValue.loading()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the data widget once loaded', (tester) async {
    await tester.pumpWidget(wrap(const AsyncValue.data('Bonjour')));

    expect(find.text('Bonjour'), findsOneWidget);
  });

  testWidgets('shows an error message and a retry button on error', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      wrap(
        AsyncValue.error(Exception('Oups'), StackTrace.empty),
        onRetry: () => retried = true,
      ),
    );

    expect(find.textContaining('Oups'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Réessayer'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Réessayer'));
    expect(retried, isTrue);
  });
}
