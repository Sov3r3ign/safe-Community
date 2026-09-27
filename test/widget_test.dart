import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_app/main.dart';

void main() {
  testWidgets('login form validates missing credentials', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('registration rejects mismatched passwords', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Test Resident');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'resident@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '0712345678');

    final passwordFields = find.byType(TextFormField);
    await tester.enterText(passwordFields.at(3), 'password1');
    await tester.enterText(passwordFields.at(4), 'password2');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
