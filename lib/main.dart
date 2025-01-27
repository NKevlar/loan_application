// lib/main.dart
import 'package:flutter/material.dart';
import 'package:loan_application/providers/config_provider.dart';
import 'package:provider/provider.dart';
import 'pages/loan_application.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfigProvider(),
      child: MaterialApp(
        home: LoanApplicationPage(),
        theme: ThemeData(
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}