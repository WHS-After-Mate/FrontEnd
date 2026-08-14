import 'package:flutter_test/flutter_test.dart';
import 'package:whs_after_mate/main.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WhsAfterMateApp());
    expect(find.text('관리 이후도, 함께할게요'), findsOneWidget);
  });
}
