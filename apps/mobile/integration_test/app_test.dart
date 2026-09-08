import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeoffice_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('platform app connects to the real API', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Ligação ao serviço'), 250);
    for (
      var i = 0;
      i < 30 && find.text('Serviço ligado').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Serviço ligado'), findsOneWidget);
    expect(find.text('Europe/Lisbon · Europe/Zurich'), findsOneWidget);
  });
}
