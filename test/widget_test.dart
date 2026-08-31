import 'package:flutter_test/flutter_test.dart';
import 'package:forwebs_flutter_starter/main.dart';

void main() {
  testWidgets('shows the reusable WebView entry point', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('URL만 전달해 전체 화면으로 엽니다.'), findsOneWidget);
    expect(find.text('WebView 열기'), findsOneWidget);
  });
}
