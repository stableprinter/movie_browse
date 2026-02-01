import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieBrowseApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Discover'), findsAtLeastNWidgets(1));
  });
}
