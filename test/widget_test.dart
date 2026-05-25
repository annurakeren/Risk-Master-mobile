// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:riskmaster/main.dart';
import 'package:provider/provider.dart';
import 'package:riskmaster/providers/auth_provider.dart';
import 'package:riskmaster/providers/criteria_provider.dart';
import 'package:riskmaster/providers/alternative_provider.dart';
import 'package:riskmaster/providers/assessment_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CriteriaProvider()),
          ChangeNotifierProvider(create: (_) => AlternativeProvider()),
          ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ],
        child: const RiskMasterApp(),
      ),
    );
    expect(find.byType(RiskMasterApp), findsOneWidget);
  });
}
