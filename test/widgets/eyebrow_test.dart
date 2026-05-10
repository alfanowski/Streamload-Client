// test/widgets/eyebrow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/theme/theme.dart';
import 'package:streamload_client/presentation/widgets/eyebrow.dart';

void main() {
  testWidgets('renders the label uppercased and visible', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: streamloadTheme(),
      home: const Scaffold(body: Eyebrow('in primo piano')),
    ));
    expect(find.text('IN PRIMO PIANO'), findsOneWidget);
  });
}
