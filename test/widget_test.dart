import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereismybin/main.dart';

void main() {
  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    // Provide mock values for shared preferences to allow the app to initialize in tests
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Verify that our app main widget starts successfully.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
